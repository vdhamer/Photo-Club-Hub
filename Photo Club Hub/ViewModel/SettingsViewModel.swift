//
//  SettingsViewModel.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/12/2021.
//

import CoreData             // for NSManagedObject
import Combine              // for AnyCancellable
import SemanticColorPicker  // for SemanticColor
import Photo_Club_Hub_Data  // for OrganizationTypeEnum

/// A view model that manages the user's preferences for filtering presentation preferences throughout the app.
///
/// `SettingsViewModel` is an `ObservableObject` that publishes a single `settings: SettingsStruct` value,
///  which holds all of the user's settings. Most are toggles.
///  Some of them build the Core Data predicates for members and organizations.
///
/// The view model is annotated with `@MainActor` because SwiftUI views both read and change `settings`,
/// and an `ObservableObject` must publish its changes on the main thread.
///
/// Persistence
/// - `settings` uses the `@Published(_:cancellableSet:)` initializer from the Data package. It loads the stored value
///   from `UserDefaults` at launch and saves every change. The subscription that does the saving is stored in the
///   static `cancellableSet`, so that it lives as long as the app does.
///
/// Usage
/// - Observe an instance of this view model from SwiftUI views and bind to the `settings` value.
/// - Read `settings.memberPredicate` to obtain a composed `NSPredicate` that reflects the current
///   set of toggles (e.g., current members, officers, former members, etc.).
@MainActor
class SettingsViewModel: ObservableObject {
    /// Shared singleton instance used by all views to ensure preference changes propagate everywhere.
    /// A view whose content depends on a setting holds it as `@ObservedObject var … = SettingsViewModel.shared`.
    /// `@ObservedObject` rather than `@StateObject`: the instance outlives every view, so no view owns it.
    /// Reading `SettingsViewModel.shared.settings` or `SettingsViewModel().settings` without observing it would give
    /// the values of that moment, and the view would not be redrawn when they change (#885).
    static let shared = SettingsViewModel()

    /// Holds the subscription that saves `settings` to `UserDefaults`. Without it, changes would no longer be saved.
    static var cancellableSet: Set<AnyCancellable> = []

    /// The app's persisted user preferences. Changes are published to update dependent views and
    /// are used to derive Core Data predicates for filtering content.
    @Published("settings", cancellableSet: &cancellableSet) // @Published only works on classes
    var settings: SettingsStruct = SettingsStruct.defaultValue
}

struct SettingsStruct { // order in which they are shown on Preferences page
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
    var preferenceForFeaturedImage: Bool

    var showClubs: Bool
    var showMuseums: Bool
    var showInactiveOrganizations: Bool // also impacts which clubs/museums the Clubs tab shows (#892)
    var highlightFotobondNL: Bool
    var highlightNonFotobondNL: Bool
    var highlightColor: SemanticColor // convert to Color using highlightColor.color

    static let defaultValue = SettingsStruct( // has to match order of declaration
        showCurrentMembers: true,
        showOfficers: true,
        showAspiringMembers: true,
        showHonoraryMembers: true,
        showFormerMembers: false, // was formerly true, but different clubs have different preferences
        showDeceasedMembers: false,
        showExternalCoaches: false,
        preferenceForFeaturedImage: true,

        showClubs: true,
        showMuseums: true,
        showInactiveOrganizations: false,
        highlightFotobondNL: false,
        highlightNonFotobondNL: false,
        highlightColor: .orange
    )

