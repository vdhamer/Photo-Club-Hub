//
//  PreferencesViewModel.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/12/2021.
//

import Foundation // for @Published and ObservableObject
import CoreData // for NSManagedObject
import Combine // for AnyCancellable
import SwiftUI // for Color

/// A view model that manages the user's preferences for filtering members throughout the app.
///
/// This type is an `ObservableObject` that publishes a single `PreferencesStruct` value, which
/// contains all toggleable options used to build Core Data predicates for members, photographers, and organizations.
///
/// The view model is annotated with `@MainActor` because it is observed by the UI
/// and its published state is consumed on the main thread. (whatever that means, this documentation was written by AI)
///
/// Persistence
/// - The `preferences` property uses a custom `@Published("preferences", cancellableSet:)` wrapper
///   that persists changes and restores values across launches. The static `cancellableSet` is kept
///   on the type so the app can retain Combine subscriptions associated with persistence.
///
/// Usage
/// - Observe an instance of this view model from SwiftUI views and bind to the `preferences` value.
/// - Read `preferences.memberPredicate` to obtain a composed `NSPredicate` that reflects the current
///   set of toggles (e.g., current members, officers, former members, etc.).
@MainActor
class PreferencesViewModel: ObservableObject {
    /// Stores Combine cancellables tied to persistence of the `preferences` property.
    static var cancellableSet: Set<AnyCancellable> = [] // not used yet: view has no OK/Cancel capabilities

    /// The app's persisted user preferences. Changes are published to update dependent views and
    /// are used to derive Core Data predicates for filtering content.
    @Published("preferences", cancellableSet: &cancellableSet)
    var preferences: PreferencesStruct = .defaultValue
}

// Custom Codable conformance is needed for PreferencesStruct because `highlightColor` does not conform to Codable.
// We encode highlightColor as an RGBA tuple using UIColor and decode it back into a SwiftUI Color.
struct PreferencesStruct { // order in which they are shown on Preferences page
    var showCurrentMembers: Bool {
        didSet {
            showOfficers = showCurrentMembers // officers are current members
            openCloseSound(openClose: showCurrentMembers ? .close : .open)
        }
    }
    var showOfficers: Bool
    var showAspiringMembers: Bool
    var showHonoraryMembers: Bool
    var showFormerMembers: Bool {
        didSet {
            showDeceasedMembers = showFormerMembers // deceased members are former members
            openCloseSound(openClose: showFormerMembers ? .close : .open)
        }
    }
    var showDeceasedMembers: Bool
    var showExternalCoaches: Bool

    var showClubs: Bool
    var showTestClubs: Bool
    var anyClubs: Bool { showClubs || showTestClubs } // convenience function
    var showMuseums: Bool
    var highlightFotobondNL: Bool
    var highlightNonFotobondNL: Bool
    var highlightColor: Color

    static let defaultValue = PreferencesStruct( // has to match order of declaration
        showCurrentMembers: true,
        showOfficers: true,
        showAspiringMembers: true,
        showHonoraryMembers: true,
        showFormerMembers: false, // was formerly true, but different clubs have different preferences
        showDeceasedMembers: false,
        showExternalCoaches: false,

        showClubs: true,
        showTestClubs: false,
        showMuseums: true,
        highlightFotobondNL: false,
        highlightNonFotobondNL: false,
        highlightColor: Color(.red)
    )

