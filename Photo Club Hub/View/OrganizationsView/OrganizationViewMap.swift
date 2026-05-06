//
//  OrganizationViewMap.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import MapKit // for MKMapItem
import CoreData // for FetchedResults

/// Map showing the selected club/museum in the middle, with markers for other organizations and the user's location.
/// Includes the standard map controls (compass, pitch toggle, scale, user-location button)
/// which are hidden when the map's pan/zoom interaction is locked.
@MainActor
struct OrganizationViewMap: View {

    @ObservedObject var filteredOrganization: Organization // observes isMapScrollLocked toggle
    var fetchedOrganizations: FetchedResults<Organization> // all organizations, used to draw all markers

    /// Location of center of map. When the lock icon is open, `cameraPosition` can be shifted by panning the map.
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 6.52396), // island on the equator
                latitudinalMeters: 100000, longitudinalMeters: 100000)
    )
    @State private var mapSelection: MKMapItem? // selected marker/pin. Probably can never be `nil`.

    var body: some View {
        Map(position: $cameraPosition,
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
        }
        .frame(minHeight: 300, idealHeight: 500, maxHeight: .infinity)
        .mapControls {
            MapCompass() // map Compass shown if rotation differs from North on top
            MapPitchToggle() // switch between 2D and 3D
            MapScaleView() // distance scale
            MapUserLocationButton()
        }
        .mapControlVisibility(filteredOrganization.isMapScrollLocked ? .hidden : .automatic)
        .task {
            initializeCameraPosition() // better than .onAppear(perform:)?
        }
    }

    private func initializeCameraPosition() {
        cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: filteredOrganization.latitude_,
                                           longitude: filteredOrganization.longitude_),
            latitudinalMeters: 10000, longitudinalMeters: 10000) // 10 km
        )
    }
}

// MARK: - Preview

//        let predicateFormat: String = "town_ = %@ || town_ = %@" // avoid localization
//        let predicate = NSPredicate(format: predicateFormat,
//                                    argumentArray: [ "Waalre", "Eindhoven" ] ) TODO

// Preview partially works: doesn't show markers
@MainActor
struct OrganizationViewMapPreviews: View {

    let context: NSManagedObjectContext
    @ObservedObject var organization: Organization
    @FetchRequest var fetchedOrganizations: FetchedResults<Organization>

    init() {
        let container = NSPersistentContainer(name: "Photo_Club_Hub")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, _ in }
        self.context = container.viewContext

        self.organization = Organization.findCreateUpdate(context: context,
                                                          organizationTypeEnum: OrganizationTypeEnum.club,
                                                          idPlus: OrganizationIdPlus(fullName: "Fotogroep Waalre",
                                                                                     town: "Waalre",
                                                                                     nickname: "fgWaalre"),
                                                          coordinates: CLLocationCoordinate2D(latitude: 51.39184,
                                                                                              longitude: 5.46144),
                                                          removeOrganization: false,
                                                          optionalFields: OrganizationOptionalFields(),
                                                          pinned: false)

        _ = Level1JsonReader(bgContext: context, isBeingTested: false, useOnlyInBundleFile: false)

        // Save the context so the fetch request can find the data
        do {
            try context.save()
            print("Preview: successfully saved preview input data")
        } catch {
            fatalError("Couldn't save preview data: \(error)")
        }

        let sortDescriptors: [SortDescriptor] = [
            SortDescriptor(\Organization.pinned, order: .reverse), // pinned clubs first
            SortDescriptor(\Organization.organizationType_?.organizationTypeName_, order: .forward),
            SortDescriptor(\Organization.fullName_, order: .forward), // photoclubID=name&town
            SortDescriptor(\Organization.town_, order: .forward)
        ]

        let predicate = NSPredicate(format: "TRUEPREDICATE")
        _fetchedOrganizations = FetchRequest<Organization>(
            sortDescriptors: sortDescriptors, // replaces previous fetchRequest
            predicate: predicate,
            animation: .easeIn
        )
        print("Preview: \(fetchedOrganizations.count) returned organizations")
    }

    var body: some View {
        OrganizationViewMap(filteredOrganization: organization, fetchedOrganizations: fetchedOrganizations)
            .onAppear {
                organization.isMapScrollLocked = false
            }
    }

}

#Preview {
    VStack(alignment: .leading) {
        Divider()
        OrganizationViewMapPreviews()
        Divider()
    }
    .padding(30)
}
