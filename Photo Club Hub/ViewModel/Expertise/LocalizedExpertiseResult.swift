//
//  LocalizedExpertiseResult.swift
//  Photo Club Hub HTML (struct currently only used by Photo Club Hub HTML)
//
//  Created by Peter van den Hamer on 26/04/2025.
//

import Foundation

/// One photographer expertise tag, resolved into a single language and ready to render.
///
/// Each value pairs a localized name with the metadata the UI/HTML needs to display it: the delimiter that
/// follows it in a comma-separated line, an optional hint that overrides the standard tooltip, and whether
/// it links to an `ExpertisePage`.
/// A `LocalizedExpertiseResult` is one element of a ``LocalizedExpertiseResultList``;
/// the supported and temporary lists together form a ``LocalizedExpertiseResultLists``.
///
/// "Supported" tags (those listed at Level 0) carry a non-nil ``localizedExpertise`` and therefore a
/// translated name; "temporary" tags have none and fall back to their raw ``id``. A few entries are
/// synthetic — e.g. the "Too many expertises" overflow warning — and are flagged non-navigable because no
/// `ExpertisePage` exists for them.
public struct LocalizedExpertiseResult {
    /// The expertise translated into the chosen language, or `nil` if no Level 0 translation exists for it.
    /// When `nil`, the tag is treated as "temporary"/"unsupported" and ``name`` falls back to ``id``.
    public let localizedExpertise: LocalizedExpertise?

    /// Canonical (English) expertise identifier, e.g. "Architecture" is used as the fallback name when there is
    /// no translation, and as the path component of the linked `ExpertisePage`.
    public let id: String

    /// Text appended _after_ this tag in a comma-separated line — normally `","`, set to `""` for the final tag.
    public var delimiterToAppend: String

    /// When set, overrides the standard tooltip/hint for this tag (e.g. the overflow warning's expertise list).
    public var customHint: String?

    /// Whether this tag links to an `ExpertisePage`. `false` for synthetic entries (e.g. the "Too many
    /// expertises" overflow warning) that have no page to link to, so the renderer shows them as plain text.
    public let isNavigable: Bool

    /// The display name in the chosen language: the localized name, or ``id`` when no translation exists.
    public var name: String { localizedExpertise?.name_ ?? id }

    /// `true` when a Level 0 translation exists (a "supported" tag); `false` for "temporary" tags.
    var isSupported: Bool { localizedExpertise != nil }

    public init(localizedExpertise: LocalizedExpertise?,
                id: String,
                delimiterToAppend: String = ",",
                customHint: String? = nil,
                isNavigable: Bool = true) {
        self.localizedExpertise = localizedExpertise
        self.id = id
        self.delimiterToAppend = delimiterToAppend
        self.customHint = customHint
        self.isNavigable = isNavigable
    }
}

extension LocalizedExpertiseResult: Comparable {

    /// Orders tags alphabetically by ``name``, but always sorts untranslated ("temporary") tags after
    /// translated ("supported") ones, regardless of their names.
    public static func < (lhs: LocalizedExpertiseResult, rhs: LocalizedExpertiseResult) -> Bool {

        if (lhs.localizedExpertise != nil && rhs.localizedExpertise != nil) || // both sides have a translation
            (lhs.localizedExpertise == nil && rhs.localizedExpertise == nil) { // both sides have no translation
            return lhs.name < rhs.name // normal sorting
        }
        return lhs.localizedExpertise != nil // put untranslateables after translateables

    }

}

extension LocalizedExpertiseResult: Identifiable { } // for compatibility with ForEach
