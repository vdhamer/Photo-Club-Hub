//
//  RoadmapView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/03/2023.
//

import SwiftUI
import Roadmap

struct VoteOnRoadmapView: View {
    static let useOnlineList = true // online allows updates, but avoids confusion if device is offline

    let configuration = RoadmapConfiguration(
                            roadmapJSONURL: VoteOnRoadmapView.useOnlineList ? // JSON file with list of features
                                URL(string: "https://simplejsoncms.com/api/vnlg2fq62s")! : // password protected
                                Bundle.main.url(forResource: "Roadmap",
                                                withExtension: "json")!,
                            voter: CustomVoter(namespace: "com.vdhamer.photo_clubs_vote_on_features"),
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
                            allowSearching: true)

    private let title = String(localized: "Roadmap Items", comment: "Title of Roadmap screen")
    private let headerText = String(localized:
                              """
                              You can vote here on roadmap items that you would like to see. \
                              Please read the entire list before voting bacause you cannot undo a vote. \
                              Don't vote for more than half the items: the data helps us \
                              prioritize (this isn't about \"liking\" individual items).
                              """,
                              comment: "Text at top of Roadmap screen")

    var body: some View {
        NavigationStack {
            RoadmapView(configuration: configuration, header: {
                Text(headerText)
                    .italic()
                    .font(.callout)
                    .foregroundColor(.blue)
            })
                .navigationTitle(title)
        }
    }

    static func lookupStatusTintColor(string: String) -> Color {
        let planned = String(localized: "planned", comment: "Status string to indicated that roadmap item is planned.")
        let unplanned = String(localized: "?", comment: "Status string to indicated that roadmap item is not planned.")

        switch string.localizedLowercase { // string is already localized using JSON file before it gets here &^%$
        case "planned": return .plannedColor
        case "?": return .unplannedColor
        default: return Color.secondary
        }
    }

}

// CustomVoter is a wrapper around the default voter used by the Roadmap package
private struct CustomVoter: FeatureVoter {

    private let defaultVoter: FeatureVoterCountAPI

    init(namespace: String) {
        defaultVoter = FeatureVoterCountAPI(namespace: namespace)
    }

    func fetch(for feature: Roadmap.RoadmapFeature) async -> Int {
        await defaultVoter.fetch(for: feature)
    }

    func vote(for feature: Roadmap.RoadmapFeature) async -> Int? {
        await defaultVoter.vote(for: feature)
    }

}

struct MyRoadmapView_Previews: PreviewProvider {
    @State static private var title = "MyRoadmapView_Preview"

    static var previews: some View {
        VoteOnRoadmapView()
            .navigationTitle(title)
    }
}
