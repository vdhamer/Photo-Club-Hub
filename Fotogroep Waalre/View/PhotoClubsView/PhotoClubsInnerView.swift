//
//  PhotoClubs.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI
import MapKit

struct PhotoClubsInnerView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchRequest: FetchedResults<PhotoClub>
    private let deletePhotoClubs = false // disables .delete() functionality for this section
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft
    @State private var scrollLocks: [String: Bool] = [:] // blocks scrolling and panning of maps

    // regenerate Section using dynamic FetchRequest with dynamic predicate and dynamic sortDescriptor
    init(predicate: NSPredicate) {
        _fetchRequest = FetchRequest<PhotoClub>(sortDescriptors: // replaces previous fetchRequest
                                                    [SortDescriptor(\.priority_, order: .reverse), // highest prio first
                                                     SortDescriptor(\.name_, order: .forward)],
                                                predicate: predicate,
                                                animation: .default)
    }

    var body: some View {
        ForEach(fetchRequest, id: \.id) { filteredPhotoClub in
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.accentColor)
                        .font(.title)
                        .padding([.trailing], 5)
                    VStack(alignment: .leading) {
                        Text(verbatim: "\(filteredPhotoClub.name)")
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
                            if scrollLocks[filteredPhotoClub.name] != nil {
                                openCloseSound(openClose: scrollLocks[filteredPhotoClub.name]! ? .close : .open)
                                scrollLocks[filteredPhotoClub.name] = !scrollLocks[filteredPhotoClub.name]!
                            }
                        },
                        label: {
                            HStack { // to make background color clickable too
                                LockAnimationView(locked: scrollLocks[filteredPhotoClub.name] ?? true)
                            }
                            .frame(maxWidth: 60, maxHeight: 60)
                            .contentShape(Rectangle())
                        }
                    )
                         .buttonStyle(.plain) // to avoid entire List element to be clickable
                }
                Map(coordinateRegion: .constant(
                    MKCoordinateRegion(center: CLLocationCoordinate2D(
                        latitude: filteredPhotoClub.latitude_,
                        longitude: filteredPhotoClub.longitude_),
                                       span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))),
                    interactionModes: (scrollLocks[filteredPhotoClub.name] ?? true) ? [] : [.zoom, .pan],
                    annotationItems: fetchRequest) { photoClub in
                    MapPin( coordinate: photoClub.coordinates,
                            tint: photoClub == filteredPhotoClub ? .photoClubColor : .blue )
                }
                    .frame(minHeight: 300, idealHeight: 500, maxHeight: .infinity)
                    .onAppear(perform: { scrollLocks[filteredPhotoClub.name] = fetchRequest.count > 1 })
            }
            .accentColor(.photoClubColor)
        }
    }

    func deletePhotoClubs(offsets: IndexSet) {
        guard deletePhotoClubs else { return }
        let name: String = offsets.map { fetchRequest[$0] }.first?.name_ ?? "DefaultPhotoClubName"
        offsets.map { fetchRequest[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save()
            }
            print("Deleted photo club \(name) and all of its members")
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}

struct PhotoClubsInner_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationView {
            List { // lists are "Lazy" automatically
                PhotoClubsInnerView(predicate: predicate)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
        }
        .navigationViewStyle(.stack)
    }
}
