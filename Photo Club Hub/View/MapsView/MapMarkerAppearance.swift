//
//  MapMarkerAppearance.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 06/02/2026.
//

import SwiftUI // for Color
import SemanticColorPicker // for SemanticColor
import Photo_Club_Hub_Data // for types such as Organization

// We strongly recommend viewing the Preview for this file:
// *t shows a table of all possible cases and resulting markers.

/// Central rules for deciding a marker's tint, applied in this order of priority.
/// `markerTint`is private, and only meant to be used by `MapMarkerBalloon`.
/// Note that the marker uses a different symbol for Clubs than for Museums.
///
/// - Parameters:
///   - organizationType: The organization's type.
///   - isOwn: Whether the organization is the one the map is about.
///   - isInFotobond: Whether the organization is a club that is a member of the Dutch Fotobond.
///   - settings: The app's settings, for cases when highlighting feature in Settings is used (for now a Dutch thing)
/// - Returns: The `Color` in which to tint the marker.
private func markerTint(organizationType: OrganizationTypeEnum,
                        isOwn: Bool,
                        isInFotobond: Bool,
                        settings: SettingsStruct
                       ) -> Color {
    let errorColor: Color = .red

    // The map's own organization gets a special color, even if it has a .unknown type (would be a bug)
    if isOwn { return .mapsColor }

    switch organizationType {
    case .unknown:
        return errorColor
    case .museum:
        return .blue // Show any Museum in blue (except the map's "own" organization)
    case .club:
        guard !(settings.highlightNonFotobondNL == true && settings.highlightFotobondNL == true) else {
            ifDebugFatalError("Fotobond and non-Fotobond toggle are both enabled. That is an invalid state.")
            return errorColor
        }

        let highlightColor: Color = settings.highlightColor.color // convert from SemanticColor
        let neutralColor: Color = .gray

        if settings.highlightFotobondNL == false && settings.highlightNonFotobondNL == false {
            return .blue // nothing to highlight, this is a mainstream case
        }

        if settings.highlightFotobondNL {
            return isInFotobond ? highlightColor : neutralColor // highlight Fotobond clubs, else use neutralColor
        } else {
            return isInFotobond ? neutralColor : highlightColor // highlight NonFotobond clubs, else use neutralColor
        }
    }
}

extension OrganizationType { // TODO: delete this copy when the app moves to Photo Club Hub Data 3.7.0
    /// The type as an enum, which views can use without Core Data (e.g. in previews).
    /// The Data package creates every `OrganizationType` from an `OrganizationTypeEnum` value, so the fallback to
    /// `.unknown` (a red marker) only catches a damaged store.
    var organizationTypeEnum: OrganizationTypeEnum {
        OrganizationTypeEnum(rawValue: organizationTypeName) ?? .unknown
    }
}

/// The marker for an organization on a map: a tinted pointer with the organization type's symbol and appropriate color.
/// Used on live maps (as the content of an `Annotation`) and on static images of locked maps (#867), so that locking or
/// unlocking a map doesn't change its markers.
///
/// Replaces MapKit's own `Marker`, whose look can't be changed beyond its color and symbol. Its point is short and,
/// in dark mode, has the map's dark outline color, so it is hard to see, and the eye takes the circle's center for
/// the spot. Here the tint runs into a longer point, whose tip points to the organization's location on the map.
struct MapMarkerBalloon: View {

    private let organizationType: OrganizationTypeEnum
    private let backgroundColor: Color // always from `markerTint`

    /// For the marker of `organization` on the map centered on `mapOrganization`. Used by the maps.
    /// Looks up what `markerTint` needs from the two organizations and the app's settings.
    init(organization: Organization, mapOrganization: Organization) {
        self.init(organizationType: organization.organizationType.organizationTypeEnum,
                  isOwn: MapsViewMap.isOwn(organization,
                                           mapOrganization: mapOrganization),
                  isInFotobond: organization.fotobondClubNumber?.id != nil, // is club member of Dutch Fotobond
                  settings: SettingsViewModel().settings) /// SettingsViewModel is marked as `@Published`
    }

    /// For a marker described without Core Data: used by previews, and by `MapsViewInfo` for its own organization.
    /// The parameters are those of `markerTint`.
    init(organizationType: OrganizationTypeEnum,
         isOwn: Bool,
         isInFotobond: Bool,
         settings: SettingsStruct) {
        self.organizationType = organizationType
        self.backgroundColor = markerTint(organizationType: organizationType,
                                          isOwn: isOwn,
                                          isInFotobond: isInFotobond,
                                          settings: settings)
    }

    /// The SF Symbol drawn in the round part, for the organization's type.
    private var systemImage: String {
        switch organizationType {
        case .club: "camera.fill"
        case .museum: "building.columns.fill"
        case .unknown: "questionmark"
        }
    }

