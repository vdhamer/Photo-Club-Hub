//
//  FilteredMapsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import MapKit // for MKMapItem
import CoreData // for NSFetchRequest

@MainActor
struct FilteredMapsView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    @FetchRequest var fetchedOrganizations: FetchedResults<Organization>

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
        ForEach(filteredOrganizations, id: \.id) { filteredOrganization in // for each club or museum...

            /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
            @State var flipImageFlag: Bool = false

            VStack(alignment: .leading) {

                MapsViewTitle(organization: filteredOrganization)

                MapsViewInfo(organization: filteredOrganization)

                OrganizationViewMap(filteredOrganization: filteredOrganization,
                                    fetchedOrganizations: fetchedOrganizations) // to show all markers within map scope

                OrganizationViewRemark(organization: filteredOrganization)

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
                        localizedTown = locality ?? town // unlocalized as fallback for localized → String
                        localizedCountry = nation // optional String
                        await updateTownCountry(clubName: clubName, town: town,
                                                localizedTown: localizedTown, localizedCountry: localizedCountry)
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

extension FilteredMapsView { // reverse GeoCoding

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
