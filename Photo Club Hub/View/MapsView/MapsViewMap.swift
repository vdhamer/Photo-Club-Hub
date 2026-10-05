//
//  MapsViewMap.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import MapKit // for MKMapItem
import CoreData // for FetchedResults
import Photo_Club_Hub_Data // for types like Organization

/// Map showing the selected club/museum in the middle, with markers for other organizations and the user's location.
/// Includes the standard map controls (compass, pitch toggle, scale, user-location button)
/// which are hidden when the map's pan/zoom interaction is locked.
@MainActor
struct MapsViewMap: View {

    @ObservedObject var mapOrganization: Organization // the organization this map is about and is centered on
    var fetchedOrganizations: FetchedResults<Organization> // all organizations; `markedOrganizations` picks from these
    let isMapScrollLocked: Bool // read-only copy; the @State lives in `MapsViewCard`, whose lock button toggles it

    /// Height of the map. Shared with the placeholder that `MapsViewCard` shows before the map is live (#870),
    /// so the card keeps its height when switching from a placeholder to an actual live map.
    static let minHeight: CGFloat = 300
    static let idealHeight: CGFloat = 500

    /// Width and height of the organization's default view, which every map starts with and returns to when locked.
    private static let defaultViewSpanMeters: CLLocationDistance = 10_000 // 10 km

    /// How far from the organization a locked map still draws markers. A locked map cannot pan or zoom, so it only
    /// ever shows `defaultViewSpanMeters` around the organization. MapKit fits that span into the *shorter* side of
    /// the map and shows more along the longer side, so a wide row (iPad, landscape) reaches further out left and
    /// right. Three times the half-span covers a map up to three times as wide as it is tall; a marker drawn just
    /// outside the visible area costs little.
    private static let lockedMarkerRadiusMeters: CLLocationDistance = 3 * defaultViewSpanMeters / 2 // 15 km

    /// What the map shows. Starts as the organization's default view; when the lock is open, the user can pan and
    /// zoom it. Set once, as the initial value of the `@State`, and not on every appearance: SwiftUI ignores the
    /// initial value while it keeps this view's state, so the user's view survives scrolling away and back, just like
    /// the lock in `MapsViewCard` does (#866).
    @State private var cameraPosition: MapCameraPosition

    /// The tag of the marker MapKit has selected, or nil when nothing is selected. Keeps the map marker (the purple
    /// one, of the organization the map is about) selected, only because MapKit draws the selected annotation on top
    /// of all others. The SwiftUI map offers no other way to order annotations: by itself, MapKit puts the southern one
    /// on top, which can bury the purple marker under a neighbor's if there is overlap. Only the map marker has a
    /// tag, so no other marker can be selected.
    /// A tap on a marker (#256) can use an ordinary tap gesture (instead of selection).
    /// Side effect: MapKit always shows a selected annotation's name, even over a neighbor's marker.
    /// `MapsViewSnapshot` does the same on the image of a locked map, so the map marker's name is shown on both.
    @State private var mapMarkerTagString: String? = Self.mapMarkerIDString

    /// The tag of the map marker: an invisible ID, the same for every map. Never shown; only equality matters.
    /// Not to be confused with a marker's label, the organization's name shown below it.
    private static let mapMarkerIDString = "this is the mapMarker"

    init(mapOrganization: Organization,
         fetchedOrganizations: FetchedResults<Organization>,
         isMapScrollLocked: Bool) {
        self.mapOrganization = mapOrganization
        self.fetchedOrganizations = fetchedOrganizations
        self.isMapScrollLocked = isMapScrollLocked
        _cameraPosition = State(initialValue: Self.defaultView(of: mapOrganization))
    }

