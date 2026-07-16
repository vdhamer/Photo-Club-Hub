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

    /// Member portfolios of the club targeted by `scrollPresetSectionID`. The scroll target is a
    /// `Section` keyed by `organization.fullNameTown`, and that section only exists once the club's
    /// members (Level 2) are imported — the `Organization` itself (Level 1) loads earlier and is
    /// therefore not a sufficient readiness signal.
    @FetchRequest(sortDescriptors: [],
                  predicate: NSPredicate(format: "organization_.fullName_ = %@", "Fotogroep de Gender"),
                  animation: .default)
    private var scrollPresetMembers: FetchedResults<MemberPortfolio>

    @State private var didApplyPreset = false

    /// The `-initialTab` launch argument (lowercased); drives the screenshot-pipeline presets (#776/#777).
    private var initialTabArgument: String? {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased()
    }

    // -initialTab Clubs ⇒ open scrolled to this section for the screenshot pipeline (#776).
    private var scrollPresetSectionID: String? {
        initialTabArgument == "clubs" ? "Fotogroep de Gender (Eindhoven)" : nil
    }

    // -initialTab PortfolioViaClubs ⇒ push this member's portfolio (member of the club fetched by
    // `scrollPresetMembers`) and jump its Juicebox-Pro gallery to this image (#777).
    private var portfolioPresetActive: Bool { initialTabArgument == "portfolioviaclubs" }
    private static let portfolioPresetMemberName = "Francien van Mil"
    private static let portfolioPresetImageIndex = 3 // 1-based, i.e. the third gallery image

    /// Applies the screenshot-pipeline preset (at most one is active per launch, keyed off `-initialTab`):
    /// - `Clubs`: scrolls the `List` to a target `Section` by its `.id()`. A `List` cannot use
    ///   `.scrollPosition(id:)` because that modifier resolves IDs against a `.scrollTargetLayout()`,
    ///   which only applies to a `LazyVStack`/`HStack` inside a `ScrollView` (see MapsView). `List`
    ///   manages its own layout, so we drive it with `ScrollViewReader`'s `scrollTo(_:anchor:)` instead.
    /// - `PortfolioViaClubs`: pushes the preset member's SinglePortfolioView via `selectedPortfolio`,
    ///   latching only once that member's record has been imported (club members arrive progressively).
    private func applyScrollPresetIfReady(proxy: ScrollViewProxy) {
        guard !didApplyPreset, !scrollPresetMembers.isEmpty else { return }
        if let target = scrollPresetSectionID {
            didApplyPreset = true
            Task { @MainActor in // wait one runloop tick so the List has laid out the freshly inserted section
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { proxy.scrollTo(target, anchor: .top) }
            }
        } else if portfolioPresetActive,
                  let member = scrollPresetMembers.first(where: {
                      $0.photographer.fullNameFirstLast == Self.portfolioPresetMemberName
                  }) {
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedPortfolio = member }
        }
    }

    var body: some View {
        ScrollViewReader { proxy in // proxy variant supports programmatic scrolling
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
            .animation(.default, value: searchText) // sections fade in/out as the Search text changes
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
                SinglePortfolioView(url: member.level3URL, webView: wkWebView,
                                    presetImageIndex: portfolioPresetActive ? Self.portfolioPresetImageIndex : nil)
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
            .onAppear { applyScrollPresetIfReady(proxy: proxy) }
            .onChange(of: scrollPresetMembers.count) { _, _ in applyScrollPresetIfReady(proxy: proxy) }
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
        } // ScrollViewReader
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
