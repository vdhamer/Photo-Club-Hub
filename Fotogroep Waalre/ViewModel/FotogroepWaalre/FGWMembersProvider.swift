//
//  FGWMembersProvider.swift
//  FGWMembersProvider
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for NSManagedObjectContext
import RegexBuilder

class FGWMembersProvider { // WWDC21 Earthquakes also uses a Class here

    private static let photoClubID: (name: String, town: String) = ("Fotogroep Waalre", "Waalre")

//    /// A shared member provider for use within the main app bundle.
//    static let shared = FotogroepWaalreMembersProvider()

    init() {
        let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        // following is asynchronous, but not documented as such using async/await
        insertSomeHardcodedMemberData(fgwBackgroundContext: fgwBackgroundContext, commit: true)

        let urlString = getFileAsString(nameEncryptedFile: "PrivateMembersURL2.txt",
                                        nameUnencryptedFile: "PrivateMembersURL3.txt",
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
            print("About to use confidential version of Private member data file.")
            return secret
        } else {
            if let unsecret = readURLFromLocalFile(fileNameWithExtension: nameUnencryptedFile) {
                print("About to use non-confidential version of Private member data file.")
                return unsecret
            } else {
                print("Problem accessing either version of Private member data file.")
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
                print("Warning: \(error) File is not a text file.")
                return nil
            }
        } else {
            print("Cannot find file \(fileNameWithExtension) from bundle")
            return("File missing!")
        }
    }

