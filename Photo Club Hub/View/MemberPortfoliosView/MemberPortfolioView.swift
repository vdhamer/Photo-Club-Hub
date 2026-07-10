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

/// A list-based view that displays member portfolios with Readme and Search toolbar buttons.
///
/// - Presents a `FilteredMemberPortfoliosView` inside a SwiftUI `List`.
/// - Supports pull-to-refresh to delete and then reimport Core Data entities.
/// - Provides a toolbar button to open Readme documentation in a sheet.
///
/// Uses iOS 26 Liquid Glass APIs where available, falling back to standard styling on iOS 17/18.
struct MemberPortfolioView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// The member whose portfolio is shown; setting it (from a row) triggers navigation via
    /// `navigationDestination(item:)`. Registered here because destinations may not live inside a lazy `List` row.
    @State private var selectedPortfolio: MemberPortfolio?

    /// Single instance shared by all rows and the portfolio destination to avoid repeated WKWebView allocation.
    /// Stored in @State so it survives re-initialization of this view struct.
    @State private var wkWebView = WKWebView()

    /// Used to choose between full club name (regular/iPad) and nickname (compact/iPhone) in the navigation title.
    @Environment(\.horizontalSizeClass) private var horSizeClass

    @ObservedObject private var settingsModel = SettingsViewModel.shared
    /// The text bound to the search field used to filter the (section) list of members
    @State private var searchText: String = ""
    @State private var isSearchPresented = false

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
        .searchable(text: $searchText,
                    isPresented: $isSearchPresented,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: String(localized: "Search prompt clubs",
                                   table: "PhotoClubHub.SwiftUI",
                                   bundle: Bundle.main,
                                   comment: """
                                            Field at top of Clubs page that allows the user to filter \
                                            the members based on a person's FullName or Expertise.
                                            """))
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
        .task { // hmmmm. Pretty obscure parts of Swift language added here by Claude Code
            let tip = TabNavigationTip()
            // Handle the case where TabNavigationTip was already invalidated before this task runs.
            if case .invalidated = tip.status {
                TabNavigationTip.isInvalidated = true
            }
            for await status in tip.statusUpdates {
                if case .invalidated = status {
                    TabNavigationTip.isInvalidated = true
                }
            }
        }
        .navigationTitle(String(localized: "Clubs",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Title of page showing member portfolios"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ReadmeButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { isSearchPresented = true } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
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

// MARK: - Previews

// Believe it or not, this preview works.

#Preview {
    NavigationStack {
        MemberPortfolioView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
