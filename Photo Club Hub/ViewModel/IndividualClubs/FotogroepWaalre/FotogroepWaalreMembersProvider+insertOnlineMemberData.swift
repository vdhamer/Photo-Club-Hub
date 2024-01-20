//
//  FotogroepWaalreMembersProvider+insertOnlineMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/07/2023.
//

import CoreData
import RegexBuilder

extension FotogroepWaalreMembersProvider {

    func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread
        // can't rely on async (!) insertSomeHardcodedMemberData() to return managed photoClub object in time
        let clubWaalre = Organization.findCreateUpdate(
            context: bgContext, organizationTypeEum: .club,
            idPlus: FotogroepWaalreMembersProvider.photoClubWaalreIdPlus
        )

        let urlString = self.getFileAsString(nameEncryptedFile: "FGWPrivateMembersURL2.txt",
                                             nameUnencryptedFile: "FGWPrivateMembersURL3.txt",
                                             allowUseEncryptedFile: true, // set to false only for testing purposes
                                             organization: clubWaalre) // used for error messages only
        if let privateURL = URL(string: urlString) {
            clubWaalre.memberListURL = privateURL
            try? bgContext.save() // persist Fotogroep Waalre and its online member data

            self.loadPrivateMembersFromWebsite( backgroundContext: bgContext,
                                                privateMemberURL: privateURL,
                                                organization: clubWaalre,
                                                idPlus: FotogroepWaalreMembersProvider.photoClubWaalreIdPlus )
        } else {
            ifDebugFatalError("Could not convert \(urlString) to a URL.",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // In release mode, an incorrect URL causes the file loading to skip.
            // In release mode this is logged, but the app doesn't stop.
        }
    }

    fileprivate func getFileAsString(nameEncryptedFile: String,
                                     nameUnencryptedFile: String,
                                     allowUseEncryptedFile: Bool = true,
                                     organization: Organization) // used for error messages only
                                     -> String {
        let organizationTown = organization.fullNameTown
        if let secret = readURLFromLocalFile(fileNameWithExtension: nameEncryptedFile), allowUseEncryptedFile {
            ifDebugPrint("\(organizationTown): will use confidential version of Private member data file.")
            return secret
        } else {
            if let unsecret = readURLFromLocalFile(fileNameWithExtension: nameUnencryptedFile) {
                ifDebugPrint("\(organizationTown): will use non-confidential version of Private member data file.")
                return unsecret
            } else {
                print("\(organizationTown): ERROR - problem accessing either version of Private member data file.")
                return "Internal error: file \(nameUnencryptedFile) looks encrypted"
            }
        }
    }

