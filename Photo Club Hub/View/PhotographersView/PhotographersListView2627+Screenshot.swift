//
//  PhotographersListView2627+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import SwiftUI // for Transaction, withTransaction

// Screenshot pipeline only (#776/#777) — no role in normal app use.
// Kept out of PhotographersListView2627.swift so the mainstream code stays uncluttered. The
// counterpart stored properties (`photographers`, `didApplyPreset`, `scrollPositionID`) must
// remain in PhotographersListView2627 itself because property wrappers cannot be declared in
// extensions. The pre-iOS-26 sibling (PhotographersListView1718) deliberately has no
// equivalent: capture-screenshots.sh does not support iOS 17/18 simulators.
@available(iOS 26.0, *)
extension PhotographersListView2627 {

    // -initialTab People ⇒ open scrolled to this photographer's card ("Mil, Ad van") anchored
    // at the top, so the next card ("Mil, Francien van") peeks in below it (#776). Nil in normal use.
    var scrollPresetPhotographerName: String? {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased() == "people" ? "Ad van Mil" : nil
//            ? "Edjoe Osinski" : nil
    }

    // The card that peeks in just below the scroll-preset target (#776); its images are also
    // prefetched so both visible cards are fully rendered when the screenshot is taken.
    private static let secondVisiblePhotographerName = "Francien van Mil"

    // Prefetch timeout: give up and signal readiness even if images are still in flight,
    // so the script never hangs on a slow image host. 20 s is generous; cache hits return
    // immediately and the script's own READY_TIMEOUT (60 s) is the hard ceiling.
    private static let thumbnailPrefetchTimeout: Duration = .seconds(20)

    // Debounce constants for waiting until all club level-2 loaders have finished saving.
    // Because clubs load concurrently, the first save can trigger the guard while others
    // are still in flight. We poll until both photographers' membership counts are stable
    // for membershipStabilityRequired consecutive checks before collecting image URLs (#776).
    private static let membershipStabilityCheckInterval: Duration = .milliseconds(500)
    private static let membershipStabilityRequired = 4   // 2 s of no change in counts or featuredImages
    // Hard ceiling. Raised from 20 (10 s) because the gate now also waits for every membership's
    // featuredImage, and slow clubs (Fotogroep de Gender) fetch a JuiceBox config.xml per member
    // serially before their single save merges into the view context (#776).
    private static let membershipStabilityMaxChecks = 60 // 30 s hard ceiling

    // -initialTab PortfolioViaPeople ⇒ push the shared preset member's portfolio (#777); the
    // People-tab twin of MemberPortfolioView's PortfolioViaClubs, producing a near-identical capture.
    var portfolioPresetActive: Bool {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased() == "portfolioviapeople"
    }