    var body: some View {
        Map(position: $cameraPosition,
            interactionModes: isMapScrollLocked ? [] : [
                .rotate, // automatically enables the compas button when rotated
                .pitch, // switch to 3D view if zoomed in far enough
                .pan, .zoom], // actually .all is the default
            selection: $mapMarkerTagString) {

            // Markers for the organizations this map can show: nearby ones when locked, all of them when unlocked.
            ForEach(markedOrganizations, id: \.self) { markedOrganization in
                if Self.isMapOrganization(markedOrganization, mapOrganization: mapOrganization) {
                    annotation(for: markedOrganization)
                        .tag(Self.mapMarkerIDString) // tell MapKit it is selected, in order to get it on top
                } else {
                    annotation(for: markedOrganization)
                }
            } // Annotation loop
            UserAnnotation() // show user's location on map
        }
        .frame(minHeight: Self.minHeight, idealHeight: Self.idealHeight, maxHeight: .infinity)
        .mapControls {
            MapCompass() // map Compass shown if rotation differs from North on top
            MapPitchToggle() // switch between 2D and 3D
            MapScaleView() // distance scale
            MapUserLocationButton()
        }
        .mapControlVisibility(isMapScrollLocked ? .hidden : .automatic)
        .onChange(of: mapMarkerTagString) { _, newSelection in
            // Preparation for future interactive Markers. Isn't there yet (Oct 5th 2026)
            // A tap on the map (or on the marker itself) deselects it. Select it again, to keep it on top.
            if newSelection == nil { mapMarkerTagString = Self.mapMarkerIDString }
        }
        .onChange(of: isMapScrollLocked) { _, isLocked in
            // Locking returns the map to the organization's default view. Without this, a map zoomed out to the whole
            // country and then locked would keep that view but lose all distant markers, because a locked map only
            // draws the nearby ones. So "locked" always means "this organization's own map".
            if isLocked { cameraPosition = Self.defaultView(of: mapOrganization) }
        }
        #if DEBUG
        // #870: counts live maps, shown in the debug section of the Settings tab
        .onAppear { LiveMapCounter.shared.mapAppeared(mapOrganization.fullName) }
        .onDisappear { LiveMapCounter.shared.mapDisappeared() }
        #endif
    }

    /// The marker of one organization: our own balloon instead of MapKit's `Marker`, so it matches the image of a
    /// locked map (#867). MapKit still draws the name below it, and hides names that would collide.
    private func annotation(for organization: Organization) -> some MapContent {
        Annotation(organization.fullName,
                   coordinate: organization.coordinates,
                   anchor: .bottom) { // the balloon's tip is at the coordinates
            MapMarkerBalloon(organization: organization, mapOrganization: mapOrganization)
        }
    }

    /// Whether `candidate` is the organization a map is centered on: the one with the purple marker.
    /// Matched on name and town. Also used by `MapMarkerBalloon` to pick the purple one, so "on top" and "purple" can't
    /// disagree. Shared with `MapsViewSnapshot`.
    static func isMapOrganization(_ candidate: Organization,
                                  mapOrganization: Organization) -> Bool {
        candidate.fullName == mapOrganization.fullName && candidate.town == mapOrganization.town
    }

    /// The organizations that get a marker on this map.
    ///
    /// Every row/card on the Maps screen holds its own live map, and a fast scroll creates a hundred of them. Giving
    /// each one a marker for every organization (about 265 in September 2026) required say 100 x 265 markers.
    /// So memory grew  until iOS killed the app on an iPhone (#804).
    /// Fortunately nearly all rows are locked, which is the default, and a locked map can only show
    /// the organizations near its own, so only those get a marker. An unlocked map draws all of
    /// them, so zooming out shows every organization on the map, which is how someone gets
    /// a national or even international overview today.
    ///
    /// `isUsable`: these results are handed down by the parent view, so this list needs its own filter to skip
    /// organizations that pull-to-refresh has just deleted (#802).
    private var markedOrganizations: [Organization] {
        guard isMapScrollLocked else { // when NOT scroll locked (often), don't filter based on distance
            return fetchedOrganizations.filter { $0.isUsable }
        }
        return Self.nearbyOrganizations(around: mapOrganization, in: fetchedOrganizations)
    }

    /// The usable organizations within `lockedMarkerRadiusMeters` of `organization`, including itself:
    /// the markers of a locked map. Shared with `MapsViewSnapshot`, so its image of a locked map has the same markers.
    static func nearbyOrganizations(around organization: Organization,
                                    in fetchedOrganizations: FetchedResults<Organization>) -> [Organization] {
        let center = CLLocation(latitude: organization.latitude_, longitude: organization.longitude_)
        return fetchedOrganizations.filter { candidate in
            guard candidate.isUsable else { return false }
            let location = CLLocation(latitude: candidate.latitude_, longitude: candidate.longitude_)
            return location.distance(from: center) <= lockedMarkerRadiusMeters // check against e.g. 15km radius
        }
    }

    /// The organization's default view: `defaultViewSpanMeters` around it.
    private static func defaultView(of organization: Organization) -> MapCameraPosition {
        MapCameraPosition.region(defaultRegion(of: organization))
    }

    /// The region of the organization's default view. Shared with `MapsViewSnapshot`.
    static func defaultRegion(of organization: Organization) -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: organization.latitude_,
                                                          longitude: organization.longitude_),
                           latitudinalMeters: defaultViewSpanMeters, longitudinalMeters: defaultViewSpanMeters)
    }
}

// MARK: - Previews

