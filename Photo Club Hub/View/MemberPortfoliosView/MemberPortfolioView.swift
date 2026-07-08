//
//  MemberPortfolioView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import CoreData // for NSManagedObjectContext, FetchRequest
import SwiftUI  // for View
import WebKit   // for WKWebView
import TipKit   // for TipView

/// A list-based view that displays member portfolios with search and a Readme toolbar button.
///
/// - Presents a `FilteredMemberPortfoliosView` inside a SwiftUI `List`.
/// - Supports pull-to-refresh to delete and then reimport Core Data entities.
/// - Provides a toolbar button to open Readme documentation in a sheet.
/// - Uses a search field to filter members by name or by expertise.
///
/// Uses iOS 26 Liquid Glass APIs where available, falling back to standard styling on iOS 17/18.
struct MemberPortfolioView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// The text bound to the search field used to filter member portfolios.
    @State private var searchText: String = ""

    /// The member whose portfolio is shown; setting it (from a row) triggers navigation via
    /// `navigationDestination(item:)`. Registered here because destinations may not live inside a lazy `List` row.
    @State private var selectedPortfolio: MemberPortfolio?

    /// Single instance shared by all rows and the portfolio destination to avoid repeated WKWebView allocation.
    /// Stored in @State so it survives re-initialization of this view struct.
    @State private var wkWebView = WKWebView()

    /// Used to choose between full club name (regular/iPad) and nickname (compact/iPhone) in the navigation title.
    @Environment(\.horizontalSizeClass) private var horSizeClass

    @ObservedObject private var settingsModel = SettingsViewModel.shared

    var body: some View {
        List { // lists are automatically "Lazy"
            // Section prevents the List from adopting the tip as an implicit section header (all-caps styling).
            Section {
                // one-shot tip (toolbar → tabs migration); renders nothing once dismissed
                TipView(TabNavigationTip())
                    .tipCornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("_MemberPortfolioColor"), lineWidth: 1.5)
                    )
                    .tipBackground(Color("_MemberPortfolioColor").opacity(0.15))
                    .tint(.primary)

                TipView(ReadmeTip())
                    .tipCornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("_MemberPortfolioColor"), lineWidth: 1.5)
                    )
                    .tipBackground(Color("_MemberPortfolioColor").opacity(0.15))
                    .tint(.primary)
            }
            FilteredMemberPortfoliosView(memberPredicate: settingsModel.settings.memberPredicate,
                                         searchText: $searchText,
                                         selectedPortfolio: $selectedPortfolio)
        }
        .listStyle(.plain)
        .navigationDestination(item: $selectedPortfolio) { member in
            SinglePortfolioView(url: member.level3URL, webView: wkWebView)
                .navigationTitle(member.photographer.fullNameFirstLast + " @ " +
                                 (horSizeClass == .compact ? member.organization.nickName :
                                                             member.organization.fullName))
                .navigationBarTitleDisplayMode(.inline)
        }
        .refreshable { // for pull-to-refresh
            resetAndReloadData()
        }
        .keyboardType(.namePhonePad)
        .textInputAutocapitalization(.sentences)
        .submitLabel(.done) // currently only works with text fields?
        .autocorrectionDisabled()
        .navigationTitle(String(localized: "Clubs",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Title of page showing member portfolios"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ReadmeButton()
            }
        }
        .searchable(text: $searchText, placement: searchPlacement,
                    // .automatic
                    // .toolbar - The search field is placed in the toolbar. To right of person.text.rect.cust
                    // .sidebar - The search field is placed in the sidebar of a navigation view. Not on iPad
                    // .navigationBarDrawer - The search field is placed in an drawer of the navigation bar. OK
                    prompt: Text("Search_names_m",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: """
                                          Field at top of MemberPortfolios page that allows the user to \
                                          filter the members based on either given- and family name.
                                          """
                                ))
        .searchToolbarBehaviorIfAvailable()
    }

    /// Pull-to-refresh: clears pending reset flag, wipes Core Data, and reloads data.
    private func resetAndReloadData() {
        // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
        if Settings.dataResetPending {
            print("dataResetPending flag toggled from true to false")
        }
        Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
        PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
    }

}

// MARK: - Controlling search bar placement

/// On iOS 27, `.automatic` + `.minimize` adds a duplicate nav-bar icon.
/// While `.toolbar` + no `.minimize` suppresses it and gives the same single compact bottom button as iOS 26.
private var searchPlacement: SearchFieldPlacement {
    if #available(iOS 27, *) {
        return .toolbar
    } else {
        return .automatic
    }
}

private extension View {
    /// Applies `.searchToolbarBehavior(.minimize)` on iOS 26 only.
    /// On iOS 27+, `.minimize` adds a duplicate nav-bar icon in addition to the compact bottom button;
    /// using `.toolbar` placement without `.minimize` reproduces the iOS 26 single-button behavior instead.
    @ViewBuilder
    func searchToolbarBehaviorIfAvailable() -> some View {
        if #available(iOS 27, *) {
            self // Swift UI bug (FB23003932): .minimize displays 2 search icons
        } else if #available(iOS 26, *) {
            self.searchToolbarBehavior(.minimize)
        } else {
            self
        }
    }
}

// MARK: - Previews

// Believe it or not, this preview works.

#Preview {
    NavigationStack {
        MemberPortfolioView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
