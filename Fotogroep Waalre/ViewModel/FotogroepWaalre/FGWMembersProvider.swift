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

                case .personName:       // find first cell in row
                    personName = self.extractName(taggedString: line)

                case .phoneNumber:                  // then find 3rd cell in row
                    phoneNumber = self.extractPhone(taggedString: line) // store url after cleanup

                case .eMail:                      // then find 2nd cell in row
                    eMail = self.extractEMail(taggedString: line) // store url after cleanup

                case .externalURL:
                    externalURL = self.extractExternalURL(taggedString: line) // url after cleanup

                case .birthDate:
                    let resultOld: Date? = self.extractBirthDate_old(taggedString: line)
                    let resultNew: Date? = self.extractBirthDate(taggedString: line)
                    if resultOld != resultNew {
                        fatalError("""
                                   extractExternalURL mismatch:
                                   \(String(describing: resultOld))
                                   \(String(describing: resultNew))
                                   """)
                    }
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
