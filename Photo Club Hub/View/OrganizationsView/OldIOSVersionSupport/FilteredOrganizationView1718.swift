//
//  FilteredOrganizationView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI
import MapKit
import CoreData

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView2626' for versions above iOS 18.x")
@MainActor
struct FilteredOrganizationView1718: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    @FetchRequest var fetchedOrganizations: FetchedResults<Organization>

    @State private var cameraPositions: [OrganizationID: MapCameraPosition] = [:] // location of camera per club
    @State private var mapSelection: MKMapItem? // selected Anotation, if any

    private let searchText: Binding<String>
    private let interactionModes: MapInteractionModes = [.pan, .zoom, .rotate, .pitch]
    private let iOS18: Bool

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

        if #unavailable(iOS 18) { // used to optimize ScrollView smart scrolling under iOS 18
            iOS18 = false
        } else {
            iOS18 = true
        }
    }

    var body: some View {
        ItemFilterStatsView(filteredCount: filteredOrganizations.count,
                            unfilteredCount: fetchedOrganizations.count,
                            unit: .organization)
        ForEach(filteredOrganizations, id: \.id) { filteredOrganization in // for each club or museum...
            VStack(alignment: .leading) {
                HStack {
                    Text(verbatim: "\(filteredOrganization.fullName)") // name of club or museum (left aligned)
                        .font(UIDevice.isIPad ? .title : .title2)
                        .tracking(1)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .foregroundColor(.organizationColor)
                    Spacer()
                    if let wikipedia: URL = filteredOrganization.wikipedia { // optional Wikipedia logo (right aligned)
                        Link(destination: wikipedia, label: {
                            Image("Wikipedia", label: Text(verbatim: "Wikipedia"))
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 5)
                        })
                        .buttonStyle(.plain) // to avoid entire List element to be clickable
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: systemName(organizationType: filteredOrganization.organizationType,
                                                 circleNeeded: true) // icon for organizationType
                    )
                    .foregroundStyle(.white, .yellow, // .yellow (secondary color) not actually used
                                     filteredOrganization.organizationType.isUnknown ? .red : .accentColor)
                    .symbolRenderingMode(.palette)
                    .font(.largeTitle)
                    .padding(.horizontal, 5)

                    VStack(alignment: .leading) {
                        Text(verbatim: layoutDirection == .leftToRight ?
                             "\(filteredOrganization.localizedTown), \(filteredOrganization.localizedCountry)" :
                             "\(filteredOrganization.localizedCountry) ,\(filteredOrganization.localizedTown)")
                        .font(.subheadline)
                        if filteredOrganization.members.count > 0 { // hide for museums and clubs without members
                            Text("\(filteredOrganization.members.count) members (inc. ex-members)",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: "<count> members (including all types of members) within photo club")
                            .font(.subheadline)
                        }
                        if let website: URL = filteredOrganization.organizationWebsite {
                            Link(destination: website, label: {
                                Text(website.absoluteString)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .font(.subheadline)
                                    .foregroundColor(.linkColor)
                            })
                            .buttonStyle(.plain) // to avoid entire List element to be clickable
                        }
                    }
                    Spacer() // moved Button to trailing/right side
                    Button(
                        action: {
                            openCloseSound(openClose: filteredOrganization.isMapScrollLocked ? .close : .open)
                            filteredOrganization.isMapScrollLocked.toggle()
                        },
                        label: {
                            HStack { // to make background color clickable too
                                LockAnimationView(locked: filteredOrganization.isMapScrollLocked)
                            }
                            .frame(width: 60, height: 60)
                            .contentShape(Rectangle())
                        }
                    )
                    .buttonStyle(.plain) // to avoid entire List element to be clickable
                }
                .padding(.all, 0)
                Map(position: cameraPositionBinding(for: filteredOrganization.id),
                    interactionModes: filteredOrganization.isMapScrollLocked ? [] : [
                        .rotate, // automatically enables the compas button when rotated
                        .pitch, // switch to 3D view if zoomed in far enough
                        .pan, .zoom], // actually .all is the default
                    selection: $mapSelection) {

                    // show markers of all organizations on map
                    ForEach(fetchedOrganizations, id: \.self) { organization in
                        Marker(organization.fullName,
                               systemImage: systemName(organizationType: organization.organizationType,
                                                       circleNeeded: false),
                               coordinate: organization.coordinates)
                        .tint(selectMarkerTint(organization: organization,
                                               selectedOrganization: filteredOrganization))
                    } // Marker loop
                    UserAnnotation() // show user's location on map
                } // Map ends here
                    .frame(minHeight: 300, idealHeight: 500, maxHeight: .infinity)
                Text(filteredOrganization.localizedRemark) // display remark in preferred language (if possible)
                    .padding(.top, 5)
                    .frame(height: iOS18 ? nil : 70) // iOS 18 can handle variable size views for smart scrolling
            } // VStack
            .id(filteredOrganization.id)
            .task {
                initializeCameraPosition(organization: filteredOrganization) // better than .onAppear(perform:)?
            }
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
            .mapControls {
                MapCompass() // map Compass shown if rotation differs from North on top
                MapPitchToggle() // switch between 2D and 3D
                MapScaleView() // distance scale
                MapUserLocationButton()
            } .mapControlVisibility(filteredOrganization.isMapScrollLocked ? .hidden : .automatic)
        } // outer ForEach (filteredOrganization)
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

    private func initializeCameraPosition(organization: Organization) {
        let mapCameraPosition: MapCameraPosition

        mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D( latitude: organization.latitude_,
                                            longitude: organization.longitude_),
            latitudinalMeters: 10000, longitudinalMeters: 10000) // 10 km
        )
        cameraPositions[organization.id] = mapCameraPosition // return MapCameraPosition and don't use input param
    }

    private func cameraPositionBinding(for key: OrganizationID) -> Binding<MapCameraPosition> {
        let defaultCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 6.52396), // island on the equator
                    latitudinalMeters: 100000, longitudinalMeters: 100000)
        )

        // https://stackoverflow.com/questions/68430007/how-to-use-state-with-dictionary
        // https://forums.swift.org/t/swiftui-how-to-use-dictionary-as-binding/34967
        return .init( // a bit ackward, but the geter does return a binding
            get: { return cameraPositions[key] ?? defaultCameraPosition },
            set: { newValue in cameraPositions[key] = newValue } // is this working correctly?
        )
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

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView2626' for versions above iOS 18.x")
extension FilteredOrganizationView1718 { // reverse GeoCoding

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

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView2626' for versions above iOS 18.x")
struct FilteredOrganizationView1718_Previews: PreviewProvider {
    static let organizationPredicate = NSPredicate(format: "fullName_ = %@ || fullName_ = %@ || fullName_ = %@",
                                                   argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])
    @State static var searchText: String = ""

    static var previews: some View {
        NavigationStack {
            List { // lists are "Lazy" automatically
                FilteredOrganizationView1718(predicate: organizationPredicate, searchText: $searchText)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
            .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names and towns"))
            // .searchToolbarBehavior(.minimize) // unavailable before iOS 26
        }
    }
}
