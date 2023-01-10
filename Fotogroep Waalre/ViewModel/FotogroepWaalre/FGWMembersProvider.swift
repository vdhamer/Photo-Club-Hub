//
//  FGWMembersProvider.swift
//  FGWMembersProvider
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for NSManagedObjectContext
import RegexBuilder

class FGWMembersProvider { // WWDC21 Earthquakes also uses a Class here

    private static let photoClubID: (name: String, shortName: String, town: String) =
                                    ("Fotogroep Waalre", "FGWaalre", "Waalre")

//    /// A shared member provider for use within the main app bundle.
//    static let shared = FotogroepWaalreMembersProvider()

    init() {
        let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        // following is asynchronous, but not documented as such using async/await
        insertSomeHardcodedMemberData(fgwBackgroundContext: fgwBackgroundContext, commit: true)

        let urlString = getFileAsString(nameEncryptedFile: "FGWPrivateMembersURL2.txt",
                                        nameUnencryptedFile: "FGWPrivateMembersURL3.txt",
                                        okToUseEncryptedFile: true) // false forces use of PrivateMembersURL3.txt
        if let privateURL = URL(string: urlString) {
            Task {
                await loadPrivateMembersFromWebsite( backgroundContext: fgwBackgroundContext,
                                                     privateMemberURL: privateURL,
                                                     photoClubID: FGWMembersProvider.photoClubID,
                                                     commit: true
                )
            }
        } else {
            fatalError("Could not convert \(urlString) to a URL.")
        }

    }

    private func getFileAsString(nameEncryptedFile: String,
                                 nameUnencryptedFile: String,
                                 okToUseEncryptedFile: Bool = true) -> String {
        if let secret = readURLFromLocalFile(fileNameWithExtension: nameEncryptedFile), okToUseEncryptedFile {
            print("Fotogroep Waalre: will use confidential version of Private member data file.")
            return secret
        } else {
            if let unsecret = readURLFromLocalFile(fileNameWithExtension: nameUnencryptedFile) {
                print("Fotogroep Waalre: will use non-confidential version of Private member data file.")
                return unsecret
            } else {
                print("Fotogroep Waalre: ERROR - roblem accessing either version of Private member data file.")
                return "Internal error: file \(nameUnencryptedFile) looks encrypted"
            }
        }
    }

    private func readURLFromLocalFile(fileNameWithExtension: String) -> String? {
        let fileName = fileNameWithExtension.fileName()
        let fileExtension = fileNameWithExtension.fileExtension()
        if let filepath = Bundle.main.path(forResource: fileName, ofType: fileExtension) {
            do {
                let firstLine = try String(contentsOfFile: filepath).components(separatedBy: "\n")[0]
                return firstLine // encypted version starts with hex 00 47 49 54 43 52 59 50 54 00 and is not a String
            } catch {
                print("Fotogroep Waalre: ERROR - \(error) File is not a text file.")
                return nil
            }
        } else {
            print("Fotogroep Waalre: ERROR - cannot find file \(fileNameWithExtension) from bundle")
            return("File missing!")
        }
    }

    func loadPrivateMembersFromWebsite( backgroundContext: NSManagedObjectContext,
                                        privateMemberURL: URL,
                                        photoClubID: (name: String, shortName: String, town: String),
                                        commit: Bool ) async {

        print("Fotogroep Waalre: starting loadPrivateMembersFromWebsite() in background")
        var results: (utfContent: Data?, urlResponse: URLResponse?)? = (nil, nil)
        results = try? await URLSession.shared.data(from: privateMemberURL)
        if results != nil, results?.utfContent != nil {
            let htmlContent = String(data: results!.utfContent! as Data,
                                     encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseHTMLContent(backgroundContext: backgroundContext, htmlContent: htmlContent, photoClubID: photoClubID)
            if commit {
                do {
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                        print("Fotogroep Waalre: completed loadPrivateMembersFromWebsite()")
                    }
                 } catch {
                    print("Fotogroep Waalre: ERROR - could not save backgroundContext to Core Data " +
                          "in loadPrivateMembersFromWebsite()")
                }
            }
        } else { // careful - we are likely running on a background thread (but print() is ok)
                print("Fotogroep Waalre: ERROR - loading from \(privateMemberURL) " +
                      "in loadPrivateMembersFromWebsite() failed")
        }
    }