    var memberPredicate: NSPredicate {
        var format = ""
        let args: [NSManagedObject] = [] // array from which to fetch the %@ values

        // add members with requested special properties (duplicate members won't occur)
        if showCurrentMembers {
            format = format.predicateOrAppend(suffix: """
                                                      (photographer_.isDeceased = FALSE AND \
                                                       isFormerMember = FALSE AND \
                                                       isHonoraryMember = FALSE AND \
                                                       isProspectiveMember = FALSE AND \
                                                       isMentor = FALSE)
                                                      """)
        }
        if showAspiringMembers {
            format = format.predicateOrAppend(suffix: "(isProspectiveMember = TRUE)")
        }
        if showOfficers {
            format = format.predicateOrAppend(suffix: """
                                                      (isChairman = TRUE OR
                                                       isViceChairman = TRUE OR
                                                       isTreasurer = TRUE OR
                                                       isSecretary = TRUE OR
                                                       isAdmin = TRUE OR
                                                       isOther = TRUE)
                                                      """)
        }
        if showHonoraryMembers {
            format = format.predicateOrAppend(suffix: "(isHonoraryMember = TRUE)")
        }
        if showFormerMembers {
            format = format.predicateOrAppend(suffix: "(isFormerMember = TRUE AND isMentor = FALSE)")
        }
        if showDeceasedMembers {
            format = format.predicateOrAppend(suffix: "(photographer_.isDeceased = TRUE)")
        }
        if showExternalCoaches {
            format = format.predicateOrAppend(suffix: "(isMentor = TRUE)")
        }

        let predicate: NSPredicate
        if format != "" {
            predicate = NSPredicate(format: format, argumentArray: args)
        } else {
            let predicateNone = NSPredicate(format: "FALSEPREDICATE")
            predicate = predicateNone // if all toggles are disabled, we don't show anything
        }
        return predicate
    }

    var organizationPredicate: NSPredicate {
        var format = ""
        var args: [String] = [] // array from which to fetch the %@ values
        let showAllClubs: Bool = showClubs && showTestClubs // for query optimization

        let showAll = showAllClubs && showMuseums // for query oprimization
        if showAll { return NSPredicate(format: "TRUEPREDICATE") } // kind of a guard statement, but avoiding Not()

        if showAllClubs {

            format = format.predicateOrAppend(suffix: "(organizationType_.organizationTypeName_ = %@)")
            args.append(OrganizationTypeEnum.club.rawValue)

        } else {
            if showClubs {
                format = format.predicateOrAppend(suffix: "(organizationType_.organizationTypeName_ = %@) AND" +
                                                          " NOT (nickName_ CONTAINS[cd] %@)")
                args.append(OrganizationTypeEnum.club.rawValue)
                args.append("Xample")
            }

            if showTestClubs {
                format = format.predicateOrAppend(suffix: "(organizationType_.organizationTypeName_ = %@) AND" +
                                                          " (nickName_ CONTAINS[cd] %@)")
                args.append(OrganizationTypeEnum.club.rawValue)
                args.append("Xample") // clubs containing "Xample" anywhere in the name
            }
        }

        if showMuseums {
            format = format.predicateOrAppend(suffix: "(organizationType_.organizationTypeName_ = %@)")
            args.append(OrganizationTypeEnum.museum.rawValue)
        }

        let predicate: NSPredicate
        if format != "" {
            predicate = NSPredicate(format: format, argumentArray: args)
        } else {
            let predicateAll = NSPredicate(format: "FALSEPREDICATE") // if no OR conditions, return 0 Organizations
            predicate = predicateAll
        }
        return predicate
    }

    var photographerPredicate: NSPredicate {
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        return predicateAll // for now, we show all Photographers because filtering is done in View
    }

    /// A localized title for the Organizations screen derived from user preferences.
    /// The`organizationLabel` is also used when displaying the count of shown organizations (e.g. "35 museums").
    ///
    /// This computed property inspects the current `PreferencesViewModel().preferences` flags
    /// — `showClubs`, `showTestClubs`, and `showMuseums` — to decide which section(s)
    /// of organizations are visible, and returns an appropriate, localized string.
    ///
    /// Logic overview:
    /// - If clubs (including test clubs) are shown and museums are hidden, returns "Clubs".
    /// - If only museums are shown, returns "Museums".
    /// - If nothing is shown, returns the neutral "Organizations".
    /// - In all mixed/combined cases (both clubs and museums visible), returns "Organizations".
    ///
    /// The returned value is localized using the "PhotoClubHub.SwiftUI" strings table.
    /// The returned value starts with a capital, so must be converted to lower case where needed.

