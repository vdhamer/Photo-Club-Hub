//
//  FotogroepWaalreMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for NSManagedObjectContext
import RegexBuilder // for Regex struct

class FotogroepWaalreMembersProvider { // WWDC21 Earthquakes also uses a Class here

    static let photoClubWaalreIdPlus = OrganizationIdPlus(fullName: "Fotogroep Waalre",
                                                          town: "Waalre",
                                                          nickname: "fgWaalre")

    init(bgContext: NSManagedObjectContext) {
        // following is asynchronous, but not documented as such using async/await
        bgContext.perform { // done asynchronously by CoreData
            self.insertOnlineMemberData(bgContext: bgContext)
            do {
                if bgContext.hasChanges { // optimisation
                    try bgContext.save() // persist Fotogroep Waalre and its online member data
                    print("Sucess loading FG Waalre member data")
                }
            } catch {
                ifDebugFatalError("Error saving members of FG Waalre: \(error.localizedDescription)")
            }
        }
    }
}

extension FotogroepWaalreMembersProvider { // private utitity functions

    func isStillAlive(phone: String?) -> Bool {
        return phone != "[overleden]"
    }

    func isCurrentMember(name: String, includeProspectiveMembers: Bool) -> Bool {
        // "Guido Steger" -> false
        // "Bart van Stekelenburg (lid)" -> true
        // "Zoë Aspirant (aspirantlid)" -> depends on includeCandidates param
        // "Hans Zoete (mentor)" -> false
        let regex = Regex {
            ZeroOrMore(.any)
            OneOrMore(.horizontalWhitespace)
            Capture {
                ChoiceOf {
                    "(lid)" // NL
                    "(member)" // not via localization because input file can have different language setting than app
                }
            }
        }

        if (try? regex.wholeMatch(in: name)) != nil {
            return true // "Bart van Stekelenburg (lid)"
        } else if includeProspectiveMembers {
            return isProspectiveMember(name: name) // "Zoë Aspirant (aspirantlid)"
        }
        return false // "Guido Steger" and "Hans Zoete (mentor)" -> false
    }

    func isMentor(name: String) -> Bool {
        // "Guido Steger" -> false
        // "Bart van Stekelenburg (lid)" -> false
        // "Zoë Aspirant (aspirantlid)" -> false
        // "Hans Zoete (mentor)" -> true
        let regex = Regex {
            ZeroOrMore(.any)
            OneOrMore(.horizontalWhitespace)
            Capture {
                ChoiceOf {
                    "(mentor)" // NL
                    "(coach)" // EN
                }
            }
        }

        if (try? regex.wholeMatch(in: name)) != nil {
            return true
        } else {
            return false
        }
    }

    func isProspectiveMember(name: String) -> Bool {
        // "Bart van Stekelenburg (lid)" -> false
        // "Zoë Aspirant (aspirantlid)" -> true
        // "Guido Steger" -> false
        // "Hans Zoete (mentor)" -> false
        let regex = Regex {
            ZeroOrMore(.any)
            OneOrMore(.horizontalWhitespace)
            Capture {
                ChoiceOf {
                    "(aspirantlid)" // NL
                    "(aspiring)" // EN
                }
            }
        }

        if (try? regex.wholeMatch(in: name)) != nil {
            return true
        } else {
            return false
        }
    }

}
