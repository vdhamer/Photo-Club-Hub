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

    private let defaultCoordRegion = MKCoordinateRegion( // used as a default if region is not found
                center: CLLocationCoordinate2D(latitude: 48.858222, longitude: 2.2945), // Eifel Tower, Paris
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

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
                VStack {
                    HStack(alignment: .center) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.white, .yellow, accentColor ) // yellow secondary color shouldn't show up
                            .symbolRenderingMode(.palette)
                            .foregroundColor(.accentColor)
                            .font(.title)
                            .padding([.trailing], 5)
                        VStack(alignment: .leading) {
                            Text(verbatim: "\(filteredPhotoClub.fullName)")
                                .font(.title3)
                                .tracking(1)
                                .foregroundColor(.photoClubColor)
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
                        Spacer()
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
                            }
                        )
                        .buttonStyle(.plain) // to avoid entire List element to be clickable
                    }
                    Map(position: cameraPositionBinding(for: filteredPhotoClub.id),
                        interactionModes: filteredPhotoClub.isScrollLocked ? [] : [.pan, .zoom],
                        selection: $mapSelection) {
                        ForEach(fetchedPhotoClubs, id: \.self) { photoClub in
                            let coordinate = CLLocationCoordinate2D(latitude: photoClub.latitude_,
                                                                    longitude: photoClub.longitude_)
                            let placemark = MKPlacemark(coordinate: coordinate)
                            Marker(photoClub.shortName,
                                   systemImage: "camera",
                                   coordinate: placemark.coordinate)
                            .tint(photoClub == filteredPhotoClub ? .photoClubColor : .blue)
                        }
                    }
                        .frame(minHeight: 300, idealHeight: 500, maxHeight: .infinity)
                } // VStack
                .task {
                    initializeCameraPosition(photoClub: filteredPhotoClub) // works better than .onAppear(perform:)?
                }
                .onDisappear(perform: { try? viewContext.save() }) // store map scroll-lock states in database
                .accentColor(.photoClubColor)
                .listRowSeparator(.hidden)
                .padding()
                .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
            } // Section
        } // ForEach
        .onDelete(perform: deletePhotoClubs)
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

extension PhotoClubView {

    static var userLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 51.39184, longitude: 5.46144) // Waalre
    }

    static var userRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: PhotoClubView.userLocation,
                           latitudinalMeters: 10000, longitudinalMeters: 10000)
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
