//
//  RoadmapView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/03/2023.
//

import SwiftUI
import Roadmap

struct VoteOnRoadmapView: View {
    var useOnlineList: Bool // using online allows updates, but gives empty page if device is offline

    private let title = String(localized: "Roadmap Items",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Title of Roadmap screen")
    private let headerText = String(localized:
                                        """
                                        You can vote here on which roadmap items you would like to see. \
                                        Please read the entire list before voting bacause you cannot undo a vote. \
                                        Don't vote for more than half the items: the data helps us \
                                        prioritize (this isn't about \"liking\" individual items).
                                        """,
                                        table: "PhotoClubHub.SwiftUI",
                                        comment: "Instructions at top of Roadmap screen")

    var configuration: RoadmapConfiguration? // nil gets overwritten during init(). Initialization needs access to self.

    init(useOnlineList: Bool) {
        self.useOnlineList = useOnlineList
        configuration = RoadmapConfiguration(
            roadmapJSONURL: useOnlineList ? // JSON file with list of features
                            URL(string: "https://simplejsoncms.com/api/vnlg2fq62s")! : // password protected
                            Bundle.main.url(forResource: "Roadmap", withExtension: "json")!,
            voter: FeatureVoterCountAPI(namespace: "com.vdhamer.photo_clubs_vote_on_features"),
            style: RoadmapStyle(icon: Image(systemName: "circle.square.fill"),
                                titleFont: RoadmapTemplate.standard.style.titleFont.italic(),
                                numberFont: RoadmapTemplate.standard.style.numberFont,
                                statusFont: RoadmapTemplate.standard.style.statusFont,
                                statusTintColor: lookupStatusTintColor, // function name
                                cornerRadius: 10,
                                cellColor: RoadmapTemplate.standard.style.cellColor, // cell background
                                selectedColor: RoadmapTemplate.standard.style.selectedForegroundColor,
                                tint: RoadmapTemplate.standard.style.tintColor), // voting icon
            shuffledOrder: true,
            allowVotes: true,
            allowSearching: true
        )
    }

    var body: some View {
        NavigationStack {
            RoadmapView(configuration: configuration!, header: {
                Text(headerText)
                    .italic()
                    .font(.callout)
                    .foregroundColor(.blue)
            })
                .navigationTitle(title)
        }
    }

    private func lookupStatusTintColor(string: String) -> Color {
        switch string.lowercased() { // string should be unlocalized version as defined in Roadmap.json file
        case "planned": return .plannedColor
        case "?": return .unplannedColor
        default: return Color.red
        }
    }

}

struct VoteOnRoadmapView_Previews: PreviewProvider {
    @State static private var title = "VoteOnRoadmapView_Preview"

    static var previews: some View {
        VoteOnRoadmapView(useOnlineList: false)
            .navigationTitle(title)
    }
}
