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
