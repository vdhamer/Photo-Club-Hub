//
//  MapsViewCard.swift
//  Photo Club Hub
//
//  Created by Claude Code guided by Peter van den Hamer on 01/10/2026.
//

import SwiftUI // for View
import Photo_Club_Hub_Data // for types like Organization
import CoreData // for Organization and FetchedResults

/// Title, info line with the lock button, map and remark for one organization. Exists to own the lock.
///
/// The lock keeps a map inert, so a swipe over it scrolls the list; unlocking is a deliberate, temporary choice
/// to explore one map. A user should only see two states: locked with the club's default view, or unlocked with
/// a zoom/pan setting of their choice (#866).
/// So the lock is `@State` here, and `MapsViewMap` keeps its camera view in `@State` too:
/// both share this card's lifetime, survive scrolling off-screen together,
/// and reset together to "locked, default view".
/// A relaunch always starts locked. The map locks used to be persisted in Core Data (removed in Data 3.6.0),
/// which brought back unlocked maps whose view had reset, thus subtly violating the "two states" design.
@MainActor
struct MapsViewCard: View {

    let organization: Organization
    let language: Language?
    let fetchedOrganizations: FetchedResults<Organization>

    @State private var isMapScrollLocked: Bool = true // every map is initially locked

    /// Whether this card's locked map may be a live MapKit map yet (#870). A fast scroll used to create a live map,
    /// loading its tiles, for every card that flew past, and memory could not keep up (#804). Now a locked map
    /// becomes live only after the card has been on screen for a short delay, and returns to a placeholder when
    /// the card leaves the screen. An unlocked map is always live and is never removed: that would destroy
    /// `MapsViewMap`'s `@State`, and with it the view the user chose (#866). A locked map always shows the default
    /// view, so recreating it loses nothing.
    @State private var isMapLive: Bool = false

    @AppStorage(MapsTestMode.storageKey) private var testMode = MapsTestMode.defaultValue
    @AppStorage(MapsTestMode.delayStorageKey) private var delayMilliseconds = MapsTestMode.defaultDelayMilliseconds

    /// How long a map takes to fade in over its placeholder, so its arrival after the delay reads as calm, not late.
    private static let fadeInSeconds = 0.2

    private var showsLiveMap: Bool {
        testMode == .original || // all maps used to be live
                    isMapScrollLocked == false || // live if user unlocked it
                    isMapLive // or live because map was visible long enough
    }

    var body: some View {
        VStack(alignment: .leading) {
            MapsViewTitle(organization: organization)
            MapsViewInfo(organization: organization, language: language, isMapScrollLocked: $isMapScrollLocked)
            if showsLiveMap {
                MapsViewMap(filteredOrganization: organization,
                            fetchedOrganizations: fetchedOrganizations,
                            isMapScrollLocked: isMapScrollLocked)
                .transition(.opacity) // only animated where `isMapLive` is set inside `withAnimation`, below
            } else {
                // Quiet on purpose: the card's own background shows through, and most placeholders are only seen
                // for an instant.
                Color.clear
                    .frame(minHeight: MapsViewMap.minHeight, idealHeight: MapsViewMap.idealHeight,
                           maxHeight: .infinity)
            }
            MapsViewRemark(organization: organization)
        } // VStack
        // Cancelled by SwiftUI when the card leaves the screen, so a card flung past never gets a live map.
        // Restarted when the test mode changes, so switching modes also applies to the cards already on screen.
        .task(id: testMode) {
            guard testMode != .original, !isMapLive else { return } // only .original mode runs without a delay
            try? await Task.sleep(for: .milliseconds(delayMilliseconds))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: Self.fadeInSeconds)) { isMapLive = true }
        }
        .onDisappear {
            // Otherwise, scrolling back during a fast fling would make every card seen before create its map at once.
            if isMapScrollLocked { isMapLive = false }
        }
        .onChange(of: isMapScrollLocked) { _, isLocked in
            // Unlocking shows the live map at once, even over a placeholder. Mark it live, or locking it again
            // would turn it back into a placeholder while it is on screen.
            if !isLocked { isMapLive = true }
        }
    }
}

// MARK: - Previews

/// Shows one card the way `FilteredMapsView` does, for Fotogroep de Gender and its four neighbors
/// (see `MapsViewMapPreviews.seedOrganization`). A host view is needed because `FetchedResults` only comes from a
/// `@FetchRequest` inside a view. With the default test mode, the map fades in over its placeholder after the delay.
///
/// This preview actually works.
@MainActor
private struct MapsViewCardPreviewHost: View {

    let organization: Organization
    let language: Language?

    @FetchRequest(sortDescriptors: [SortDescriptor(\Organization.fullName_, order: .forward)])
    private var fetchedOrganizations: FetchedResults<Organization>

    init() {
        let context = MapsViewMapPreviews.persistenceController.container.viewContext
        organization = MapsViewMapPreviews.seedOrganization(in: context)
        language = Self.seedLocalizedAddress(for: organization, in: context)
    }

    /// Stores a fixed English town and country for `organization`, and returns that language.
    ///
    /// In the app these names come from reverse geocoding in `FilteredMapsView`, which the card doesn't run.
    /// Geocoding here wouldn't work anyway: `FilteredMapsView` saves the result to `PersistenceController.shared`,
    /// not to the preview store. Without this, the card shows the town as stored and "Country?".
    private static func seedLocalizedAddress(for organization: Organization,
                                             in context: NSManagedObjectContext) -> Language? {
        Language.initConstants(context: context) // the preview store has no languages of its own
        guard let language = Language.find(context: context, isoCode: "en") else { return nil }
        LocalizedAddress.findCreateUpdate(bgContext: context, // any context works; this one is the main one
                                          organization: organization,
                                          language: language,
                                          newLocalizedAddressFields: LocalizedAddressFields(
                                              localizedTown: "Eindhoven", localizedCountry: "Netherlands"),
                                          newCoordinates: organization.coordinates)
        try? context.save() // a failed save leaves the row in the context, which is all the card reads
        return language
    }

    var body: some View {
        MapsViewCard(organization: organization,
                     language: language,
                     fetchedOrganizations: fetchedOrganizations)
        .padding() // the same framing as each card in `FilteredMapsView`
        .border(Color(.darkGray), width: 0.5)
        .background(Color(.secondarySystemBackground))
    }
}

#Preview {
    MapsViewCardPreviewHost()
        .padding()
        .environment(\.managedObjectContext, MapsViewMapPreviews.persistenceController.container.viewContext)
}
