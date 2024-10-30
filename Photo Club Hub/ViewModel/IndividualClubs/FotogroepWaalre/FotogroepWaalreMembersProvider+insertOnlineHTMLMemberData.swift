//
//  FotogroepWaalreMembersProvider+insertOnlineHTMLMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/07/2023.
//

import CoreData
import RegexBuilder

extension FotogroepWaalreMembersProvider {

    public static let baseURL = "http://www.vdHamer.com/fgWaalre/"
    fileprivate static let url = "http://www.vdhamer.com/fgwaalre_level2/?ppt=f13a433cf52df1318ca04ca739867054"

    func insertOnlineHTMLMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread
        // can't rely on async (!) insertSomeHardcodedMemberData() to return managed photoClub object in time
        let clubWaalre = Organization.findCreateUpdate(
            context: bgContext,
            organizationTypeEnum: .club,
            idPlus: FotogroepWaalreMembersProvider.photoClubWaalreIdPlus,
            optionalFields: OrganizationOptionalFields() // empty
        )

        if let url = URL(string: FotogroepWaalreMembersProvider.url) {
            clubWaalre.level2URL = url
            self.loadPrivateMembersFromWebsite( bgContext: bgContext,
                                                privateMemberURL: url,
                                                organization: clubWaalre,
                                                idPlus: FotogroepWaalreMembersProvider.photoClubWaalreIdPlus)
        } else {
            ifDebugFatalError("Could not convert string to a URL.",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // In release mode, an incorrect URL causes the file loading to skip.
            // In release mode this is logged, but the app doesn't stop.
        }
    }

    fileprivate func loadPrivateMembersFromWebsite(bgContext: NSManagedObjectContext,
                                                   privateMemberURL: URL,
                                                   organization: Organization,
                                                   idPlus: OrganizationIdPlus) {

        ifDebugPrint("\(organization.fullNameTown): starting loadPrivateMembersFromWebsite() in background")

        // swiftlint:disable:next large_tuple
        var results: (utfContent: Data?, urlResponse: URLResponse?, error: (any Error)?)? = (nil, nil, nil)
        results = URLSession.shared.synchronousDataTask(from: privateMemberURL)

        if results != nil, results?.utfContent != nil {
            let htmlContent = String(data: results!.utfContent! as Data,
                                     encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseHTMLContent(bgContext: bgContext,
                             htmlContent: htmlContent,
                             idPlus: idPlus)

            // If we would commit here using ManagedObjectContext.save(), this would lead to a commit
            // of a member without a valid image. That can show up on the very first loading of Level 2 data.

            // https://www.advancedswift.com/core-data-background-fetch-save-create/
            do { // fill or update or check refreshFirstImage()
                let fetchRequest: NSFetchRequest<MemberPortfolio>
                fetchRequest = MemberPortfolio.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: """
                                                             organization_.fullName_ = %@ && \
                                                             organization_.town_ = %@
                                                             """,
                             argumentArray: ["Fotogroep Waalre", "Waalre"])
                let portfoliosInClub = try bgContext.fetch(fetchRequest)

                for portfolio in portfoliosInClub {
                    portfolio.refreshFirstImage()
                }
                try bgContext.save() // persist first images for Fotogroep Waalre
            } catch let error {
                fatalError(error.localizedDescription)
            }

        } else { // careful - we are running on a background thread (but print() is ok)
                print("Fotogroep Waalre: ERROR - loading from \(privateMemberURL) " +
                      "in loadPrivateMembersFromWebsite() failed")
        }
    }

