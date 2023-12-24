//
//  PhotoClubView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI
import MapKit
import CoreData

struct PhotoClubView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    @FetchRequest var fetchedPhotoClubs: FetchedResults<PhotoClub>
    private let permitDeletionOfPhotoClubs = true // disables .delete() functionality for this screen
    let accentColor: Color = .accentColor // needed to solve a typing issue

    @State private var cameraPositions: [PhotoClubId: MapCameraPosition] = [:] // location of camera per club
    let interactionModes: MapInteractionModes = [.pan, .zoom, .rotate, .pitch]
    @State private var mapSelection: MKMapItem? // selected Anotation, if any

    // regenerate Section using dynamic FetchRequest with dynamic predicate and dynamic sortDescriptor
    init(predicate: NSPredicate) {
        _fetchedPhotoClubs = FetchRequest<PhotoClub>(sortDescriptors: // replaces previous fetchRequest
                                                    [SortDescriptor(\.pinned, order: .reverse), // pinned clubs first
                                                     SortDescriptor(\.name_, order: .forward), // photoclubID=name&town
                                                     SortDescriptor(\.town_, order: .forward)],
                                                     predicate: predicate,
                                                     animation: .bouncy)
    }

    var body: some View {
        ForEach(fetchedPhotoClubs, id: \.id) { filteredPhotoClub in
            Section {
                VStack(alignment: .leading) {
                    Text(verbatim: "\(filteredPhotoClub.fullName)")
                        .font(UIDevice.isIPad ? .title : .title2)
                        .tracking(1)
                        .foregroundColor(.photoClubColor)
//                        .border(.red)

                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "camera.circle.fill")
                            .foregroundStyle(.white, .yellow, accentColor ) // secondary = yellow color not really used
                            .symbolRenderingMode(.palette)
                            .font(.largeTitle)
                            .padding(.horizontal, 5)
                        VStack(alignment: .leading) {
                            Text(verbatim: layoutDirection == .leftToRight ?
                                 "\(filteredPhotoClub.town), \(filteredPhotoClub.country)" : // English, Dutch
                                 "\(filteredPhotoClub.country) ,\(filteredPhotoClub.town)") // Hebrew, Arabic
                            .font(.subheadline)
                            Text("\(filteredPhotoClub.members.count) members (inc. ex-members)",
                                 comment: "<count> members (including all types of members) within photo club")
                            .font(.subheadline)
                            if let url: URL = filteredPhotoClub.photoClubWebsite {
                                Link(destination: url, label: {
                                    Text(url.absoluteString)
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
                                openCloseSound(openClose: filteredPhotoClub.isScrollLocked ? .close : .open)
                                filteredPhotoClub.isScrollLocked.toggle()
                            },
                            label: {
                                HStack { // to make background color clickable too
                                    LockAnimationView(locked: filteredPhotoClub.isScrollLocked)
                                }
                                .frame(maxWidth: 60, maxHeight: 60)
                                .contentShape(Rectangle())
//                                .border(.red)
                            }
                        )
                        .buttonStyle(.plain) // to avoid entire List element to be clickable
                    }
                    .padding(.all, 0)
//                    .border(.blue)
                    Map(position: cameraPositionBinding(for: filteredPhotoClub.id),
                        interactionModes: filteredPhotoClub.isScrollLocked ? [] : [
                            .rotate, // automatically enables the compas button when rotated
                            .pitch, // switch to 3D view if zoomed in far enough
                            .pan, .zoom], // actually .all is the default
//                        userTrackingMode: .constant(.follow),
                        selection: $mapSelection) {

                        // show markers
                        ForEach(toMapItems(photoClubs: fetchedPhotoClubs), id: \.self) { mapItem in
                            Marker(isEqual(mapItemLHS: mapItem, mapItemRHS: mapSelection) ?
                                mapItem.name ?? "NoName??" : String(""),
                                   systemImage: "camera.fill",
                                   coordinate: mapItem.placemark.coordinate)
                                .tint(isEqual(mapItem: mapItem, photoclub: filteredPhotoClub) ? .photoClubColor : .blue)
                        }

                        UserAnnotation() // show user's location on map
                    }
                        .frame(minHeight: 300, idealHeight: 500, maxHeight: .infinity)
                } // VStack
                .task {
                    initializeCameraPosition(photoClub: filteredPhotoClub) // works better than .onAppear(perform:)?
                }
                .onAppear {
                    let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    backgroundContext.name = "reverseGeocode \(filteredPhotoClub.fullName)"
                    backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    backgroundContext.perform { // executes on background thread created for backgroundContext
                        updateTownCountry(photoClub: filteredPhotoClub, bgContext: backgroundContext)
                    }
                }
                .onDisappear(perform: { try? viewContext.save() }) // store map scroll-lock states in database
                .accentColor(.photoClubColor)
                .listRowSeparator(.hidden)
                .padding()
                .border(Color(.darkGray), width: 0.5)
                .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
                .mapControls {
                    MapCompass() // map Compass shown if rotation differs from North on top
                    MapPitchToggle() // switch between 2D and 3D
                    MapScaleView() // distance scale
                    MapUserLocationButton()
                } .mapControlVisibility(filteredPhotoClub.isScrollLocked ? .hidden : .automatic)
            } // Section
        } // outer ForEach (PhotoClub)
        .onDelete(perform: deletePhotoClubs)
    }

    private func updateTownCountry(photoClub: PhotoClub, bgContext: NSManagedObjectContext) {
        var town: String? // initialize to nil
        var country: String? // initialize to nil
        Task { // not sure about this TODO
            let coord = photoClub.coordinates
            do {
                let (locality, nation) = try await reverseGeocode(coordinates: coord)
                town = locality
                country = nation
            } catch {
                print("Could not reverseGeocode \(photoClub.fullName)'s at (\(coord.latitude), \(coord.longitude))")
            }

            if town != nil || country != nil {
                print("Location: \(photoClub.town), \(photoClub.country)")
                if let town { photoClub.town = town }
                if let country { photoClub.country = country}
                do {
                    try bgContext.save()
                } catch {
                    print("ERROR: could not save \(town ?? "nil"), \(country ?? "nil") to CoreData")
                }
            }
        }
        if town != nil || country != nil { // TODO duplicate
            print("Location: \(photoClub.town), \(photoClub.country)")
            if let town { photoClub.town = town }
            if let country { photoClub.country = country}
            do {
                try bgContext.save() // TODO this save triggers exception if com.apple.CoreData.ConcurrencyDebug = 1
            } catch {
                print("ERROR: could not save \(town ?? "nil"), \(country ?? "nil") to CoreData")
            }
        }
    }

    // conversion to [MKMapItems] is needed to make Placemarks touch (and mouse) sensitive
    private func toMapItems(photoClubs: FetchedResults<PhotoClub>) -> [MKMapItem] {
        var mapItems: [MKMapItem] = []
        for photoClub in photoClubs {
            let coordinates = CLLocationCoordinate2D(latitude: photoClub.latitude_,
                                                     longitude: photoClub.longitude_)
            let placemark = MKPlacemark(coordinate: coordinates)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = photoClub.fullName
            mapItems.append(mapItem)
        }
        return mapItems
    }

    private func initializeCameraPosition(photoClub: PhotoClub) {
        let mapCameraPosition: MapCameraPosition

        mapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D( latitude: photoClub.latitude_,
                                            longitude: photoClub.longitude_),
            latitudinalMeters: 10000, longitudinalMeters: 10000) // 10 km
        )
        cameraPositions[photoClub.id] = mapCameraPosition // return MapCameraPosition and don't use input param
    }

    private func cameraPositionBinding(for key: PhotoClubId) -> Binding<MapCameraPosition> {
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

    private func deletePhotoClubs(offsets: IndexSet) {
        guard permitDeletionOfPhotoClubs else { return } // to turn off the feature
        if let photoClub = (offsets.map { fetchedPhotoClubs[$0] }.first) { // unwrap first PhotoClub to be deleted
            photoClub.deleteAllMembers(context: viewContext)
            guard photoClub.members.count == 0 else { // safety: will crash if member.photoClub == nil
                print("Could not delete photo club \(photoClub.fullName) " +
                      "because it still has \(photoClub.members.count) members.")
                return
            }
            offsets.map { fetchedPhotoClubs[$0] }.forEach( viewContext.delete )

            do {
                if viewContext.hasChanges {
                    try viewContext.save()
                }
            } catch {
                let nsError = error as NSError
                ifDebugFatalError("Unresolved error \(nsError), \(nsError.userInfo)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, the failed deletion is only logged. App doesn't stop.
            }
        }

    }

}

extension PhotoClubView { // reverse GeoCoding

    func reverseGeocode(coordinates: CLLocationCoordinate2D) async throws -> (city: String?, country: String?) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude,
                                  longitude: coordinates.longitude)

        guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
            throw CLError(.geocodeFoundNoResult)
        }

        let town = placemark.locality
        let country = placemark.country
