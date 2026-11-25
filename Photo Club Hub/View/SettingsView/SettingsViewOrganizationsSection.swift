//
//  SettingsViewOrganizationsSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker
import Photo_Club_Hub_Data // for OrganizationTypeEnum

struct SettingsViewOrganizationsSection: View {
    @Binding var settings: SettingsStruct

    var body: some View {
        Section(header: Text("Organizations",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Settings, section title above map-related toggles"),
                footer: emptyMapsFooter,
                content: {

            HStack(spacing: SettingsView.iconSpacing) { // Show clubs
                markerIcon(organizationType: .club, color: .plainMarkerColor, // as a club on the maps
                           isShown: settings.showClubs)
                Toggle(String(localized: "Show clubs",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showClubs.animation())
            }

            // The highlighting rows sit right below "Show clubs", which reveals them.
            // A highlighting row that can't apply is hidden rather than disabled: with clubs hidden on the maps there
            // is nothing to highlight, and only one of the two highlighting toggles can be on at a time.
            if settings.showClubs && !settings.highlightNonFotobondNL {
                HStack(spacing: SettingsView.iconSpacing) { // Highlight Fotobond clubs
                    highlightIcon
                    Toggle(String(localized: "Highlight Fotobond clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Settings"),
                           isOn: $settings.highlightFotobondNL.animation())
                }
            }

            if settings.showClubs && !settings.highlightFotobondNL {
                HStack(spacing: SettingsView.iconSpacing) { // Highlight non-Fotobond clubs
                    highlightIcon
                    Toggle(String(localized: "Highlight non-Fotobond clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Settings"),
                           isOn: $settings.highlightNonFotobondNL.animation())
                }
            }

            // Shown whenever clubs are, also while no highlighting is on, so the color can be chosen beforehand.
            // Then both highlighting toggles animate alike: the other toggle's row goes, and this row slides up.
            if settings.showClubs {
                HStack(spacing: SettingsView.iconSpacing) {
                    markerIcon(organizationType: .club, color: settings.highlightColor.color) // the chosen color
                    SemanticColorPicker(
                        String(localized: "Highlighting color",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Label of color picker in Settings"),
                        data: SemanticColor.palette,
                        selection: $settings.highlightColor)
                }
            }

            HStack(spacing: SettingsView.iconSpacing) { // Show museums
                markerIcon(organizationType: .museum, color: .plainMarkerColor, // as a museum on the maps
                           isShown: settings.showMuseums)
                Toggle(String(localized: "Show museums",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showMuseums.animation())
            }

            // Also decides which clubs the Clubs tab shows, unlike the other toggles in this section (#891, #892),
            // so its label has a second line that says so.
            // Hidden while clubs and museums are both off, like the highlighting rows above. Its value then still
            // applies to the Clubs tab, which ignores those two toggles, but can't be changed until one is back on.
            if settings.couldShowOrganizations {
                HStack(spacing: SettingsView.iconSpacing) { // Show inactive organizations
                    markerIcon(organizationType: settings.showClubs ? .club : .museum, // the ghost it brings back
                               color: .ghostMarkerColor, isGhost: true, isShown: settings.showInactiveOrganizations)
                    Toggle(isOn: $settings.showInactiveOrganizations.animation()) {
                        VStack(alignment: .leading) {
                            // "clubs", "museums" or "organizations", as in the Maps tab's title
                            Text("Show inactive \(settings.organizationLabel().lowercased())",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: "Label of toggle in Settings: also show clubs and/or museums that stopped")
                            Text("Also applies to the Clubs tab",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: "Second line of the Show inactive organizations toggle in Settings")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }) // end of section
    } // end of body

    /// A note below the section while clubs and museums are both off, so the empty Maps tab doesn't come as a
    /// surprise. The Maps tab says so too, but only once it is opened. `couldShowOrganizations` also decides
    /// `organizationPredicate`, so the two can't disagree.
    @ViewBuilder
    private var emptyMapsFooter: some View {
        if settings.couldShowOrganizations == false {
            Text("Warning: Maps will show no markers when clubs and museums are both off.",
                 tableName: "PhotoClubHub.SwiftUI",
                 comment: "In Settings, footer of the Organizations section while Show clubs and Show museums are off")
        }
    }

    /// The icon of the highlighting rows: a club marker in the color a highlighted club gets on the maps, or in plain
    /// blue while highlighting is off. While it is on, the icon follows the color picker at once, because this view
    /// redraws whenever `settings` changes.
    private var highlightIcon: some View {
        markerIcon(organizationType: .club, color: Self.highlightIconColor(for: settings))
    }

    /// The color of `highlightIcon`: the chosen highlighting color while either highlighting toggle is on, else
    /// `plainMarkerColor`, as the maps then draw every club. Only one highlighting row is shown while one is on, so
    /// that row is the one that is on. A test checks that it matches the color highlighted clubs get on the maps.
    static func highlightIconColor(for settings: SettingsStruct) -> Color {
        let highlightIsUsed = settings.highlightFotobondNL || settings.highlightNonFotobondNL
        return highlightIsUsed ? settings.highlightColor.color : .plainMarkerColor
    }

    /// A map marker as a row's icon, so the rows together show what the maps show with the current settings: an
    /// organization type that is off has no marker. The color is chosen here, per row, to match `markerTint`.
    ///
    /// The marker is drawn over an invisible `mappin.square`, which gives it the size of an SF Symbol icon at
    /// `.title2`, so the labels line up with those of other Settings sections, also while the marker is not shown.
    /// The marker is shrunk to about that size.
    private func markerIcon(organizationType: OrganizationTypeEnum, color: Color, isGhost: Bool = false,
                            isShown: Bool = true) -> some View {
        Image(systemName: "mappin.square")
            .font(.title2)
            .hidden()
            .overlay {
                MapMarkerBalloonDrawing(organizationType: organizationType, color: color, isGhost: isGhost)
                    .scaleEffect(0.75)
                    .opacity(isShown ? 1 : 0) // keeps the space, so the label doesn't move
            }
            .accessibilityHidden(true) // decoration: the label and the toggle say it all to VoiceOver
    }
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
private struct SettingsOrganizationsPreviewHost: View {
    @StateObject var model = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                SettingsViewOrganizationsSection(settings: $model.settings)
            }
        }
    }
}

#Preview {
    SettingsOrganizationsPreviewHost()
}
