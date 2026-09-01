//
//  FilteredMapsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import MapKit // for MKMapItem
import CoreData // for NSFetchRequest
import Photo_Club_Hub_Data // for types like Organization

@MainActor
struct FilteredMapsView: View {

    /// Would return nothing — what `organizationPredicate` yields when every category toggle is off.
    private static let predicateNone = NSPredicate(format: "FALSEPREDICATE")

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    @FetchRequest var fetchedOrganizations: FetchedResults<Organization>

    /// Unfiltered query that answers one question: does the data store hold *any* organization at all?
    /// That separates "nothing has been loaded" from "your filters hide everything", which the above
    /// FetchRequest cannot distinguish because its own predicate is one of the suspects (#821).
    /// Only `isEmpty` is ever read — never a relationship — so it stays clear of the deleted-row
    /// accessors that `isUsable` guards against (#802).
    @FetchRequest(fetchRequest: {
        let request = Organization.fetchRequest()
        request.sortDescriptors = [] // required: @FetchRequest traps on a request with nil sortDescriptors
        request.fetchLimit = 1       // one row is enough to answer "any?"
        return request
    }()) private var anyOrganizationProbe: FetchedResults<Organization>

    /// The language these cards are shown in: the app's own resolved UI language, so a localized town
    /// reads in the same language as the rest of the interface. `knownRegions` is en/nl, so this can only
    /// resolve to a language the site generator also publishes, which keeps the rows written here
    /// interchangeable with the ones `OrganizationGeocoder` writes (#827).
    ///
    /// A `@FetchRequest` rather than a lookup per card: SwiftUI maintains it, so the row is not
    /// re-fetched on every body evaluation. Empty only if `Language.initConstants` has not run.
    @FetchRequest(fetchRequest: {
        let request = Language.fetchRequest()
        request.predicate = NSPredicate(format: "isoCode_ =[c] %@", // avoid localization
                                        Locale.current.language.languageCode?.identifier ?? "en")
        request.sortDescriptors = [] // required: @FetchRequest traps on a request with nil sortDescriptors
        request.fetchLimit = 1       // one row is enough
        return request
    }()) private var uiLanguages: FetchedResults<Language> // fetchRequests returns array, although this hold only 1

    private let searchText: Binding<String>

    // regenerate Section using dynamic FetchRequest with dynamic predicate and dynamic sortDescriptor
    init(predicate: NSPredicate, searchText: Binding<String>) {
        let sortDescriptors: [SortDescriptor] = [
            SortDescriptor(\Organization.pinned, order: .reverse), // pinned clubs first
            SortDescriptor(\Organization.organizationType_?.organizationTypeName_, order: .forward),
            SortDescriptor(\Organization.fullName_, order: .forward), // photoclubID=name&town
            SortDescriptor(\Organization.town_, order: .forward)
        ]

        _fetchedOrganizations = FetchRequest<Organization>(
            sortDescriptors: sortDescriptors, // replaces previous fetchRequest
            predicate: predicate,
            animation: .easeIn
        )
        self.searchText = searchText
    }

    var body: some View {
        ItemFilterStatsView(filteredCount: filteredOrganizations.count,
                            unfilteredCount: fetchedOrganizations.count,
                            unit: .organization)
        // Like a `guard`: deal with the reasons the screen could be empty, then get on with the happy flow below.
        // Every reason but `.listHasRows` implies the ForEach is empty, so the two never both show.
        EmptyListHint(reason: emptyListReason(),
                      tint: .mapsColor,
                      wording: hintText)
            .padding(.horizontal) // the organization cards bring their own padding; a callout doesn't.
        ForEach(filteredOrganizations, id: \.id) { filteredOrganization in // for each club or museum...

            /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
            @State var flipImageFlag: Bool = false

            VStack(alignment: .leading) {

                MapsViewTitle(organization: filteredOrganization)

                MapsViewInfo(organization: filteredOrganization, language: uiLanguages.first)

                MapView(filteredOrganization: filteredOrganization,
                        fetchedOrganizations: fetchedOrganizations) // to show all markers within map scope

                MapsViewRemark(organization: filteredOrganization)

            } // VStack
            .id(filteredOrganization.id)
            .onAppear {
                // on main queue (avoid accessing NSManagedObjects on background thread!)
                let clubName = filteredOrganization.fullName
                let town = filteredOrganization.town // unlocalized
                let coordinates = filteredOrganization.coordinates

                // Apple's geocoder is rate limited, so don't spend a request re-deriving a name already
                // stored. A card re-appears every time it is added to the hierarchy again (#827).
                guard let uiLanguage = uiLanguages.first else { return } // Language table not seeded yet
                guard Self.needsGeocoding(filteredOrganization, for: uiLanguage) else { return }
                let isoCode = uiLanguage.isoCode

                // Deliberately outlives the card. `.onAppear` does not await this, and nothing cancels it
                // when the card scrolls away: but, by then, the rate-limited request has already been spent,
                // so abandoning it would discard an answer worth keeping for every later appearance and every
                // later launch — this fills the cache, not just this card. The guard above means it runs at
                // most once per organization per language. At least, until the entire database content is wiped
                // but that is increasingly unnecessary/discouraged in the app's roadmap.
                // Both awaited methods are `@MainActor`-isolated, because `FilteredMapsView` is,
                // so detaching keeps `.onAppear` from waiting but does not move the work off the main thread.
                Task.detached {
                    var localizedTown: String
                    var localizedCountry: String?
                    do {
                        let (locality, nation) = // can be (nil, nil) for Chinese location or Chinese user location
                            try await reverseGeocode(coordinates: coordinates, isoCode: isoCode)
                        localizedTown = locality ?? town // unlocalized as fallback for localized → String
                        localizedCountry = nation // optional String
                        // Nothing consumes the result, and nothing needs to: the background save merges
                        // into `viewContext` (`automaticallyMergesChangesFromParent`, set in
                        // `PersistenceController`) and the `@FetchRequest` above re-renders the card. The
                        // await only keeps this task alive until the save has landed.
                        await updateTownCountry(
                            clubName: clubName, town: town, languageIsoCode: isoCode,
                            addressStrings: LocalizedAddressStrings(
                                localizedTown: localizedTown,
                                localizedCountry: localizedCountry ?? LocalizedAddress.unknownCountry),
                            coordinates: coordinates)
                    } catch {
                        print("ERROR: could not reverseGeocode (\(coordinates.latitude), \(coordinates.longitude))")
                    }
                }
            }
            .onDisappear(perform: { try? viewContext.save() }) // persist map scroll-lock states when leaving page
            .accentColor(.mapsColor)
            .listRowSeparator(.hidden)
            .padding()
            .border(Color(.darkGray), width: 0.5)
            .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
        } // ForEach (filteredOrganization)
    } // body