    static let width: CGFloat = 30 // matches MapKit's own marker (iPhone simulator, Oct 2026)
    static let height: CGFloat = 36
    private static let outlineWidth: CGFloat = 1.5

    var body: some View {
        MapMarkerBalloonShape()
            .fill(backgroundColor)
            .stroke(.secondary, lineWidth: Self.outlineWidth)
            .overlay(alignment: .top) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: Self.width, height: Self.width) // centered in the round part
            }
            .shadow(color: .black.opacity(0.4), radius: 3, x: 3, y: 3)
            .frame(width: Self.width, height: Self.height)
    }
}

/// A circle with a point at the bottom center: the outline of a `MapMarkerBalloon`.
private struct MapMarkerBalloonShape: Shape {

    /// Half the width of the point where it leaves the circle, as an angle seen from the circle's center.
    private static let pointHalfAngle: Double = .pi / 8 // 22.5°

    func path(in rect: CGRect) -> Path {
        let radius = rect.width / 2
        let center = CGPoint(x: rect.midX, y: rect.minY + radius)
        let tip = CGPoint(x: rect.midX, y: rect.maxY)

        let halfAngle = Self.pointHalfAngle // between straight down and where the point leaves the circle
        let right = CGPoint(x: center.x + radius * sin(halfAngle), y: center.y + radius * cos(halfAngle))

        var path = Path()
        path.move(to: tip)
        path.addLine(to: right)
        // From the lower right, over the top, to the lower left.
        path.addArc(center: center, radius: radius,
                    startAngle: .radians(.pi / 2 - halfAngle), endAngle: .radians(.pi / 2 + halfAngle),
                    clockwise: true)
        path.closeSubpath()
        return path
    }
}

// MARK: - Previews

// Shows the marker for each organization type and highlight setting, as markerTint colors it:
// on another organization (left column) and on the map's own organization (right column).

#Preview {
    // A Grid makes each column as wide as its widest cell. Giving both headers this width makes the marker columns
    // equally wide, so the markers are evenly spaced.
    let markerColumnWidth: CGFloat = 50

    let rows: [TintPreviewRow] = [
        TintPreviewRow("MUSEUM", .museum),
        TintPreviewRow("CLUB, no highlight", .club),
        TintPreviewRow("Fotobond CLUB, highlight Fotobond", .club,
                       isInFotobond: true, settings: .highlighting(fotobond: true)),
        TintPreviewRow("other CLUB, highlight Fotobond", .club, settings: .highlighting(fotobond: true)),
        TintPreviewRow("Fotobond CLUB, highlight others", .club,
                       isInFotobond: true, settings: .highlighting(fotobond: false)),
        TintPreviewRow("other CLUB, highlight others", .club, settings: .highlighting(fotobond: false)),
        TintPreviewRow("unknown type", .unknown)
    ]

    Grid(horizontalSpacing: 20, verticalSpacing: 10) { // a Grid, so the cells line up in columns
        GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical]) // empty corner cell
            Text(verbatim: "other").frame(width: markerColumnWidth)
            Text(verbatim: "own").frame(width: markerColumnWidth)
        }
        ForEach(rows.indices, id: \.self) { index in
            let row = rows[index]
            GridRow {
                Text(verbatim: row.label)
                    .lineLimit(1)
                    .gridColumnAlignment(.leading) // applies to the whole first column
                ForEach([false, true], id: \.self) { isOwn in
                    MapMarkerBalloon(organizationType: row.type,
                                     isOwn: isOwn,
                                     isInFotobond: row.isInFotobond,
                                     settings: row.settings)
                }
            }
        }
    }
    .font(.footnote) // small enough for the longest label to fit on one line
    .padding()
    .background(Color(.systemGray4))
    Text(verbatim: "Highlight color is set in Settings tab")
}

/// One row of the preview: an organization type, and what else its marker's tint depends on.
private struct TintPreviewRow {
    let label: String
    let type: OrganizationTypeEnum
    let isInFotobond: Bool
    let settings: SettingsStruct

    init(_ label: String, _ type: OrganizationTypeEnum,
         isInFotobond: Bool = false, settings: SettingsStruct = .defaultValue) {
        self.label = label
        self.type = type
        self.isInFotobond = isInFotobond
        self.settings = settings
    }
}

private extension SettingsStruct {
    /// The default settings, but highlighting either the Fotobond clubs or the other clubs.
    static func highlighting(fotobond: Bool) -> SettingsStruct {
        var settings = SettingsStruct.defaultValue
        settings.highlightFotobondNL = fotobond
        settings.highlightNonFotobondNL = !fotobond
        return settings
    }
}