    private func parseHTMLContent(backgroundContext: NSManagedObjectContext, htmlContent: String,
                                  photoClubID: (name: String, shortName: String, town: String)) {
        var targetState: HTMLPageLoadingState = .tableStart        // initial entry point on loop of states

        var personName = PersonName(fullName: "", givenName: "", familyName: "")
        var eMail = "", phoneNumber: String?, externalURL: String = ""
        var birthDate = toDate(from: "1/1/9999") // dummy value that is overwritten later

        let photoClub: PhotoClub = PhotoClub.findCreateUpdate(context: backgroundContext,
                                                              name: photoClubID.name,
                                                              shortName: photoClubID.shortName,
                                                              town: photoClubID.town)

        htmlContent.enumerateLines { (line, _ stop) -> Void in
            if line.contains(targetState.targetString()) {
                switch targetState {

                case .tableStart: break   // find start of table (only happens once)
                case .tableHeader: break  // find head of table (only happens once)
                case .rowStart: break     // find start of a table row defintion (may contain <td> or <th>)

                case .personName:       // find first cell in row
                    personName = self.extractName(taggedString: line)

                case .phoneNumber:                  // then find 3rd cell in row
                    phoneNumber = self.extractPhone(taggedString: line) // store url after cleanup

                case .eMail:                      // then find 2nd cell in row
                    eMail = self.extractEMail(taggedString: line) // store url after cleanup

                case .externalURL:
                    externalURL = self.extractExternalURL(taggedString: line) // url after cleanup

                case .birthDate:
                    birthDate = self.extractBirthDate(taggedString: line)

                    let photographer = Photographer.findCreateUpdate(
                        context: backgroundContext, givenName: personName.givenName, familyName: personName.familyName,
                        memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [
                            .deceased: !self.isStillAlive(phone: phoneNumber) ]),
                        phoneNumber: phoneNumber, eMail: eMail,
                        photographerWebsite: URL(string: externalURL), bornDT: birthDate
                    )

                    _ = MemberPortfolio.findCreateUpdate(
                        context: backgroundContext, photoClub: photoClub, photographer: photographer,
                        memberRolesAndStatus: MemberRolesAndStatus(
                            role: [:],
                            stat: [
                                .former: !self.isCurrentMember(name: personName.fullName, includeCandidates: true),
                                .coach: self.isMentor(name: personName.fullName),
                                .prospective: self.isProspectiveMember(name: personName.fullName)
                            ]
                        ),
                        memberWebsite: self.generateInternalURL(
                            using: "\(personName.givenName) \(personName.familyName)"
                        )
                    )

                }

                targetState = targetState.nextState()
            }
        }

    }
}

extension FGWMembersProvider { // private utitity functions

    private func isStillAlive(phone: String?) -> Bool {
        return phone != "[overleden]"
    }

    private func isCurrentMember(name: String, includeCandidates: Bool) -> Bool {
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
            return true
        } else if !includeCandidates {
            return false
        } else {
            return isProspectiveMember(name: name)
        }
    }

    private func isMentor(name: String) -> Bool {
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

    private func isProspectiveMember(name: String) -> Bool {
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

    private func generateInternalURL(using name: String) -> URL? { // for URLs we want basic latin alphabet
        // "Peter van den Hamer" -> "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer"
        // "Henriëtte van Ekert" -> "https://www.fotogroepwaalre.nl/fotos/Henriette_van_Ekert"
        // "José_Daniëls" -> "https://www.fotogroepwaalre.nl/fotos/Jose_Daniels"
        // "Ekin Özbiçer" -> "https://www.fotogroepwaalre.nl/fotos/Ekin_" // app doesn't substitute the Ö yet
        let baseURL = "https://www.fotogroepwaalre.nl/fotos/"
        var tweakedName = name.replacingOccurrences(of: " ", with: "_")
        tweakedName = tweakedName.replacingOccurrences(of: "á", with: "a") // István_Nagy
        tweakedName = tweakedName.replacingOccurrences(of: "é", with: "e") // José_Daniëls
        tweakedName = tweakedName.replacingOccurrences(of: "ë", with: "e") // José_Daniëls and Henriëtte_van_Ekert
        tweakedName = tweakedName.replacingOccurrences(of: "ç", with: "c") // François_Hermans

        let regex = Regex { // check if tweakedName consists of only clean ASCII characters
            Capture {
                OneOrMore {
                    CharacterClass(
                        .anyOf("_"),
                        ("a"..."z"),
                        ("A"..."Z")
                    )
                }
            }
        }

        if (try? regex.wholeMatch(in: tweakedName)) == nil {
            print("Error: please add special chars of <\(tweakedName)> to generateInternalURL()")
        } else {
            if let match = (try? regex.firstMatch(in: tweakedName)) {
                let (_, first) = match.output
                tweakedName = String(first) // shorten name up to first weird character
            } else {
                fatalError("Error in generateInternalURL()")
            }
        }

        return URL(string: baseURL + tweakedName + "/") // "/" not strictly needed (link works without)
    }

    private func toDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: dateString)
    }

}
