//
//  FGWMembersProvider.swift
//  FGWMembersProvider
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for NSManagedObjectContext

class FGWMembersProvider { // WWDC21 Earthquakes also uses a Class here

    private static let photoClubID: (name: String, town: String) = ("Fotogroep Waalre", "Waalre")

//    /// A shared member provider for use within the main app bundle.
//    static let shared = FotogroepWaalreMembersProvider()

    init() {
        let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        // following is asynchronous, but not documented as such using async/await
        insertSomeHardcodedMemberData(fgwBackgroundContext: fgwBackgroundContext, commit: true)

        let urlString = getFileAsString(secretFilename: "PrivateMembersURL2.txt",
                                        unsecretFileName: "PrivateMembersURL3.txt") // fetch URL2 or URL3
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

    private func getFileAsString(secretFilename: String, unsecretFileName: String) -> String {
        if let secret = readURLFromLocalFile(fileNameWithExtension: secretFilename) {
            print("About to use confidential version of Private member data file.")
            return secret
        } else {
            if let unsecret = readURLFromLocalFile(fileNameWithExtension: unsecretFileName) {
                print("About to use non-confidential version of Private member data file.")
                return unsecret
            } else {
                print("Problem accessing either version of Private member data file.")
                return "Internal error: file \(unsecretFileName) looks encrypted"
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

    ///////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Load ex-members array (including name and URLs) from internal website page

    // Example fragment from middle of PRIVATELEDENURL file
    // <table>
    // <tbody>
    // <tr>
    // <th>Ex-lid</th>
    // <th>E-mail</th>
    // <th>Telefoon</th>
    // </tr>
    // <tr>
    // <td>Aad Schoenmakers</td>
    // <td><a href="mailto:aad@fotograad.nl">aad@fotograad.nl</a></td>
    // <td>06-10859556</td>
    // </tr>
    // <tr>
    // <td>Hans van Steensel (aspirantlid)</td>
    // <td><a href="mailto:info@vansteenselconsultants.nl">info@vansteenselconsultants.nl</a></td>
    // <td>06-53952538</td>
    // </tr>

    enum HTMLPageLoadingState: String {
        // rawValues are target search strings in the HTML file
        case tableStart     = "<table>"
        case tableHeader    = "Groepslid" // "Ex-lid" "Groepslid""
        case rowStart       = "<tr>"
        case personName     = "<td>"
        case eMail          = "<td><a href"
        case phoneNumber    = "<td"            // strings have to be unique, otherwise <td> would be more obvious
        case externalURL    = "<td><a title"

        // compute next state for given state
        func nextState() -> HTMLPageLoadingState {
            switch self {
            case .tableStart:    return .tableHeader
            case .tableHeader:   return .rowStart
            case .rowStart:      return .personName
            case .personName:    return .eMail
            case .eMail:         return .phoneNumber
            case .phoneNumber:   return .externalURL
            case .externalURL:   return .rowStart
            }
        }

        // myState.targetString() alternative to myState.rawValue
        func targetString() -> String {
            return self.rawValue
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

        var eMail = "", phoneNumber: String?, externalURL: String = ""
        var familyName = "", givenName = "", personName  = ""

        let photoClub: PhotoClub = PhotoClub.findCreateUpdate(context: backgroundContext,
                                                              name: photoClubID.name, town: photoClubID.town)

        htmlContent.enumerateLines { (line, _ stop) -> Void in
            if line.contains(targetState.targetString()) {
                switch targetState {

                case .tableStart: break   // find start of table (only happens once)
                case .tableHeader: break  // find head of table (only happens once)
                case .rowStart: break     // find start of a table row defintion (may contain <td> or <th>)

                case .personName:       // find first cell in row
                    personName = self.stripOffTagsFromName(taggedString: line) // cleanup
                    (givenName, familyName) = self.componentizePersonName(name: personName, printName: false)

                case .eMail:                      // then find 2nd cell in row
                    eMail = self.stripOffTagsFromEMail(taggedString: line) // store url after cleanup

                case .phoneNumber:                  // then find 3rd cell in row
                    phoneNumber = self.stripOffTagsFromPhone(taggedString: line) // store url after cleanup

                case .externalURL:
                    externalURL = self.stripOffTagsFromExternalURL(taggedString: line) // url after cleanup

                    let photographer = Photographer.findCreateUpdate(
                        context: backgroundContext, givenName: givenName, familyName: familyName,
                        memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [
                            .deceased: !self.isStillAlive(phone: phoneNumber) ]),
                        phoneNumber: phoneNumber, eMail: eMail,
                        photographerWebsite: URL(string: externalURL)
                    )

                    let (givenName, familyName) = self.componentizePersonName(name: personName, printName: false)
                    _ = MemberPortfolio.findCreateUpdate(
                        context: backgroundContext, photoClub: photoClub, photographer: photographer,
                        memberRolesAndStatus: MemberRolesAndStatus(
                            role: [:],
                            stat: [
                                .former: !self.isCurrentMember(name: personName, includeCandidates: true),
                                .coach: self.isMentor(name: personName),
                                .prospective: self.isProspectiveMember(name: personName)
                            ]
                        ),
                        memberWebsite: self.generateInternalURL(using: "\(givenName) \(familyName)")
                    )

                }

                targetState = targetState.nextState()
            }
        }

    }
}

extension FGWMembersProvider { // private utitity functions

    private func stripOffTagsFromPhone(taggedString: String) -> String? {
        // <td>2213761</td>
        // <td>06-22479317</td>
        // <td>[overleden]</td>
        // <td>[mentor]</td>

        let REGEX: String = "<td>(\\[mentor\\]|\\[overleden\\]|[0-9\\-\\?]+)<\\/td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            if result[0] != "?" {
                return result[0]
            } else {
                return nil
            }
        } else {
            return "Error: \(taggedString)"
        }
    }

    private func stripOffTagsFromEMail(taggedString: String) -> String {
        // <td><a href="mailto:bsteek@gmail.com">bsteek@gmail.com</a></td>

        let REGEX: String = "<td><a href=\"[^\"]+\">([^<]+)<\\/a><\\/td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            print("Error: \(taggedString)")
            return "Error: \(taggedString)"
        }
    }

    private func stripOffTagsFromName(taggedString: String) -> String {
        // <td>Ariejan van Twisk</td>

        let REGEX: String = "<td>([^<]+)<\\/td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "Error: \(taggedString)"
        }
    }

