//
//  MapMarker​Appearance.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 06/02/2026.
//

import SemanticColorPicker // for SemanticColor

/// Returns the tint color for a single map marker representing an organization.
/// The rules for this are executed in a specific priority.
/// Note that the marker has a different symbol for Clubs than for Museums.
///
/// - Parameters:
///   - organization: The organization for which to return the marker tint.
///   - selectedOrganization: The organization currently centered/selected on this particular  map.
/// - Returns: The `Color` in which to tint the marker for `organization`.
@MainActor
public func selectMarkerTint(organization: Organization, selectedOrganization: Organization) -> SemanticColor {
    let errorColor: SemanticColor = .red

    /// The marker for `selectedOrganization` gets a special color. It is usually at the center of the map.
    if isEqual(organizationLHS: organization, organizationRHS: selectedOrganization) {
        return .purple // TODO change to .organizationColor
    }

    if organization.organizationType.isMuseum {
        return .blue /// Show any Museum in blue (except the `selectedOrganization`)
    }

    guard organization.organizationType.isUnknown == false else {
        ifDebugFatalError("Unexpected organizationType in selectMarkerTint().") // falls though in production builds
        return errorColor // for .unknown organization type (has higher priority than other rules)
    }

    if organization.organizationType.isClub {

        let appSettings = PreferencesViewModel().preferences /// persisted via UserDefaults via `@Published``

        guard !(appSettings.highlightNonFotobondNL == true && appSettings.highlightFotobondNL == true) else {
            ifDebugFatalError("Fotobond and non-Fotobond toggle are both enabled. That shouldn't happen.")
            return errorColor
        }

        let clubInFotobond: Bool = (organization.fotobondClubNumber?.id != nil) // is club member of Dutch Fotobond
        let highlightColor: SemanticColor = appSettings.highlightColor
        let neutralColor: SemanticColor = .blue

        if appSettings.highlightFotobondNL { // TODO add .gray (temp .brown50)
            return clubInFotobond ? highlightColor : neutralColor // highlight Fotobond clubs, and make other clubs gray
        } else {
            return clubInFotobond ? neutralColor: highlightColor // highlight NonFotobond clubs; other clubs as gray
        }
    }

    return .blue // fall through isn't really possible (we have checked all enum cases)

    func isEqual(organizationLHS: Organization, organizationRHS: Organization) -> Bool {
        return (organizationLHS.fullName == organizationRHS.fullName) && (organizationLHS.town == organizationRHS.town)
    }

}

public func systemName(organizationType: OrganizationType?, circleNeeded: Bool) -> String { // for SF symbols
    guard let organizationType else { return "questionmark.circle.fill" }

    var result: String

    switch organizationType.organizationTypeName {
    case OrganizationTypeEnum.museum.rawValue:
        result = "building.columns.fill"
    case OrganizationTypeEnum.club.rawValue:
        result = "camera.fill"
    case OrganizationTypeEnum.unknown.rawValue:
        result = "questionmark"
    default: // compiler insists on having a default, likely because organizationTypeName is a String
        result = "exclamationmark"
    }

    if circleNeeded {
        result = result.replacing(".fill", with: ".circle.fill")
    }
    return result
}
