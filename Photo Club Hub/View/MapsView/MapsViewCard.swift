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

    /// Whether this card has been on screen long enough for its locked map to appear (#870). A fast scroll used to
    /// create a live map, loading its tiles, for every card that flew past, and memory could not keep up (#804).
    /// Now a locked map appears only after the card has been on screen for a short delay, and returns to a
    /// placeholder when the card leaves the screen. What appears is an image of the map, not a live map (#867).
    /// An unlocked map is always live and is never removed: that would destroy `MapsViewMap`'s `@State`, and with it
    /// the zoom/pan settings the user chose (#866).
    /// A locked map always shows the default view, so recreating it loses nothing.
    @State private var isDelayOver: Bool = false

    /// How long a card must be on screen before the image of its locked map appears.
    /// #870 started at ⅓ s, which felt slow on a slow scroll; 150 and 200 ms kept memory as low (iPhone, 1 Oct 2026).
    /// Images after a delay used the least memory of the approaches measured on the iPhone and both iPads; creating
    /// every live map at once, as before #870, crashed on iPadOS 26 at 4.4 GB (#867).
    static let delayMilliseconds = 175

    /// How long a map or its image takes to fade in over its placeholder, so its arrival after the delay seems
    /// calm, not late. Also used by `MapsViewScreenshot`, whose image arrives a moment after the delay.
    static let fadeInSeconds = 0.2

    private var showsLiveMap: Bool { // only an unlocked map is live
        isMapScrollLocked == false
    }

    private var showsSnapshot: Bool { // only asked when `showsLiveMap` is false, so the map is locked
        isDelayOver
    }

    var body: some View {
        VStack(alignment: .leading) {
            MapsViewTitle(organization: organization)
            MapsViewInfo(organization: organization, language: language, isMapScrollLocked: $isMapScrollLocked)
            if showsLiveMap {
                MapsViewMap(mapOrganization: organization,
                            fetchedOrganizations: fetchedOrganizations,
                            isMapScrollLocked: isMapScrollLocked)
                .transition(.opacity) // only animated where `isDelayOver` is set inside `withAnimation`, below
            } else if showsSnapshot {
                MapsViewScreenshot(mapOrganization: organization, fetchedOrganizations: fetchedOrganizations)
            } else {
                // Quiet on purpose: the card's own background shows through, and most placeholders are only seen
                // for an instant.
                Color.clear
                    .frame(minHeight: MapsViewMap.minHeight, idealHeight: MapsViewMap.idealHeight,
                           maxHeight: .infinity)
            }
            MapsViewRemark(organization: organization)
        } // VStack
        // Cancelled by SwiftUI when the card leaves the screen, so a card flung past never gets a map or its image.
        .task {
            guard !isDelayOver else { return }
            try? await Task.sleep(for: .milliseconds(Self.delayMilliseconds))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: Self.fadeInSeconds)) { isDelayOver = true }
        }
        .onAppear {
            // Screenshot pipeline only (#880): `-initialTab MapsMuseum3D` shows this one map unlocked. No-op otherwise.
            if MapsScreenshotPreset.startsUnlocked(organization) { isMapScrollLocked = false }
        }
        .onDisappear {
            // Otherwise, scrolling back during a fast fling would make every card seen before create its map at once.
            if isMapScrollLocked { isDelayOver = false }
        }
        .onChange(of: isMapScrollLocked) { _, isLocked in
            // Unlocking shows the live map at once, even over a placeholder. Mark the delay as over, or locking it
            // again would turn it back into a placeholder while it is on screen.
            if !isLocked { isDelayOver = true }
        }
    }
}

// MARK: - Previews

/// Shows one card the way `FilteredMapsView` does, for Fotogroep de Gender and its four neighbors
/// (see `MapsViewMapPreviews.seedOrganization`). A host view is needed because `FetchedResults` only comes from a
/// `@FetchRequest` inside a view. The map's image fades in over its placeholder after the delay.
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
        organization = MapsViewMapPreviews.seedOrganization(context: context)
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