// Shows this map's own organization and four fixed neighbors. The other sample organizations of
// `PersistenceController.preview` lie up to ~200 km away: zoom out in a live preview to see them.

// Believe it or not, this preview actually works.
@MainActor
struct MapsViewMapPreviews: View {

    /// The Data package's shared in-memory preview store, which the other previews use too. It has to come from
    /// `PersistenceController`: the data model lives in the package's bundle, so `NSPersistentContainer(name:)`,
    /// which searches the app's bundle, finds no model and the first Core Data call traps. And it has to be the
    /// *shared* one: Xcode runs many previews in one process, and a second `PersistenceController` loads a second
    /// copy of the model. Two models claiming the same classes make `Organization.entity()` ambiguous, and every
    /// later `@FetchRequest` in that process then throws "A fetch request must have an entity".
    /// `#Preview` puts its context in the environment for `@FetchRequest`.
    static let persistenceController = PersistenceController.preview

    let context: NSManagedObjectContext
    @ObservedObject var organization: Organization
    @FetchRequest var fetchedOrganizations: FetchedResults<Organization>

    init() {
        self.context = Self.persistenceController.container.viewContext
        self.organization = Self.seedOrganization(in: context)

        let sortDescriptors: [SortDescriptor] = [
            SortDescriptor(\Organization.pinned, order: .reverse), // pinned organizations first
            SortDescriptor(\Organization.organizationType_?.organizationTypeName_, order: .forward),
            SortDescriptor(\Organization.fullName_, order: .forward), // organization ID = name & town
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

    /// Creates Fotogroep de Gender and four imaginary neighbors in the preview store, saves them, and returns the club.
    /// Also used by the `MapsViewCard` preview. Safe to call repeatedly: `findCreateUpdate` finds what exists.
    static func seedOrganization(in context: NSManagedObjectContext) -> Organization {
        let center = CLLocationCoordinate2D(latitude: 51.42398, longitude: 5.4501) // Fotogroep de Gender (Eindhoven)

        let organization = Organization.findCreateUpdate(context: context,
                                                         organizationTypeEnum: OrganizationTypeEnum.club,
                                                         idPlus: OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                                                                    town: "Eindhoven",
                                                                                    nickname: "fgDeGender"),
                                                         coordinates: center,
                                                         removeOrganization: false,
                                                         optionalFields: OrganizationOptionalFields(),
                                                         pinned: false)

        addNeighbors(around: center, in: context)

        // Save the context so the fetch request can find the data
        do {
            try context.save()
            print("Preview: successfully saved preview input data")
        } catch {
            fatalError("Couldn't save preview data: \(error)")
        }
        return organization
    }

    /// Adds four clubs about 2.5 km north, east, south and west of `center`, so the map always shows other markers
    /// too, in the same places, and their colors can be checked. The store's randomly placed sample organizations
    /// (`PersistenceController.preview`) rarely land inside the 10 km default view. Nothing is loaded from JSON.
    private static func addNeighbors(around center: CLLocationCoordinate2D, in context: NSManagedObjectContext) {
        // MapKit converts meters to degrees at this location, so the distances hold at any latitude.
        let span = MKCoordinateRegion(center: center,
                                      latitudinalMeters: 5_000, longitudinalMeters: 5_000).span // half: 2.5 km
        let neighbors: [String: (latitude: Double, longitude: Double)] = [ // offsets in degrees
            "North": (span.latitudeDelta / 2, 0),
            "East": (0, span.longitudeDelta / 2),
            "South": (-span.latitudeDelta / 2, 0),
            "West": (0, -span.longitudeDelta / 2)
        ]
        for (name, offset) in neighbors {
            _ = Organization.findCreateUpdate(context: context,
                                              organizationTypeEnum: OrganizationTypeEnum.club,
                                              idPlus: OrganizationIdPlus(fullName: "Club \(name)",
                                                                         town: "Eindhoven",
                                                                         nickname: "fcPreview\(name)"),
                                              coordinates: CLLocationCoordinate2D(
                                                  latitude: center.latitude + offset.latitude,
                                                  longitude: center.longitude + offset.longitude),
                                              removeOrganization: false,
                                              optionalFields: OrganizationOptionalFields(),
                                              pinned: false)
        }
    }

    var body: some View {
        MapsViewMap(mapOrganization: organization,
                    fetchedOrganizations: fetchedOrganizations,
                    isMapScrollLocked: false)
    }

}

#Preview {
    VStack(alignment: .leading) {
        Divider()
        MapsViewMapPreviews()
        Divider()
    }
    .padding(30)
    .environment(\.managedObjectContext, MapsViewMapPreviews.persistenceController.container.viewContext)
}