    /// Applies the screenshot-pipeline preset (at most one is active per launch, keyed off `-initialTab`):
    /// - `People`: one-shot scroll, retried from `.onAppear`, `photographers.count` changes, and
    ///   `memberPortfolios.count` changes until the target photographer AND at least one of their
    ///   membership's `featuredImage` URLs have been imported (level-1 + level-2 JSON both done).
    /// - `PortfolioViaPeople`: pushes the preset member's SinglePortfolioView via `selectedPortfolio`,
    ///   latching only once her de Gender membership record has been imported.
    func applyScrollPresetIfReady() {
        guard !didApplyPreset else { return }
        if let target = scrollPresetPhotographerName,
           let photographer = photographers.first(where: { $0.fullNameFirstLast == target }),
           photographer.memberships.contains(where: { $0.featuredImage != nil }) {
            // Only latch when at least one membership has a featuredImage URL, so
            // signalWhenThumbnailsReady has real URLs to prefetch. Without this guard the
            // preset could fire when the Photographer record first arrives (level-1 JSON)
            // before any MemberPortfolio records exist and before debouncing is meaningful.
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { scrollPositionID = photographer.id }
            signalWhenThumbnailsReady(for: photographer) // #776: tells capture script to stop waiting
        } else if portfolioPresetActive,
                  let member = photographers
                      .first(where: { $0.fullNameFirstLast == ScreenshotReadiness.portfolioPresetMemberName })?
                      .memberships
                      .first(where: { $0.organization.fullName == ScreenshotReadiness.portfolioPresetClubName }) {
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedPortfolio = member }
        }
    }

    // Waits for the membership sets of both visible photographers to stop growing
    // (debounce), then prefetches their thumbnail images into URLCache. Signals readiness
    // once all images are cached, or after thumbnailPrefetchTimeout — whichever comes first.
    //
    // The debounce is necessary because level-2 JSON loaders for different clubs run
    // concurrently: the first club to save triggers the guard in applyScrollPresetIfReady()
    // while other clubs' MemberPortfolio records are still in flight. Without debouncing,
    // signalReady fires before those records appear, and the screenshot captures their
    // thumbnails as orange question marks (member.featuredImage == nil) (#776).
    private func signalWhenThumbnailsReady(for primaryPhotographer: Photographer) {
        let secondPhotographer = photographers.first(where: {
            $0.fullNameFirstLast == Self.secondVisiblePhotographerName
        })

        Task { @MainActor in
            // Poll until BOTH conditions hold for membershipStabilityRequired consecutive checks:
            //   (1) both photographers' membership counts are unchanged, AND
            //   (2) every membership of both photographers has a non-nil featuredImage.
            //
            // Count stability alone is insufficient (#776): clubs load concurrently and some
            // (e.g. Fotogroep de Gender) set featuredImage *only* via refreshFirstImage()'s slow
            // JuiceBox config.xml fetch, which is done inside that club's single bgContext.save().
            // A photographer can reach a stable membership count while a slow club's row is still
            // absent, or present with a nil featuredImage — either way the thumbnail renders as an
            // orange question mark. Gating on featuredImage completeness closes that race; the
            // secondary card (Francien van Mil) is de-Gender-only, so it depends on this entirely.
            var prevPrimary = -1
            var prevSecond  = -1
            var stableChecks = 0

            func allFeaturedImagesPresent() -> Bool {
                for photographer in [primaryPhotographer, secondPhotographer].compactMap({ $0 }) {
                    let memberships = photographer.memberships
                    if memberships.isEmpty { return false }
                    if memberships.contains(where: { $0.featuredImage == nil }) { return false }
                }
                return true
            }

            for _ in 0 ..< Self.membershipStabilityMaxChecks {
                let currentPrimary = primaryPhotographer.memberships.count
                let currentSecond  = secondPhotographer?.memberships.count ?? 0
                let countsStable = currentPrimary == prevPrimary && currentSecond == prevSecond
                if countsStable && allFeaturedImagesPresent() {
                    stableChecks += 1
                    if stableChecks >= Self.membershipStabilityRequired { break }
                } else {
                    prevPrimary  = currentPrimary
                    prevSecond   = currentSecond
                    stableChecks = 0
                }
                try? await Task.sleep(for: Self.membershipStabilityCheckInterval)
            }

            // Collect image URLs now that all memberships have settled.
            var urls = Set<URL>()
            for photographer in [primaryPhotographer, secondPhotographer].compactMap({ $0 }) {
                if let url = photographer.photographerImage { urls.insert(url) }
                for membership in photographer.memberships {
                    if let url = membership.featuredImage { urls.insert(url) }
                }
            }
            let urlArray = Array(urls)

            // Race: all prefetches complete vs. timeout — whichever comes first.
            await withTaskGroup(of: Void.self) { outer in
                outer.addTask {
                    await withTaskGroup(of: Void.self) { inner in
                        for url in urlArray {
                            inner.addTask { _ = try? await URLSession.shared.data(from: url) }
                        }
                    }
                }
                outer.addTask { try? await Task.sleep(for: Self.thumbnailPrefetchTimeout) }
                _ = await outer.next() // first to finish wins (images done OR timeout)
                outer.cancelAll()
            }

            // Let SwiftUI commit any pending @ObservedObject-driven re-render before signaling.
            // The prefetch above usually returns instantly from URLCache (refreshFirstImage() just
            // downloaded these), so without this flush signalReady can fire in the same runloop
            // region as the last CoreData merge — before the render pass that replaces the
            // question-mark placeholder with the real thumbnail has actually drawn (#776).
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(250))

            ScreenshotReadiness.signalReady(for: "People")
        }
    }

}
