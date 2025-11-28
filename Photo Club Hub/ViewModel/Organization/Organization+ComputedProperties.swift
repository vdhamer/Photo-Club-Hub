//
//  Organization+ComputedProperties.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreLocation // needed for coordinate translation

extension Organization {

    // MARK: - getters and setters

	public var members: Set<MemberPortfolio> {
		get { (members_ as? Set<MemberPortfolio>) ?? [] }
		set { members_ = newValue as NSSet }
	}

    var organizationType: OrganizationType {
        @MainActor
        get { // careful: cannot read organizationType on background thread if database still contains nil
            if organizationType_ != nil {
                return organizationType_! // organizationType_ cannot be nil at this point
            } else {
                // something is fundamentally wrong if this happens
                ifDebugFatalError( "Error because organization is nil", file: #fileID, line: #line )
                let persistenceController = PersistenceController.shared // for Core Data
                let viewContext = persistenceController.container.viewContext // requires @MainActor
                return OrganizationType.findCreateUpdate( // organizationType is CoreData NSManagedObject
                    context: viewContext, // requires @MainActor
                    orgTypeName: OrganizationTypeEnum.unknown.rawValue
                )
            }
        }

        set {
            if organizationType_ != newValue { // avoid unnecessarily dirtying context
                organizationType_ = newValue
            }
        }
    }

	public var fullName: String {
		get { return fullName_ ?? "DefaultPhotoClubName" }
		set { fullName_ = newValue }
	}

    // Appends " \(town)" to \(fullName) unless \(town) is already part of \(fullName).
    // The following cases are tested in OrganizationTest:
    // "Fotogroep Waalre" and "Aalst" returns "Fotogroep Waalre (Aalst)"
    // "Fotogroep Waalre" and "Waalre" returns "Fotogroep Waalre"
    // "Fotogroep Waalre" and "waalre" returns "Fotogroep Waalre"
    // "Fotogroep Waalre" and "to" returns "Fotogroep Waalre (to)"
    // "Fotogroep Waalre" and "Waal" returns "Fotogroep Waalre (Waal)" if you use NLP-based word matching
    // "Fotoclub Den Dungen" and "Den Dungen" returns "Fotoclub Den Dungen"
    // "Fotokring Sint-Michelsgestel" and "Sint-Michelsgestel" returns "Fotoclub Sint-Michelsgestel"
    @objc public var fullNameTown: String { // @objc needed for SectionedFetchRequest's sectionIdentifier
        if fullName.containsWordUsingNLP(targetWord: town) {
            return fullName // fullname "Fotogroep Waalre" and town "Waalre" returns "Fotogroep Waalre"
        }

        if fullName.contains(town) { // for "Fotoclub Den Dungen" and "Fotokring Sint-Michielsgestel"
            if town.contains(" ") || town.contains("-") {
                return fullName
            }
        }

        return "\(fullName) (\(town))" // fullname "Fotogroep Aalst" with "Waalre" returns "Fotogroep Aalst (Waalre)"
    }

    public var id: OrganizationID { // public because needed for Identifiable protocol
        OrganizationID(fullName: self.fullName, town: self.town)
    }

    public var nickName: String {
        get { return nickName_ ?? "Name?" }
        set { nickName_ = newValue }
    }

    public var contactEmail: String? {
        get { // https://softwareengineering.stackexchange.com/questions/32578/sql-empty-string-vs-null-value
            if contactEmail_ == "" || contactEmail_ == nil {
                return nil
            } else {
                return contactEmail_!
            }
        }
        set {
            if newValue == "" {
                contactEmail_ = nil
            } else {
                contactEmail_ = newValue
            }
        }
    }

	public var town: String { // may be one word ("Rotterdam") or multiple words ("Den Bosch").
		get { return town_ ?? "DefaultPhotoClubTown" }  // nil shouldn't occur, but it does?
		set { town_ = newValue }
	}

    var localizedTown: String {
        /*
            LocalizedCountry is retrieved from the CoreData database, where it is not optional.
            It is calculated using the mandatory GPS coordinates using reverseGeolocation.
            During this reverseGeolocation, the string is automatically adapted to the current locale.
            Example: Paris returns localizedTown="Paris" if the device is set to Dutch.
            The value of Town is not localized and is the original value provided by the user.
            Localization may return a slightly different town: Tokyo -> suburb of Tokyo (because "Tokyo" is not used).
        */
        get { return localizedTown_ ?? "ErrorTown" }
        set { localizedTown_ = newValue}
    }

    var localizedCountry: String {
        /*
         LocalizedCountry is retrieved from the CoreData database, where it is not optional.
         It is calculated using the mandatory GPS coordinates using reverseGeolocation.
         During this reverseGeolocation, the string is automatically adapted to the current locale.
         Example: Paris returns localizedCountry="Frankrijk" if the device is set to Dutch.
         */
        get { return localizedCountry_ ?? "ErrorCountry" }
        set { localizedCountry_ = newValue}
    }

    var level2URL: URL? {
        get {
            // use a default unless level2URL points to the club's own website
            let defaultURL: URL? = URL(string: "http://www.vdhamer.com/\(self.nickName)/index.html")
            guard let defaultURL else {
                ifDebugFatalError("Bad URL: \(defaultURL?.absoluteString ?? "nil")")
                return nil
            }

            guard !self.organizationType.isMuseum else { return nil } // no level2URL for a museum
            guard self.organizationType.isClub else { // warn if bad or new OrganizationType
                ifDebugFatalError("Unexpected organizationType: \(self.organizationType.organizationTypeName)")
                return nil // for production code
            }

            guard self.level2URL_ != nil else { return defaultURL } // nobody provided a URL
            guard let website: String = self.organizationWebsite?.absoluteString else { return defaultURL }
            guard self.level2URL_!.absoluteString.lowercased().contains(website.lowercased()) else { return defaultURL }

            return level2URL_ // initial files don't reach this point when Website is (still) a dummy value
        }
        set { level2URL_ = newValue }
    }

    public var level2URLDir: URL? {
        let url: URL? = level2URL
        guard url != nil else { return nil }
        return url!.deletingLastPathComponent()
    }

    var coordinates: CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: latitude_, longitude: longitude_) }
        set {
            latitude_ = newValue.latitude
            longitude_ = newValue.longitude
        }
    }

    var localizedRemarks: Set<LocalizedRemark> {
        (localizedRemarks_ as? Set<LocalizedRemark>) ?? []
    }

    // Priority system to choose an item's remark in the appropriate language.
    // The choice depends on the current language settings of the device, and on available translations.
    var localizedRemark: String {
        // don't use Locale.current.language.languageCode because this only returns languages supported by the app
        // first choice: accomodate user's language preferences according to Apple's Locale API
        for lang in Locale.preferredLanguages {
            let langID = lang.split(separator: "-").first?.uppercased() ?? "EN"
            // now check if one of the user's preferences is available for this Remark
            for localRemark in localizedRemarks where localRemark.language.isoCode == langID {
                if localRemark.localizedString != nil {
                    return localRemark.localizedString!
                }
            }
        }

        // second choice: most people speak English, at least let's pretend that is the case ;-)
        for localizedRemark in localizedRemarks where localizedRemark.language.isoCode == "EN" {
            if localizedRemark.localizedString != nil {
                return localizedRemark.localizedString!
            }
        }

        // third choice: use any translation available for this expertise
        if localizedRemarks.first != nil, localizedRemarks.first!.localizedString != nil {
            return "\(localizedRemarks.first!.localizedString!) [\(localizedRemarks.first!.language.isoCode)]"
        }

        // otherwise display an error message instead of a real remark
        let clubOrMuseum: String = organizationType.organizationTypeName
        return String(localized: "No remark currently available for \(clubOrMuseum) \(fullName).",
                      table: "PhotoClubHubData",
                      comment: "Shown below map if there is no usable remark in the OrganzationList.json file.")
    }

}
