//
//  PhotoClubs.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI
import MapKit
import CoreData

struct PhotoClubsInnerView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchRequest: FetchedResults<PhotoClub>
    private let permitDeletionOfPhotoClubs = true // disables .delete() functionality for this section
    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft
    @State private var scrollLocks: [PhotoClubId: Bool] = [:] // blocks scrolling and panning of maps
    let accentColor: Color = .accentColor // needed to solve a typing issue

    // regenerate Section using dynamic FetchRequest with dynamic predicate and dynamic sortDescriptor
    init(predicate: NSPredicate) {
        _fetchRequest = FetchRequest<PhotoClub>(sortDescriptors: // replaces previous fetchRequest
                                                    [SortDescriptor(\.priority_, order: .reverse), // highest prio first
                                                     SortDescriptor(\.name_, order: .forward), // photoclubID=name&town
                                                     SortDescriptor(\.town_, order: .forward)],
                                                predicate: predicate,
                                                animation: .default)
    }

    var body: some View {
        ForEach(fetchRequest, id: \.id) { filteredPhotoClub in
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.white, .yellow, accentColor ) // yellow secondary color should not show up
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
                            if scrollLocks[filteredPhotoClub.fullNameCommaTown] != nil {
                                openCloseSound(openClose: scrollLocks[filteredPhotoClub.fullNameCommaTown]!
                                               ? .close : .open)
                                filteredPhotoClub.isScrollLocked.toggle()
                                scrollLocks[filteredPhotoClub.fullNameCommaTown]! = filteredPhotoClub.isScrollLocked
                            }
                        },
                        label: {
                            HStack { // to make background color clickable too
                                if let isLocked = scrollLocks[filteredPhotoClub.fullNameCommaTown] {
                                    LockAnimationView(locked: .constant(isLocked))
                                }
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
                    interactionModes: (scrollLocks[filteredPhotoClub.id] ?? false) ? [] : [.zoom, .pan],
                    annotationItems: fetchRequest) { photoClub in
                    MapMarker( coordinate: photoClub.coordinates,
                               tint: photoClub == filteredPhotoClub ? .photoClubColor : .blue )
                }
                    .frame(minHeight: 300, idealHeight: 500, maxHeight: .infinity)
                    .onAppear(perform: { scrollLocks[filteredPhotoClub.fullNameCommaTown] =
                                                                                    filteredPhotoClub.isScrollLocked })
                    .onDisappear(perform: { try? viewContext.save() }) // to store map scroll lock state in database
            }
            .accentColor(.photoClubColor)
        }
        .onDelete(perform: deletePhotoClubs)
    }

    func deletePhotoClubs(offsets: IndexSet) {
        guard permitDeletionOfPhotoClubs else { return } // to turn off the feature
        if let photoClub = (offsets.map { fetchRequest[$0] }.first) { // unwrap first PhotoClub to be deleted
            photoClub.deleteAllMembers(context: viewContext)
            guard photoClub.members.count == 0 else { // safety: will crash if member.photoClub == nil
                print("Could not delete photo club \(photoClub.fullName) " +
                      "because it still has \(photoClub.members.count) members.")
                return
            }
            offsets.map { fetchRequest[$0] }.forEach( viewContext.delete )

            do {
                if viewContext.hasChanges {
                    try viewContext.save()
                }
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }

    }

}

struct PhotoClubsInner_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationStack {
            List { // lists are "Lazy" automatically
                PhotoClubsInnerView(predicate: predicate)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("PhotoClubInnerView"))) // prevent localization
        }
    }
}
