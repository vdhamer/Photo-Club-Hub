//
//  FilteredOrganizationView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import MapKit // for MKMapItem
import CoreData // for NSFetchRequest

@MainActor
struct FilteredOrganizationView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    @FetchRequest var fetchedOrganizations: FetchedResults<Organization>

    private let searchText: Binding<String>
    private let interactionModes: MapInteractionModes = [.pan, .zoom, .rotate, .pitch]

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
        ForEach(filteredOrganizations, id: \.id) { filteredOrganization in // for each club or museum...

            /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
            @State var flipImageFlag: Bool = false

            VStack(alignment: .leading) {

                OrganizationViewTitle(filteredOrganization: filteredOrganization)

                OrganizationViewInfo(filteredOrganization: filteredOrganization)

                OrganizationViewMap(filteredOrganization: filteredOrganization,
                                    fetchedOrganizations: fetchedOrganizations) // to show all markers within map scope

                OrganizationViewRemark(filteredOrganization: filteredOrganization)

            } // VStack
            .id(filteredOrganization.id)
            .onAppear {
                // on main queue (avoid accessing NSManagedObjects on background thread!)
                let clubName = filteredOrganization.fullName
                let town = filteredOrganization.town // unlocalized
                let coordinates = filteredOrganization.coordinates

                Task.detached { // other (non-bgContext) background thread to access 2 async functions
                    var localizedTown: String
                    var localizedCountry: String?
                    do {
                        let (locality, nation) = // can be (nil, nil) for Chinese location or Chinese user location
                            try await reverseGeocode(coordinates: coordinates)
                        localizedTown = locality ?? town // unlocalized as fallback for localized -> String
                        localizedCountry = nation // optional String
                        await updateTownCountry(clubName: clubName, town: town,
                                                localizedTown: localizedTown, localizedCountry: localizedCountry)
                    } catch {
                        print("ERROR: could not reverseGeocode (\(coordinates.latitude), \(coordinates.longitude))")
                    }
                }
            }
            .onDisappear(perform: { try? viewContext.save() }) // persist map scroll-lock states when leaving page
            .accentColor(.organizationColor)
            .listRowSeparator(.hidden)
            .padding()
            .border(Color(.darkGray), width: 0.5)
            .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
        } // ForEach (filteredOrganization)
    } // body

    // find PhotoClub using identifier (clubName,oldTown) and then fill (newTown,newCountry) in CoreData database
    private func updateTownCountry(clubName: String, town: String,
                                   localizedTown: String, localizedCountry: String?) async {

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
                  \(String(describing: localizedTown)), \(String(describing: localizedCountry))
                  """)

            photoClub.localizedTown = localizedTown
            if let localizedCountry { photoClub.localizedCountry = localizedCountry}
            do {
                try bgContext.save() // persist Town, Country or both for an organization (on local context)
            } catch {
                print("""
                      ERROR: could not save \(localizedTown), \(localizedCountry ?? "nil") for \(clubName) to CoreData
                      """)
            }
        }
    }

    // conversion to [MKMapItems] is needed to make Placemarks touch (and mouse) sensitive
    private func toMapItems(organizations: FetchedResults<Organization>) -> [MKMapItem] {
        var mapItems: [MKMapItem] = []
        for organization in organizations {
            let coordinates = CLLocationCoordinate2D(latitude: organization.latitude_,
                                                     longitude: organization.longitude_)
            let placemark = MKPlacemark(coordinate: coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = organization.fullName
            mapItems.append(mapItem)
        }
        return mapItems
    }

    @MainActor
    private func deleteOrganizations(indexSet: IndexSet) {
        // Normally deletes just one organization, but this is how .onDelete works.
        // This function is no longer called (replaced by pull-down-to-reload data) but is kept for possible future use.

        if let organization = (indexSet.map {filteredOrganizations[$0]}.first) { // unwrap first PhotoClub to be deleted
            viewContext.delete(organization)

            do {
                if viewContext.hasChanges {
                    try viewContext.save() // persist deletion of organization (on main thread)
                }
            } catch {
                let nsError = error as NSError
                ifDebugFatalError("Unresolved error \(nsError), \(nsError.userInfo)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, the failed deletion is only logged. App doesn't stop.
            }
        }
    }

    private var filteredOrganizations: [Organization] {
        if searchText.wrappedValue.isEmpty {
            return fetchedOrganizations.filter { _ in
                true
            }
        } else {
            return fetchedOrganizations.filter { organization in
                organization.fullNameTown.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

}

extension FilteredOrganizationView { // reverse GeoCoding

    private func reverseGeocode(coordinates: CLLocationCoordinate2D) async throws -> (city: String?, country: String?) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude,
                                  longitude: coordinates.longitude)

        guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
            throw CLError(.geocodeFoundNoResult)
        }

        let town: String? = placemark.locality
        let country: String? = placemark.country
        return (town, country)
    }

}

struct FilteredOrganizationView_Previews: PreviewProvider {
    static let organizationPredicate = NSPredicate(format: "fullName_ = %@ || fullName_ = %@ || fullName_ = %@",
                                                   argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])
    @State static var searchText: String = ""

    static var previews: some View {
        NavigationStack {
            if #available(iOS 26, *) {
                List { // lists are "Lazy" automatically
                    FilteredOrganizationView(predicate: organizationPredicate, searchText: $searchText)
                        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                }
                .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
                .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names and towns"))
                .searchToolbarBehavior(.minimize)
            } else {
                List { // lists are "Lazy" automatically
                    FilteredOrganizationView(predicate: organizationPredicate, searchText: $searchText)
                        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                }
                .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
                .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names and towns"))
            }
        }
    }
}
