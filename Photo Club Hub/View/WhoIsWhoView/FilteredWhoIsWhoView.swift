//
//  FilteredWhoIsWhoView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import WebKit // for WKWebView

struct FilteredWhoIsWhoView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchRequest: FetchedResults<Photographer>

    private let isDeletePhotographersPermitted = true // disables .delete() functionality for this screen
    let searchText: Binding<String>
    let wkWebView: WKWebView

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>, wkWebView: WKWebView) {
        _fetchRequest = FetchRequest<Photographer>(sortDescriptors: [ // replaces previous fetchRequest
            SortDescriptor(\.familyName_, order: .forward),
            SortDescriptor(\.givenName_, order: .forward)
                                                                    ],
                                                   predicate: predicate,
                                                   animation: .default)

        self.searchText = searchText
        self.wkWebView = wkWebView
    }

    var body: some View {
//        Section {
            ForEach(filteredPhotographers, id: \.id) { filteredPhotographer in // each photographer's "card"
                VStack(alignment: .leading) { // there are horizontal layers within each photographer's "card"
                    HStack(alignment: .top) { // first row within each photographer's "card" with textual info

                        PhotographerIconView(isDeceased: filteredPhotographer.isDeceased)
                            .foregroundStyle(.photographerColor, .gray, .red) // red tertiary color should not show up
                            .font(.title3)
                            .frame(width: 35)
                            .padding(.top, 3)

                        WhoIsWhoTextInfo(photographer: filteredPhotographer)

                        Spacer() // push WhoIsTextInfo to the left

                        if let url: URL = filteredPhotographer.website {
                            Link(destination: url, label: {
                                Image(systemName: "link")
                                    .foregroundColor(.linkColor)
                            })
                            .buttonStyle(.plain) // to avoid entire List element to be clickable
                        }

                    }
                    .border(.gray, width: 1)

                    Spacer()
                    WhoIsWhoThumbnails(photographer: filteredPhotographer, wkWebView: wkWebView)
                    Spacer()

                } // VStack
                .accentColor(.photographerColor)
                .foregroundColor(chooseColor(accentColor: .accentColor,
                                             isDeceased: filteredPhotographer.isDeceased))

            } // ForEach filteredPhotographer
            .onDelete(perform: deletePhotographers) // can be disabled using isDeletedPhotographerEnabled flag
//        } // Section
        /* header: { // Table has only one section and it gets a header
            ItemFilterStatsView(filteredCount: filteredPhotographers.count,
                                unfilteredCount: fetchRequest.count,
                                elementType: ItemFilterStatsEnum.photographer)
            .textCase(nil) // https://sarunw.com/posts/swiftui-list-section-header-textcase/
        } // header
           */
    } // body

    private var filteredPhotographers: [Photographer] {
        if searchText.wrappedValue.isEmpty {
            return fetchRequest.filter { _ in
                true
            }
        } else {
            return fetchRequest.filter { photographer in
                photographer.fullNameFirstLast.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

    private func chooseColor(accentColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : .photographerColor
    }

    private func deletePhotographers(offsets: IndexSet) {
        guard isDeletePhotographersPermitted else { return } // exit if feature is disabled

        let fullName: String = offsets.map { filteredPhotographers[$0] }.first?.fullNameFirstLast ?? "noName"
        offsets.map { filteredPhotographers[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save() // persist deletion of photographer
                print("Deleted photographer \(fullName) and any associated memberships")
            }
        } catch {
            let nsError = error as NSError
            ifDebugFatalError("Unresolved error deleting photographer \(fullName): \(nsError), \(nsError.userInfo)",
                              file: #fileID, line: #line) // expect deprecation of #fileID in Swift 6.0
            // in release mode, the failed deletion is only logged. App doesn't stop.
        }
    }

    private struct PhotographerIconView: View {
        let isDeceased: Bool

        var body: some View {
            if isDeceased {
                Image("deceased.photographer")
            } else {
                Image(systemName: "person.text.rectangle")
            }
        }
    }
}

struct FilteredWhoIsWhoViewWrapper: View {
    var body: some View {
        let predicate = NSPredicate(format: "familyName_ = %@ || familyName_ = %@ || familyName_ = %@",
                                    argumentArray: ["Eau1", "Eau2", "Eau10"])
        @State var searchText: String = "Eau1"
        let wkWebView = WKWebView()

        return FilteredWhoIsWhoView(predicate: predicate, searchText: $searchText, wkWebView: wkWebView)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    NavigationStack {
        List {
            FilteredWhoIsWhoViewWrapper()
        }
    }
    .searchable(text: .constant("Name"))
}
