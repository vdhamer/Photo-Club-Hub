//
//  PhotoClubHubApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import CoreData // for NSManagedObjectContext
import TipKit   // for Tips.configure
import Photo_Club_Hub_Data // for many data-related functions

@main
struct PhotoClubHubApp: App {

    @Environment(\.scenePhase) var scenePhase

    init() {

        // Skip heavy app init when running under Xcode Previews to keep #Preview rendering alive.
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }

        // Automated screenshot functionality: stale-marker cleanup and handle -suppressTips CLI argument.
        ScreenshotReadiness.configureAtStartup()

        // Load persisted UI tip state (e.g. TabNavigationTip); without this call no tips are shown.
        // try? Tips.resetDatastore() /* used during manual testing only */
        try? Tips.configure([.displayFrequency(.daily)]) // show at most one tip per day

        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version numbers shown in iOS Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
        UserDefaults.standard.set(PhotoClubHubDataVersion.semver, forKey: "libraryVersion_preference")
        if Settings.manualDataLoading || Settings.dataResetPending {
            Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
        } else { // initialize some constant records for Language and OrganizationType (for stability)
            Language.initConstants(context: viewContext)
            OrganizationType.initConstants(context: viewContext)
        }

    }

    var body: some Scene {
        WindowGroup {
            RootView() // replaced the old inline #unavailable(iOS 26) PreludeView fork; see RootView.swift
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
        .onChange(of: scenePhase) { // zero-param closure is the iOS 17+ form; pre-iOS 17 the closure took (newValue)
            PersistenceController.shared.save() // Core Data will not automatically save on when scene -> background
        }
    }

}

extension PhotoClubHubApp {

    /// Runs one complete load pass: Level 0, then Level 1, then every Level 2 club loader concurrently.
    ///
    /// **Why Level 0 is awaited first.** This ordering is required, not stylistic. `Expertise` has a Core Data
    /// uniqueness constraint on `id_`. Level 0 creates expertises with `isSupported=true`, while Level 2's
    /// `findCreateUpdateUndefSupported()` creates them with the default `isSupported=false`. The contexts merge
    /// by property (see `makeBgContext`), so a Level 2 save racing Level 0 can leave the flag wrong.
    ///
    /// Level 1 is awaited too, but only for simplicity: the package allows Level 1 and Level 2 to overlap, so
    /// this call site is stricter than strictly necessary.
    ///
    /// **What the `withTaskGroup` barrier buys.** The group makes this function return only after every club
    /// loader has finished, which is what lets a caller treat "the load pass is over" as a fact. That matters
    /// in production, not merely under test:
    /// - `ClubLoadCoordinator.refresh(viewContext:)` awaits this pass and holds the pull-to-refresh spinner
    ///   up until it returns.
    /// - `ClubLoadCoordinator.enqueue(_:)` queues each pass behind its predecessor. Without the barrier this
    ///   function would return while loaders were still writing, and a queued refresh would delete Core Data
    ///   on top of an in-flight reload — precisely the race condition #802 removed.
    ///
    /// **When the barrier is actually observed.** On a launch with no pull-to-refresh, never. The startup pass
    /// is queued once from `RootView.onAppear`, has no predecessor to wait for, and `loadIfIdle()` discards
    /// its Task — so nothing watches it finish. The barrier starts earning its keep at the first refresh,
    /// when a second pass sits on the queue behind this one and must not delete Core Data on top of it.
    ///
    /// The app's own tests never call this function either: they drive `Level0JsonReader` and
    /// `Level2JsonReader` directly (see `LoadOrderIndependenceTest`). So the barrier is dormant in the common
    /// path and adds value from the first refresh onward — cheap insurance rather than dead code.
    static func loadLevels0To2() async { // swiftlint:disable:this function_body_length

        let isBeingTested = false // these are being loaded to get the data into Core Data, not for testing purposes
        let useOnlyInBundleFile = false

        // MARK: - Level 0

        // load list of Expertises and Languages from root.Level0.json file
        await Level0JsonReader.load(
            bgContext: makeBgContext(ctxName: "Level 0 loader"),
            isBeingTested: isBeingTested,
            useOnlyInBundleFile: useOnlyInBundleFile)

        // MARK: - Level 1

        // Load list of organizations from root_.Level1.json file (which Includes additional Level 1 child files).
        let fileName = "root_"
        await Level1JsonReader.load(
            bgContext: makeBgContext(ctxName: "Level 1 loader for \(fileName)"),
            fileName: fileName,
            isBeingTested: isBeingTested,
            useOnlyInBundleFile: useOnlyInBundleFile)

        // MARK: - Level 2

        // Load all clubs with Level 2 files concurrently within one serialized (withTaskGroup) load pass.
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await FotogroepDeGenderMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fgDeGender"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotogroepWaalreMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fgWaalre"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotoclubBellusImagoMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fcBellusImago"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotogroepOirschotMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fgOirschot"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await TemplateMinMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader TemplateMin"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await TemplateMaxMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader TemplateMax"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await Persoonlijk16MembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader Persoonlijk16"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotoclubEricameraMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fcEricamera"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotoclubDenDungenMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fcDenDungen"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotokringStMichielsgestelMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fkGestel"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await Persoonlijk03MembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader Persoonlijk03"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FotoclubVeghelMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fcVeghel"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FFCShot71MembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader ffcShot71"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
            group.addTask {
                await FEGGemertMembersProvider.load(
                    bgContext: makeBgContext(ctxName: "Level 2 loader fegGemert"),
                    isBeingTested: isBeingTested,
                    useOnlyInBundleFile: useOnlyInBundleFile)
            }
        }
    }

    static func makeBgContext(ctxName: String) -> NSManagedObjectContext {

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = ctxName
        if inDebugMode && Settings.errorOnCoreDataMerge {
            bgContext.mergePolicy = NSMergePolicy.error // to force detection of Core Data merge issues
        } else {
            bgContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // is .mergeByPropertyObjectTrump better?
        }
        bgContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
        bgContext.undoManager = nil // no undo manager (for speed)
        return bgContext

    }
}