    func organizationLabel() -> String {

        switch (anyClubs, showMuseums) {
        case (true, false):
            return String(localized: "Clubs",
                          table: "PhotoClubHub.SwiftUI", comment: "Title of page with maps for Clubs")
        case (false, true):
            return String(localized: "Museums",
                          table: "PhotoClubHub.SwiftUI", comment: "Title of page with maps for Museums")
        case (false, false): // nothing to show, but let's call that "0 organizations"
            // swiftlint:disable:next no_fallthrough_only
            fallthrough
        case (true, true):
            return String(localized: "Organizations",
                          table: "PhotoClubHub.SwiftUI", comment: "Title of page with maps for Organizations")
        }
    }

}

extension String {
    func predicateOrAppend(suffix: String) -> String {
        guard self != "" else { return suffix }
        return self + " OR " + suffix
    }
}

extension PreferencesStruct: Codable { // this extension was generated entirely by ChatGPT
    enum CodingKeys: String, CodingKey {
        case showCurrentMembers
        case showOfficers
        case showAspiringMembers
        case showHonoraryMembers
        case showFormerMembers
        case showDeceasedMembers
        case showExternalCoaches
        case showClubs
        case showTestClubs
        case showMuseums
        case highlightFotobondNL
        case highlightNonFotobondNL
        // highlightColor handled separately
    }

    enum HighlightColorKeys: String, CodingKey {
        case red, green, blue, alpha
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        showCurrentMembers = try container.decode(Bool.self, forKey: .showCurrentMembers)
        showOfficers = try container.decode(Bool.self, forKey: .showOfficers)
        showAspiringMembers = try container.decode(Bool.self, forKey: .showAspiringMembers)
        showHonoraryMembers = try container.decode(Bool.self, forKey: .showHonoraryMembers)
        showFormerMembers = try container.decode(Bool.self, forKey: .showFormerMembers)
        showDeceasedMembers = try container.decode(Bool.self, forKey: .showDeceasedMembers)
        showExternalCoaches = try container.decode(Bool.self, forKey: .showExternalCoaches)

        showClubs = try container.decode(Bool.self, forKey: .showClubs)
        showTestClubs = try container.decode(Bool.self, forKey: .showTestClubs)
        showMuseums = try container.decode(Bool.self, forKey: .showMuseums)
        highlightFotobondNL = try container.decode(Bool.self, forKey: .highlightFotobondNL)
        highlightNonFotobondNL = try container.decode(Bool.self, forKey: .highlightNonFotobondNL)

        // Decode highlightColor
        if let colorContainer = try? decoder.container(keyedBy: HighlightColorKeys.self) {
            let red = try colorContainer.decode(Double.self, forKey: .red)
            let green = try colorContainer.decode(Double.self, forKey: .green)
            let blue = try colorContainer.decode(Double.self, forKey: .blue)
            let alpha = try colorContainer.decode(Double.self, forKey: .alpha)
            highlightColor = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        } else {
            highlightColor = .red // fallback default color
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(showCurrentMembers, forKey: .showCurrentMembers)
        try container.encode(showOfficers, forKey: .showOfficers)
        try container.encode(showAspiringMembers, forKey: .showAspiringMembers)
        try container.encode(showHonoraryMembers, forKey: .showHonoraryMembers)
        try container.encode(showFormerMembers, forKey: .showFormerMembers)
        try container.encode(showDeceasedMembers, forKey: .showDeceasedMembers)
        try container.encode(showExternalCoaches, forKey: .showExternalCoaches)

        try container.encode(showClubs, forKey: .showClubs)
        try container.encode(showTestClubs, forKey: .showTestClubs)
        try container.encode(showMuseums, forKey: .showMuseums)
        try container.encode(highlightFotobondNL, forKey: .highlightFotobondNL)
        try container.encode(highlightNonFotobondNL, forKey: .highlightNonFotobondNL)

        // Encode highlightColor as RGBA components via UIColor
        var colorContainer = encoder.container(keyedBy: HighlightColorKeys.self)
        let uiColor = UIColor(highlightColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        try colorContainer.encode(Double(red), forKey: .red)
        try colorContainer.encode(Double(green), forKey: .green)
        try colorContainer.encode(Double(blue), forKey: .blue)
        try colorContainer.encode(Double(alpha), forKey: .alpha)
    }
}