//        print("\(placemark.locality ?? "No Town")")
//        print("\(placemark.country ?? "No Country")")
        return (town, country)
    }

}

extension PhotoClubView {

    static var userLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 51.39184, longitude: 5.46144) // Waalre
    }

    static var userRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: PhotoClubView.userLocation,
                           latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}

extension PhotoClubView { // tests for equality

    private func isEqual(mapItem: MKMapItem, photoclub: PhotoClub) -> Bool {
        // a little bit scary to compare two floats for equality, but for now it only affects the color of the marker
        if mapItem.placemark.coordinate.latitude != photoclub.coordinates.latitude {
            return false
        } else {
            return mapItem.placemark.coordinate.longitude == photoclub.coordinates.longitude
        }
    }

    private func isEqual(mapItemLHS: MKMapItem, mapItemRHS: MKMapItem?) -> Bool {
        // a little bit scary to compare two floats for equality
        if mapItemLHS.placemark.coordinate.latitude != mapItemRHS?.placemark.coordinate.latitude {
            return false
        } else {
            return mapItemLHS.placemark.coordinate.longitude == mapItemRHS?.placemark.coordinate.longitude
        }
    }

}

struct PhotoClubsInner_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationStack {
            List { // lists are "Lazy" automatically
                PhotoClubView(predicate: predicate)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
        }
    }
}
