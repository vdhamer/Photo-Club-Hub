//
//  SimplifiedPhotoClubView.swift (for testing layout problem with PhotoClubView)
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 19/11/2023.
//

import SwiftUI
import MapKit
import CoreData

struct SimplifiedPhotoClubView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct

    @FetchRequest var fetchedPhotoClubs: FetchedResults<PhotoClub>
    let accentColor: Color = .accentColor // needed to solve a typing issue
    @State private var buttonState: Bool = false

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
                VStack(alignment: .leading) {
                    Text(verbatim: "\(filteredPhotoClub.fullName)")
                        .font(.title)
                        .border(.red)
                    HStack(alignment: .center, spacing: 0) {
                        VStack {
                            Text("VStack1")
                            Text("VStack2")
                            Text("VStack3")
                        }.border(.red)
                        Spacer() // push Button to trailing/right side
                        Button(
                            action: {
                                buttonState.toggle()
                            },
                            label: {
                                HStack { // to make background color clickable too
                                    LockAnimationView(locked: buttonState)
                                }
                                .frame(maxWidth: 60, maxHeight: 60)
                                .contentShape(Rectangle())
                                .border(buttonState ? .green: .red)
                            }
                        )
                        .buttonStyle(.plain) // to avoid entire List element to be clickable
                    }
                    .padding(.all, 0)
                    .border(.blue)
                    Text(verbatim: "\(filteredPhotoClub.fullName)")
                        .font(.title)
                        .border(.red)
                    Map(interactionModes: [])
                        .frame(minHeight: 50, idealHeight: 100, maxHeight: .infinity)
                } // VStack
                .accentColor(.photoClubColor)
                .padding()
                .border(Color(.photoClubColor), width: 1)
                .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
            } // Section
        } // ForEach
    }

} // PhotoClubView2