    private func stripOffTagsFromExternalURL(taggedString: String) -> String {
        // swiftlint:disable:next line_length
        // <td><a title="Ariejan van Twisk fotografie" href="http://www.ariejanvantwiskfotografie.nl" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td>

        let REGEX: String = " href=\"([^\"]*)\""
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "Error: \(taggedString)"
        }
    }

    // Split a String containing a name into PersonNameComponents
    // This is done manually instead of using the iOS 10
    // formatter.personNameComponents() function to handle last names like Henny Looren de Jong
    // An optional suffix like (lid), (aspirantlid) or (mentor) is removed
    // This is done in 2 stages using regular expressions because I coudn't get it to work in one stage
    private func componentizePersonName(name: String, printName: Bool) -> (givenName: String, familyName: String) {
        var components = PersonNameComponents()
        var strippedNameString: String
        if name.contains(" (lid)") {
            let REGEX: String = "([^(]*) \\(lid\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else if name.contains(" (aspirantlid)") {
            let REGEX: String = "([^(]*) \\(aspirantlid\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else if name.contains(" (mentor)") {
            let REGEX: String = "([^(]*) \\(mentor\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else {
            strippedNameString = name
        }
        let REGEX: String = "([^ ]+) (.*)" // split on first space
        let result = strippedNameString.capturedGroups(withRegex: REGEX)
        if result.count > 1 {
            components.givenName  = result[0]
            components.familyName = result[1]
            if printName {
                print("Name found: \(components.givenName!) \(components.familyName!)")
            }
            return (components.givenName!, components.familyName!)
        } else {
            if printName {
                print("Error in componentizePersonName() while handling \(name)")
            }
           return ("Bad member name: ", "rawNameString")
        }
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

}