    fileprivate func readURLFromLocalFile(fileNameWithExtension: String) -> String? {
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

    fileprivate func loadPrivateMembersFromWebsite( backgroundContext: NSManagedObjectContext,
                                                    privateMemberURL: URL,
                                                    organization: Organization,
                                                    idPlus: OrganizationIdPlus ) {

        ifDebugPrint("\(organization.fullNameTown): starting loadPrivateMembersFromWebsite() in background")

        // swiftlint:disable:next large_tuple
        var results: (utfContent: Data?, urlResponse: URLResponse?, error: (any Error)?)? = (nil, nil, nil)
        results = URLSession.shared.synchronousDataTask(from: privateMemberURL)

        if results != nil, results?.utfContent != nil {
            let htmlContent = String(data: results!.utfContent! as Data,
                                     encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseHTMLContent(backgroundContext: backgroundContext,
                             htmlContent: htmlContent,
                             idPlus: idPlus)
            do {
                if backgroundContext.hasChanges {
                    try backgroundContext.save() // persist member data for Fotogroep Waalre
                }
                ifDebugPrint("""
                             \(organization.fullNameTown): \
                             completed loadPrivateMembersFromWebsite() in background")
                             """)
            } catch {
                print("Fotogroep Waalre: ERROR - could not save backgroundContext to Core Data " +
                      "in loadPrivateMembersFromWebsite()")
            }

            // https://www.advancedswift.com/core-data-background-fetch-save-create/
            do { // fill or update or check refreshFirstImage()
                let fetchRequest: NSFetchRequest<MemberPortfolio>
                fetchRequest = MemberPortfolio.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: """
                                                             organization_.name_ = %@ && \
                                                             organization_.town_ = %@
                                                             """,
                             argumentArray: ["Fotogroep Waalre", "Waalre", "Jan"])
                let portfoliosInClub = try backgroundContext.fetch(fetchRequest)

                for portfolio in portfoliosInClub {
                    // PhotoClubHubApp.antiZombiePinningOfMemberPortfolios.insert(portfolio)
                    portfolio.refreshFirstImage()
                }
                try backgroundContext.save() // persist first images for Fotogroep Waalre
            } catch let error {
                fatalError(error.localizedDescription)
            }

        } else { // careful - we are running on a background thread (but print() is ok)
                print("Fotogroep Waalre: ERROR - loading from \(privateMemberURL) " +
                      "in loadPrivateMembersFromWebsite() failed")
        }
    }

    fileprivate func parseHTMLContent(backgroundContext: NSManagedObjectContext,
                                      htmlContent: String,
                                      idPlus: OrganizationIdPlus) {
        var targetState: HTMLPageLoadingState = .tableStart        // initial entry point on loop of states

        var personName = PersonName(fullNameWithParenthesizedRole: "", givenName: "", infixName: "", familyName: "")
        var eMail = "", phoneNumber: String?, externalURL: String = ""
        var birthDate = toDate(from: "1/1/9999") // dummy value that is overwritten later

        let organization: Organization = Organization.findCreateUpdate(context: backgroundContext,
                                                                       organizationTypeEum: .club,
                                                                       idPlus: idPlus)

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
                        context: backgroundContext,
                        personName: personName,
                        memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [
                            .deceased: !self.isStillAlive(phone: phoneNumber) ]),
                        phoneNumber: phoneNumber, eMail: eMail,
                        photographerWebsite: URL(string: externalURL),
                        bornDT: birthDate,
                        organization: organization
                    )

                    _ = MemberPortfolio.findCreateUpdate(
                        bgContext: backgroundContext, organization: organization, photographer: photographer,
                        memberRolesAndStatus: MemberRolesAndStatus(
                            role: [:],
                            stat: [
                                .former: !self.isCurrentMember(name: personName.fullNameWithParenthesizedRole,
                                                               includeProspectiveMembers: true),
                                .coach: self.isMentor(name: personName.fullNameWithParenthesizedRole),
                                .prospective: self.isProspectiveMember(name: personName.fullNameWithParenthesizedRole)
                            ]
                        ),
                          memberWebsite: self.generateInternalURL(using: personName.fullNameWithoutParenthesizedRole)
                    )

                }

                targetState = targetState.nextState()
            }
        }

    }

    fileprivate func generateInternalURL(using name: String) -> URL? { // only use standard ASCII A...Z,a...z in URLs
        // spaces are replaced by underscores:
        //      "Peter van den Hamer" -> "<baseURL>/Peter_van_den_Hamer"
        // cases with one or more replacements:
        //      "Henriëtte van Ekert" -> "<baseURL>/Henriette_van_Ekert"
        //      "José_Daniëls" -> "<baseURL>/Jose_Daniels"
        // case if there is a replacement needed, that is not defined yet
        //      "Ekin Özbiçer" -> "<baseURL>/Ekin_" // because app doesn't substitute the Ö yet
        let baseURL = "https://www.fotogroepwaalre.nl/fotos"
        var tweakedName = name.replacingOccurrences(of: " ", with: "_")
                              .replacingOccurrences(of: "á", with: "a") // affects István_Nagy
                              .replacingOccurrences(of: "ç", with: "c") // affects François_Hermans
                              .replacingOccurrences(of: "ë", with: "e") // affects Henriëtte_van_Ekert
                              .replacingOccurrences(of: "é", with: "e") // affects José_Daniëls

        let regex = Regex { // check if tweakedName only consists of standard ASCII characters
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
                ifDebugFatalError("Error in generateInternalURL()",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, the call to the website is skipped, and this logged. App doesn't stop.
                tweakedName = "Peter_van_den_Hamer" // fallback if all other options fail
            }
        }

        return URL(string: baseURL + "/" + tweakedName + "/") // final "/" not strictly needed (link works without)
    }

    fileprivate func toDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: dateString)
    }

}
