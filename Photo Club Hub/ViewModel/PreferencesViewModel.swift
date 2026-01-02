//
//  PreferencesViewModel.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/12/2021.
//

import Foundation // for @Published and ObservableObject
import CoreData // for NSManagedObject
import Combine // for AnyCancellable

@MainActor
class PreferencesViewModel: ObservableObject {
    static var cancellableSet: Set<AnyCancellable> = [] // not used yet: view has no OK/Cancel capabilities

    @Published("preferences", cancellableSet: &cancellableSet)
    var preferences: PreferencesStruct = .defaultValue
}

struct PreferencesStruct: Codable { // order in which they are shown on Preferences page
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

    static let defaultValue = PreferencesStruct( // has to match order of declaration
        showCurrentMembers: true,
        showOfficers: true,
        showAspiringMembers: true,
        showHonoraryMembers: true,
        showFormerMembers: false, // used to be true
        showDeceasedMembers: false,
        showExternalCoaches: false
    )

    var memberPredicate: NSPredicate {
        let predicateNone = NSPredicate(format: "FALSEPREDICATE")
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
            predicate = predicateNone // if all toggles are disabled, we don't show anything
        }
        return predicate
    }

    var photographerPredicate: NSPredicate {
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        return predicateAll // for now, we show all Photographers because filtering is done in View
    }

    var organizationPredicate: NSPredicate {
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        return predicateAll // for now, we show all Photo Clubs
    }
}

extension String {
    func predicateOrAppend(suffix: String) -> String {
        guard self != "" else { return suffix }
        return self + " OR " + suffix
    }
}