    /// The Core Data predicate for the Clubs tab's fetch request: which `MemberPortfolio`s are fetched, and thereby
    /// which clubs can get a section. The Search bar is not part of it: it filters the fetched portfolios afterwards,
    /// in Swift.
    ///
    /// A membership is shown if it matches at least one enabled member category (current, aspiring, officer, honorary,
    /// former, deceased, external coach). The categories overlap, but a fetch returns each membership only once.
    /// The result is then narrowed by the status of the membership's club: only active clubs by default,
    /// or every club except rejected ones while `showInactiveOrganizations` is on.
    ///
    /// `showClubs` and `showMuseums` play no part here: they only filter the Maps tab.
    ///
    /// Returns a bare `FALSEPREDICATE` when every member category is off.
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
        // Officers are current members with an extra responsibility.
        // A role flag can outlive the membership: the JSON keeps it when a member leaves or passes away (#609).
        if showOfficers {
            format = format.predicateOrAppend(suffix: """
                                                      ((isChairman = TRUE OR
                                                        isViceChairman = TRUE OR
                                                        isTreasurer = TRUE OR
                                                        isSecretary = TRUE OR
                                                        isAdmin = TRUE OR
                                                        isOther = TRUE) AND
                                                       isFormerMember = FALSE AND
                                                       photographer_.isDeceased = FALSE)
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

        // If all toggles are disabled, we don't show anything. This is returned without the status clause below,
        // because FilteredMemberPortfoliosView compares against FALSEPREDICATE to explain the empty list.
        guard format != "" else { return NSPredicate(format: "FALSEPREDICATE") }

        // Members of inactive clubs are hidden unless asked for, so that this tab agrees with the Maps tab.
        // Members of rejected clubs are never shown in any "normal" user interface (#891, #892).
        let statusPredicate = showInactiveOrganizations ? MemberPortfolio.inScopeOrganizationPredicate // not rejected
                                                        : MemberPortfolio.activeOrganizationPredicate // not inactive
        return NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: format, argumentArray: args),
                                                                  statusPredicate])
    }

    /// The Core Data predicate for the Maps tab's fetch request: which `Organization`s are fetched.
    /// The Search bar is not part of it: it filters the fetched organizations afterwards, in Swift.
    ///
    /// The same fetch supplies the pins on every card's map and the tab's header count, so whatever this excludes is
    /// gone from all of them, and Search can't find it either.
    ///
    /// An organization is shown if its type is enabled (`showClubs`, `showMuseums`) and its status passes:
    /// only active organizations by default, or every org except rejected ones while `showInactiveOrganizations` is on.
    ///
    /// Returns a bare `FALSEPREDICATE` when both types are off.
    var organizationPredicate: NSPredicate {
        var format = ""
        var args: [String] = [] // array from which to fetch the %@ values

        // Inactive organizations are hidden unless asked for. Rejected ones are never shown (#891, #892).
        let statusPredicate = showInactiveOrganizations ? Organization.inScopePredicate // not rejected
                                                        : Organization.activePredicate // not inactive
        let showAll = showClubs && showMuseums // for query optimization
        if showAll { return statusPredicate } // kind of a guard statement, but avoiding Not()

        if showClubs { // TemplateMin and TemplateMax are clubs like any other, so nothing is excluded here (#858)
            format = format.predicateOrAppend(suffix: "(organizationType_.organizationTypeName_ = %@)")
            args.append(OrganizationTypeEnum.club.rawValue)
        }

        if showMuseums {
            format = format.predicateOrAppend(suffix: "(organizationType_.organizationTypeName_ = %@)")
            args.append(OrganizationTypeEnum.museum.rawValue)
        }

        // If no OR conditions, return 0 Organizations. This is returned without the status clause,
        // because FilteredMapsView compares against FALSEPREDICATE to explain the empty list.
        guard format != "" else { return NSPredicate(format: "FALSEPREDICATE") }

        return NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: format, argumentArray: args),
                                                                  statusPredicate])
    }

    var photographerPredicate: NSPredicate {
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        return predicateAll // for now, we show all Photographers because filtering is done in View
    }

    /// A localized title for the Organizations screen derived from user preferences.
    /// The`organizationLabel` is also used when displaying the count of shown organizations (e.g. "35 museums").
    ///
    /// This method inspects this struct's own flags
    /// — `showClubs` and `showMuseums` — to decide which section(s)
    /// of organizations are visible, and returns an appropriate, localized string.
    ///
    /// Logic overview:
    /// - If clubs are shown and museums are hidden, returns "Clubs".
    /// - If only museums are shown, returns "Museums".
    /// - If nothing is shown, returns the neutral "Organizations".
    /// - In all mixed/combined cases (both clubs and museums visible), returns "Organizations".
    ///
    /// The returned value is localized using the "PhotoClubHub.SwiftUI" strings table.
    /// The returned value starts with a capital, so must be converted to lower case where needed.

    func organizationLabel() -> String {

        switch (showClubs, showMuseums) {
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

extension SettingsStruct: Equatable { }

extension SettingsStruct: Codable { // this extension was generated (and was needed for SemanticColor?)

    enum CodingKeys: String, CodingKey {
        case showCurrentMembers // Bool
        case showOfficers // Bool
        case showAspiringMembers // Bool
        case showHonoraryMembers // Bool
        case showFormerMembers // Bool
        case showDeceasedMembers // Bool
        case showExternalCoaches // Bool
        case showClubs // Bool
        case showMuseums // Bool
        case showInactiveOrganizations // Bool
        case highlightFotobondNL // Bool
        case highlightNonFotobondNL // Bool
        case highlightColor // SemanticColor
        case preferenceForFeaturedImage // Bool
    }

    /// Reads each field on its own, so that a missing or unreadable field falls back to its default
    /// without taking the other settings with it.
    ///
    /// The synthesized decoder is all-or-nothing: a stored blob that lacks a newly added key would fail to decode,
    /// and `Published+UserDefaults` then silently starts from `defaultValue`, resetting every setting (#892).
    /// The same happens to a `highlightColor` whose color id may no longer exists in SemanticColorPicker.
    /// Encoding stays synthesized. Assigning in an initializer doesn't trigger `didSet`, so the couplings
    /// between toggles (officers follow current members, deceased follow former) keep their stored values.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = SettingsStruct.defaultValue

        /// The stored value for `key`, or `defaultValue` if it is absent or can't be decoded as type `T`.
        func value<T: Decodable>(_ key: CodingKeys, _ defaultValue: T) -> T {
            (try? container.decodeIfPresent(T.self, forKey: key)) ?? defaultValue
        }

        // one line per stored property: the compiler rejects an initializer that leaves one out
        showCurrentMembers          = value(.showCurrentMembers, fallback.showCurrentMembers) // Clubs-related
        showOfficers                = value(.showOfficers, fallback.showOfficers)
        showAspiringMembers         = value(.showAspiringMembers, fallback.showAspiringMembers)
        showHonoraryMembers         = value(.showHonoraryMembers, fallback.showHonoraryMembers)
        showFormerMembers           = value(.showFormerMembers, fallback.showFormerMembers)
        showDeceasedMembers         = value(.showDeceasedMembers, fallback.showDeceasedMembers)
        showExternalCoaches         = value(.showExternalCoaches, fallback.showExternalCoaches)
        preferenceForFeaturedImage  = value(.preferenceForFeaturedImage, fallback.preferenceForFeaturedImage)

        showClubs                   = value(.showClubs, fallback.showClubs) // Maps-related
        showMuseums                 = value(.showMuseums, fallback.showMuseums)
        showInactiveOrganizations   = value(.showInactiveOrganizations, fallback.showInactiveOrganizations)
        highlightFotobondNL         = value(.highlightFotobondNL, fallback.highlightFotobondNL)
        highlightNonFotobondNL      = value(.highlightNonFotobondNL, fallback.highlightNonFotobondNL)
        highlightColor              = value(.highlightColor, fallback.highlightColor)
    }

}

extension String {
    func predicateOrAppend(suffix: String) -> String {
        guard self != "" else { return suffix }
        return self + " OR " + suffix
    }
}