    // MARK: - explaining an empty FilteredMapsView screen to the user

    /// Picks the single reason the screen is empty. The priority order itself lives in
    /// `EmptyListReason.resolve`, shared with Clubs and People; only the inputs below are specific to
    /// this screen.
    ///
    /// `MapsView` used to make this call from a single `organizations.isEmpty` test on the *unfiltered*
    /// fetch, which could only ever answer `databaseEmpty` — so it stayed silent on both filter cases and
    /// flashed "pull down to reload" during the pull-to-refresh that had just emptied the store (#821).
    private func emptyListReason() -> EmptyListReason {
        EmptyListReason.resolve(hasVisibleRows: !filteredOrganizations.isEmpty,
                                allCategoriesOff: fetchedOrganizations.nsPredicate == Self.predicateNone,
                                storeIsEmpty: anyOrganizationProbe.isEmpty,
                                searchIsEmpty: searchText.wrappedValue.isEmpty)
    }

    /// The wording for each reason that has any. `nil` covers the two cases where the screen should stay
    /// silent: organizations are on display, or a pull-to-refresh is in progress and its spinner said it.
    private func hintText(for reason: EmptyListReason) -> Text? {
        switch reason {

        case .listHasRows, .refreshing, .buildingDatabase:
            return nil

        case .noCategoriesEnabled:
            return Text("""
                        Warning: \
                        all organization categories (Clubs and Museums) on the Settings page are disabled. \
                        To see maps, please adjust the filter settings in the Settings tab.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if all of the Organization toggles are disabled.")

        case .databaseEmpty: // wording unchanged from the NoClubsText this replaced, translations included
            return Text("""
                        No photo clubs or museums appear to be currently loaded.
                        Try dragging down the Organizations screen to reload the default clubs.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if the database returns zero Organizations.")

        case .searchFilterTooStrict:
            return Text("""
                        To see clubs and museums here, please adapt the Search filter \
                        or enable additional categories on the Preferences page.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if zero Organizations remain visible with Search filter in use.")

        case .categoriesTooStrict:
            return Text("""
                        To see clubs and museums here, please enable additional categories \
                        on the Preferences page.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if the database returns zero Organizations, empty Search filter.")
        }
    }

    /// Stores one geocoded address: creates or updates the `LocalizedAddress` row for this organization
    /// in this language, on a private background context.
    ///
    /// Everything arrives as values rather than as objects because `NSManagedObject` is not `Sendable` and
    /// is bound to the context that fetched it. So the organization and the language are re-found here, in
    /// the background context, from keys the caller captured on the main queue before detaching.
    ///
    /// - Parameters:
    ///   - clubName: the organization's `fullName`. Together with `town` it is the store's unique identifier of an `Organization`,
    ///     so the pair re-finds exactly one row.
    ///   - town: the *unlocalized* town from the JSON — the second half of that key, not the geocoded name.
    ///   - languageIsoCode: the language the address was derived in, used to re-find the `Language` row.
    ///     A string rather than a `Language`, for the sendability reason above.
    ///   - addressStrings: the geocoded town and country. Bundled into one value because the five
    ///     parameters here are SwiftLint's limit, which is what that type exists for.
    ///   - coordinates: the coordinates the address was derived from. Stored as `prevCoordinates`, so a
    ///     club that later moves is geocoded again rather than keeping a name for where it used to be.
    private func updateTownCountry(clubName: String, town: String, languageIsoCode: String,
                                   addressStrings: LocalizedAddressStrings,
                                   coordinates: CLLocationCoordinate2D) async {

        let bgContext = PersistenceController.shared.container.newBackgroundContext() // background thread
        bgContext.name = "save reverseGeocode \(clubName)"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        bgContext.performAndWait { // block must be synchronous and CoreData operations must occur on bgContext thread
            let fetchRequest: NSFetchRequest<Organization>
            fetchRequest = Organization.fetchRequest()

            // Create the component predicates
            let clubPredicate = NSPredicate(format: "fullName_ = %@", clubName)
            let townPredicate = NSPredicate(format: "town_ = %@", town)

            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [clubPredicate, townPredicate]
            )

            let photoClub = try? bgContext.fetch(fetchRequest).first
            guard let photoClub else {
                print("ERROR: couldn't find photo club in CoreData query")
                return
            }

            print("""
                  Photo Club: \(photoClub.fullName), \(photoClub.town) -> \
                  \(addressStrings.localizedTown), \(addressStrings.localizedCountry) [\(languageIsoCode)]
                  """)

            guard let language = Language.find(context: bgContext, isoCode: languageIsoCode) else {
                print("ERROR: no Language row for \(languageIsoCode); cannot store a localized address")
                return
            }

            // `findCreateUpdate` compares before assigning and records `prevCoordinates`, so an unchanged
            // re-geocode leaves the row clean and a club that moved is detected next time (#827).
            LocalizedAddress.findCreateUpdate(
                bgContext: bgContext,
                organization: photoClub,
                language: language,
                newLocalizedAddressStrings: addressStrings,
                newCoordinates: coordinates)

            guard bgContext.hasChanges else { return }
            do {
                try bgContext.save() // persist the localized address for this (organization × language)
            } catch {
                print("""
                      ERROR: could not save \(addressStrings.localizedTown) for \(clubName) to CoreData
                      """)
            }
        }
    }

    // isUsable keeps rows that pull-to-refresh has just deleted out of the view tree: their
    // relationships are already nullified, so rendering them trips the accessors (issue #802).
    private var filteredOrganizations: [Organization] {
        if searchText.wrappedValue.isEmpty {
            return fetchedOrganizations.filter { organization in
                organization.isUsable
            }
        } else {
            return fetchedOrganizations.filter { organization in
                organization.isUsable &&
                organization.fullNameTown.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

}

extension FilteredMapsView { // reverse GeoCoding

    /// True when this organization has no localized address in `language`, or when it has moved since
    /// the stored one was derived.
    ///
    /// A row is per (organization × language), so unlike the deprecated single-slot columns this cannot
    /// serve a name in the wrong language: a device switched to another supported language simply finds
    /// no row and geocodes afresh. `prevCoordinates` covers the other staleness — a club whose
    /// coordinates changed in the JSON — which the columns could not express at all (#827).
    static func needsGeocoding(_ organization: Organization, for language: Language) -> Bool {
        guard let address = organization.localizedAddress(for: language) else { return true }
        return address.prevCoordinates != organization.coordinates
    }

    /// Reverse-geocodes in `isoCode` rather than in whatever the device implies, so the stored name is a
    /// decision rather than an accident. Mirrors `OrganizationGeocoder`, which sets `preferredLocale` per
    /// language as it loops over the languages the site publishes in (#827).
    private func reverseGeocode(coordinates: CLLocationCoordinate2D,
                                isoCode: String) async throws -> (city: String?, country: String?) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude,
                                  longitude: coordinates.longitude)

        guard let placemark = try await geocoder.reverseGeocodeLocation(
            location, preferredLocale: Locale(identifier: isoCode)).first else {
            throw CLError(.geocodeFoundNoResult)
        }

        let town: String? = placemark.locality
        let country: String? = placemark.country
        return (town, country)
    }

}

// MARK: - Previews

// Unfortunately, the following Preview doesn't work yet.
// It was generated by Claude 4.5 but doesn't create data to work with?
struct FilteredOrganizationView_Previews: PreviewProvider {
    static let organizationPredicate = NSPredicate(format: "TRUEPREDICATE")
    @State static var searchText: String = ""

    static var previews: some View {
        NavigationStack {
            if #available(iOS 26, *) {
                List { // lists are "Lazy" automatically
                    FilteredMapsView(predicate: organizationPredicate, searchText: $searchText)
                        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                }
                .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
                .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names and towns"))
                .searchToolbarBehavior(.minimize)
            } else {
                List { // lists are "Lazy" automatically
                    FilteredMapsView(predicate: organizationPredicate, searchText: $searchText)
                        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                }
                .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
                .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names and towns"))
            }
        }
    }
}
