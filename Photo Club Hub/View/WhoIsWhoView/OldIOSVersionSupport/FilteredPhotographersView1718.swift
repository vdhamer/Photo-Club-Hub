//
//  FilteredPhotographersView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import WebKit // for WKWebView

// Implements list of photographer cards including
//      * defining fetchRequest to get list of photographers sorted on last name
//      * filtering the photographer list based on search bar string
//      * per photographer card, it displays
//          - an icon (with a special icon if the photographer is deceased)
//          - photographer's name (last name first)
//          - optionally a link icon that leads to the phototographer's own website
//          - some textual information
//          - a horizontally scrolling list of thumbnails representing portfolios
// Preview unfortunately doesn't work.

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView2626' for versions above iOS 18.x")
struct FilteredPhotographersView1718: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchedPhotographers: FetchedResults<Photographer>

    private let isDeletePhotographersPermitted = true // enable/disable .onDelete() functionality for this screen
    let searchText: Binding<String>
    let wkWebView: WKWebView

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>, wkWebView: WKWebView) {
        _fetchedPhotographers = FetchRequest<Photographer>(sortDescriptors: [ // replaces previous fetchedPhotographers
                                                        SortDescriptor(\.familyName_, order: .forward),
                                                        SortDescriptor(\.givenName_, order: .forward)],
                                                   predicate: predicate,
                                                   animation: .default)
        self.searchText = searchText
        self.wkWebView = wkWebView
    }

    var body: some View {
        ItemFilterStatsView(filteredCount: filteredPhotographers.count,
                            unfilteredCount: fetchedPhotographers.count,
                            unit: .photographer)
        ForEach(filteredPhotographers, id: \.id) { photographer in // each photographer's "card"
            VStack(alignment: .leading) { // there are horizontal layers within each photographer's "card"
                HStack(alignment: .top) { // first row within each photographer's "card" with textual info

                    PhotographerIconView(isDeceased: photographer.isDeceased)
                        .foregroundStyle(.photographerColor, .gray, .red) // red tertiary color should not show up
                        .font(.title3)
                        .frame(width: 35)
                        .padding(.top, 3)

                    PhotographersTextInfo(photographer: photographer)

                    Spacer() // push PhotographersTextInfo to the left

                    if let url: URL = photographer.photographerWebsite {
                        Link(destination: url, label: {
                            Image(systemName: "link")
                                .foregroundColor(.linkColor)
                        })
                        .buttonStyle(.plain) // to avoid entire List element being clickable
                    }

                } // HStack

                PhotographersThumbnails(photographer: photographer, wkWebView: wkWebView)

            } // VStack
            .accentColor(.photographerColor)
            .foregroundColor(chooseColor(accentColor: .accentColor,
                                         isDeceased: photographer.isDeceased))
        } // ForEach filteredPhotographer
        .onDelete { indexSet in
            deletePhotographers(indexSet: indexSet) // can be disabled using isDeletedPhotographerEnabled flag
        }
    } // body

    private var filteredPhotographers: [Photographer] {
        if searchText.wrappedValue.isEmpty {
            return fetchedPhotographers.filter { _ in
                true
            }
        } else {
            return fetchedPhotographers.filter { photographer in
                photographer.fullNameFirstLast.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

    private func chooseColor(accentColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : .photographerColor
    }

    @MainActor
    private func deletePhotographers(indexSet: IndexSet) {
        guard isDeletePhotographersPermitted else { return } // exit if feature is disabled

        let fullName: String = indexSet.map { filteredPhotographers[$0] }.first?.fullNameFirstLast ?? "noName"
        indexSet.map { filteredPhotographers[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save() // persist deletion of photographer (on main thread)
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

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView2626' for versions above iOS 18.x")
struct FilteredWhoIsWhoViewWrapper1718: View {
    var body: some View {
        let predicate = NSPredicate(format: "familyName_ = %@ || familyName_ = %@ || familyName_ = %@",
                                    argumentArray: ["Eau1", "Eau2", "Eau10"])
        @State var searchText: String = "Eau1"
        let wkWebView = WKWebView()

        return FilteredPhotographersView1718(predicate: predicate, searchText: $searchText, wkWebView: wkWebView)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView2626' for versions above iOS 18.x")
#Preview {
    NavigationStack {
        List {
            FilteredWhoIsWhoViewWrapper1718()
        }
    }
    .searchable(text: .constant("Name"))
}