    fileprivate func parseHTMLContent(bgContext: NSManagedObjectContext,
                                      htmlContent: String,
                                      idPlus: OrganizationIdPlus) {
        var targetState: HTMLPageLoadingState = .tableStart        // initial entry point on loop of states

        var personName = PersonName(fullNameWithParenthesizedRole: "", givenName: "", infixName: "", familyName: "")
        var eMail = "", phoneNumber: String?, externalURL: String = ""
        var bornDT = toDate(from: "1/1/9999") // dummy value that is overwritten later

        let organization: Organization = Organization.findCreateUpdate(
            context: bgContext, organizationTypeEnum: .club, idPlus: idPlus,
            optionalFields: OrganizationOptionalFields() // empty
        )

        htmlContent.enumerateLines { (line, _ stop) in
            if line.contains(targetState.targetString()) {
                switch targetState {

                case .tableStart: break   // find start of table (only happens once)
                case .tableHeader: break  // find head of table (only happens once)
                case .rowStart: break     // find start of a table row defintion (may contain <td> or <th>)

                case .personName:         // find first cell in row
                    personName = self.extractName(taggedString: line)

                case .phoneNumber:        // then find 3rd cell in row
                    phoneNumber = self.extractPhone(taggedString: line) // store url after cleanup

                case .eMail:              // then find 2nd cell in row
                    eMail = self.extractEMail(taggedString: line) // store url after cleanup

                case .externalURL:
                    externalURL = self.extractPhotographerWebsite(taggedString: line) // url after cleanup

                case .birthDate:
                    bornDT = self.extractBirthDate(taggedString: line)

                    self.addMember(bgContext: bgContext,
                                   organization: organization, personName: personName,
                                   optionalFields: PhotographerOptionalFields(
                                        bornDT: bornDT,
                                        eMail: eMail,
                                        phoneNumber: phoneNumber,
                                        photographerWebsite: URL(string: externalURL) ?? nil
                                   )
                    )
                }

                targetState = targetState.nextState()
            }
        }

    }

    // add Photographer and MemberPortfolio records to CoreData
    fileprivate func addMember(bgContext: NSManagedObjectContext,
                               organization: Organization,
                               personName: PersonName,
                               optionalFields: PhotographerOptionalFields) {

        let photographer = Photographer.findCreateUpdate(
            context: bgContext,
            personName: personName,
            isDeceased: !self.isStillAlive(phone: optionalFields.phoneNumber),
            optionalFields: optionalFields)

        _ = MemberPortfolio.findCreateUpdate(
                bgContext: bgContext,
                organization: organization,
                photographer: photographer,
                optionalFields: MemberOptionalFields(
                    level3URL: self.generateInternalURL(using: personName.fullNameWithoutParenthesizedRole),
                    memberRolesAndStatus: MemberRolesAndStatus(
                        role: [:], // FG Waalre HTML input file doesn't contain role information
                        status: [
                            .former: !self.isCurrentMember(name: personName.fullNameWithParenthesizedRole,
                                                           includeProspectiveMembers: true),
                            .coach: self.isMentor(name: personName.fullNameWithParenthesizedRole),
                            .prospective: self.isProspectiveMember(
                                name: personName.fullNameWithParenthesizedRole
                            )
                        ]
                    )
                )
            )
    }

    fileprivate func generateInternalURL(using name: String) -> URL? { // only use standard ASCII A...Z,a...z in URLs
        // spaces are replaced by underscores:
        //      "Peter van den Hamer" -> "<baseURL>/Peter_van_den_Hamer"
        // cases with one or more replacements:
        //      "Henriëtte van Ekert" -> "<baseURL>/Henriette_van_Ekert"
        //      "José_Daniëls" -> "<baseURL>/Jose_Daniels"
        // case if there is a replacement needed, that is not defined yet
        //      "Ekin Özbiçer" -> "<baseURL>/Ekin_" // because app doesn't substitute the Ö yet
        var tweakedName = name.replacingOccurrences(of: " ", with: "_")
                              .replacingOccurrences(of: "á", with: "a") // affects István_Nagy, fgWaalre
                              .replacingOccurrences(of: "ç", with: "c") // affects François_Hermans, fgWaalre
                              .replacingOccurrences(of: "ë", with: "e") // affects Henriëtte_van_Ekert, fgWaalre
                              .replacingOccurrences(of: "é", with: "e") // affects José_Daniëls, fgWaalre
                              .replacingOccurrences(of: "ü", with: "u") // affects Hans_Krüsemann, fgDeGender

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

        // final "/" not strictly needed (link works without)
        return URL(string: FotogroepWaalreMembersProvider.baseURL + "/" + tweakedName + "/")
    }

    fileprivate func toDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: dateString)
    }

}