    func loadPrivateMembersFromWebsite( backgroundContext: NSManagedObjectContext,
                                        privateMemberURL: URL,
                                        photoClubID: (name: String, town: String),
                                        commit: Bool ) async {

        print("Starting loadPrivateMembersFromWebsite() for Fotogroep Waalre in background")
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
                        print("Completed loadPrivateMembersFromWebsite() for Fotogroep Waalre in background")
                    }
                 } catch {
                    print("Could not save backgroundContext in FotogroepWaalreMembersProvider.init()")
                }
            }
        } else {
            DispatchQueue.main.async {
                print("loading from \(privateMemberURL) in loadPrivateMembersFromWebsite() failed")
                // print(results?.urlResponse)
                // if let errorcode: HTTPURLResponse = results?.urlResponse {
                    // print("\nHTTP status code: \(errorcode.statusCode)")
            }
        }
    }

    private func parseHTMLContent(backgroundContext: NSManagedObjectContext, htmlContent: String,
                                  photoClubID: (name: String, town: String)) {
        var targetState: HTMLPageLoadingState = .tableStart        // initial entry point on loop of states

        var personName = PersonName(fullName: "", givenName: "", familyName: "")
        var eMail = "", phoneNumber: String?, externalURL: String = ""
        var birthDate = toDate(from: "1/1/9999") // dummy value that is overwritten later

        let photoClub: PhotoClub = PhotoClub.findCreateUpdate(context: backgroundContext,
                                                              name: photoClubID.name, town: photoClubID.town)

        htmlContent.enumerateLines { (line, _ stop) -> Void in
            if line.contains(targetState.targetString()) {
                switch targetState {

                case .tableStart: break   // find start of table (only happens once)
                case .tableHeader: break  // find head of table (only happens once)
                case .rowStart: break     // find start of a table row defintion (may contain <td> or <th>)

                case .phoneNumber:                  // then find 3rd cell in row
                    phoneNumber = self.stripOffTagsFromPhone(taggedString: line) // store url after cleanup

                case .eMail:                      // then find 2nd cell in row
                    eMail = self.stripOffTagsFromEMail(taggedString: line) // store url after cleanup

                case .personName:       // find first cell in row
                    personName = self.extractName(taggedString: line)

                case .externalURL:
//                    let resultOld: String = self.stripOffTagsFromExternalURL_old(taggedString: line)
//                    let resultNew: String = self.stripOffTagsFromExternalURL(taggedString: line)
//                    if resultOld != resultNew {
//                        fatalError("stripOffTagsFromExternalURL mismatch:\n\(resultOld)\n\(resultNew)")
//                    }
                    externalURL = self.stripOffTagsFromExternalURL(taggedString: line) // url after cleanup

                case .birthDate:
                    birthDate = self.stripOffTagsFromBirthDateAndDecode(taggedString: line)

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

    func stripOffTagsFromPhone(taggedString: String) -> String? {
        let phoneCapture = Reference(Substring.self)
        let regex = Regex {
            "<td>"
            Capture(as: phoneCapture) {
                ChoiceOf {
                    One("[overleden]") // accepts <td>[overleden]</td> in NL
                    One("[deceased]") // accepts <td>[deceased]</td> in EN
                    OneOrMore { // accepts <td>12345678</td> or <td>06-12345678</td> or <td>+31 6 12345678</td>
                        CharacterClass(
                            .anyOf("-+ "),
                            ("0"..."9")
                        )
                    }
                    One("?") // signifies that phone number is unknown
                }
            }
            "</td>"
        }

        if let result = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            if result[phoneCapture] != "?" {
                return String(result[phoneCapture])
            } else {
                return nil
            }
        } else {
            let error = "Bad tel#: \(taggedString)"
            print(error)
            return error
        }
    }

    private func stripOffTagsFromEMail(taggedString: String) -> String {
        let emailCapture = Reference(Substring.self)
        let regex: Regex = Regex {
            "<td><a href=\"mailto:" // <td><a href="mailto:somebody@gmail.com">somebody@gmail.com</a></td>
            Capture(as: emailCapture) {
                OneOrMore(
                    CharacterClass(.anyOf("@").inverted) // somebody
                ) // stop before closing <@>
                "@"                                      // @
                OneOrMore(
                    CharacterClass(.anyOf(".").inverted) // gmail
                ) // stop before closing <.>
                "."                                      // .
                OneOrMore(
                    CharacterClass(.anyOf("\"").inverted) // com
                ) // stop before closing <">
            }
            "\">"
            Capture { // Capture(as:) doesn't really work here because .1 and .2 have same type
                OneOrMore(
                    CharacterClass(.anyOf("@").inverted) // somebody
                ) // stop before closing <@>
                "@"                                      // @
                OneOrMore(
                    CharacterClass(.anyOf(".").inverted) // gmail
                ) // stop before closing <.>
                "."                                      // .
                OneOrMore(
                    CharacterClass(.anyOf("<").inverted) // com
                )
            }
            "</a></td>"
        }

        if let result = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            if result[emailCapture] != result.2 {
                print("""
                      Warning: mismatched e-mail addresses\
                                  \(result[emailCapture])\
                                  \(result.2)
                      """)
            }
            return String(result[emailCapture])
        } else {
            let error = "Bad e-mail: \(taggedString)"
            print(error)
            return error
        }
    }

    private func stripOffTagsFromExternalURL_old(taggedString: String) -> String {
        // swiftlint:disable:next line_length
        // <td><a title="Ariejan van Twisk fotografie" href="http://www.ariejanvantwiskfotografie.nl" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td> // old Wordpress template: no URL available
        // <td><a title="" <="" a=""></a></td> // sometimes Wordpress does this if no URL available (bug in WP?)

        let REGEX: String = " href=\"([^\"]*)\""
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "" // backup in " href=..." not found
        }
    }

    private func stripOffTagsFromExternalURL(taggedString: String) -> String {
        // swiftlint:disable:next line_length
        // <td><a title="Ariejan van Twisk fotografie" href="http://www.ariejanvantwiskfotografie.nl" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td> // old Wordpress template: no URL available
        // <td><a title="" <="" a=""></a></td> // sometimes Wordpress does this if no URL available (bug in WP?)

        let REGEX: String = " href=\"([^\"]*)\""
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "" // backup in " href=..." not found
        }
    }

    private func stripOffTagsFromBirthDateAndDecode(taggedString: String) -> Date? {
        // <td>2022-05-26</td> is valid input

        let REGEX: String = "<td>(.*)</td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        guard result.count > 0 else {
            fatalError("Failed to decode data from \(taggedString) because RegEx didn't trigger")
        }

        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
                                          timeZone: TimeZone.autoupdatingCurrent)
        let birthDateString = result[0]
        let date = try? Date(birthDateString, strategy: strategy) // can be nil
        if date==nil && !birthDateString.isEmpty {
            print("Failed to decode data from \"\(result[0])\" because the date is not in ISO8601 format")
        }
        return date
    }

    private func isStillAlive(phone: String?) -> Bool {
        return phone != "[overleden]"
    }

    private func isCurrentMember(name: String, includeCandidates: Bool) -> Bool {
        let REGEX: String = ".* (\\(lid\\))"
        let result = name.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return true
        } else if !includeCandidates {
            return false
        } else {
            return isProspectiveMember(name: name)
        }
    }

    private func isMentor(name: String) -> Bool {
        let REGEX: String = ".* (\\(mentor\\))"
        let result = name.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return true
        } else {
            return false
        }
    }

    private func isProspectiveMember(name: String) -> Bool {
        let REGEX: String = ".* (\\(aspirantlid\\))"
        let result = name.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return true
        } else {
            return false
        }
    }

    private func generateInternalURL(using name: String) -> URL? {
        let     baseURL = "https://www.fotogroepwaalre.nl/fotos/"
        var tweakedName = name.replacingOccurrences(of: " ", with: "_")
        tweakedName = tweakedName.replacingOccurrences(of: "á", with: "a") // István_Nagy
        tweakedName = tweakedName.replacingOccurrences(of: "é", with: "e") // José_Daniëls
        tweakedName = tweakedName.replacingOccurrences(of: "ë", with: "e") // José_Daniëls and Henriëtte van Ekert
        tweakedName = tweakedName.replacingOccurrences(of: "ç", with: "c") // François_Hermans

        if tweakedName.contains("_(lid)") {
            let REGEX: String = "([^(]*)_\\(lid\\).*"
            tweakedName = tweakedName.capturedGroups(withRegex: REGEX)[0]
        } else if tweakedName.contains("_(aspirantlid)") {
            let REGEX: String = "([^(]*)_\\(aspirantlid\\).*"
            tweakedName = tweakedName.capturedGroups(withRegex: REGEX)[0]
        }
        return URL(string: baseURL + tweakedName + "/")
    }

    private func toDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: dateString)
    }

}
