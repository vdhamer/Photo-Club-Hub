//
//  Language+InterfaceLanguage.swift
//  Photo Club Hub
//
//  Created by Claude Code (guided by Peter van den Hamer) on 07/11/2026.
//

import CoreData             // for NSFetchRequest
import Photo_Club_Hub_Data  // for Language

extension Language {

    /// A fetch request for the `Language` of the app's own resolved interface language, for use in a `@FetchRequest`.
    ///
    /// This is the language an organization's town is shown and searched in (Data#88), so that a localized town
    /// reads in the same language as the rest of the interface. `knownRegions` is en/nl, so this can only resolve
    /// to a language the site generator also publishes, which keeps the rows written here interchangeable with
    /// the ones `OrganizationGeocoder` writes (#827).
    ///
    /// The language is `Bundle.main.preferredLocalizations.first`: the localization iOS picked for this app's own
    /// texts, so the town is in the language of the interface by definition. A device set to German or Japanese
    /// gets "en", the development region. `Locale.current` gives the same answer on iOS today, but it also
    /// follows region and formatting settings, and the HTML app found the two disagreeing on macOS.
    ///
    /// The request finds no row only if `Language.initConstants` has not run yet.
    static var interfaceLanguageRequest: NSFetchRequest<Language> {
        let localization = Bundle.main.preferredLocalizations.first ?? "en" // e.g. "en" or "nl"
        let isoCode = Locale(identifier: localization).language.languageCode?.identifier ?? "en"

        let request = Language.fetchRequest()
        request.predicate = NSPredicate(format: "isoCode_ =[c] %@", isoCode) // avoid localization
        request.sortDescriptors = [] // required: @FetchRequest traps on a request with nil sortDescriptors
        request.fetchLimit = 1       // one row is enough
        return request
    }

}
