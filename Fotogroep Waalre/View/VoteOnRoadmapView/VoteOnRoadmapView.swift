//
//  RoadmapView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/03/2023.
//

import SwiftUI
import Roadmap

struct VoteOnRoadmapView: View {
    let configuration = RoadmapConfiguration(
                            // could use an external URL(string: "https://simplejsoncms.com/api/vnlg2fq62s")!,
                            roadmapJSONURL: Bundle.main.url(forResource: "Roadmap", withExtension: "json")!,
                            namespace: Bundle.main.bundleIdentifier,
                            style: RoadmapStyle(icon: Image(systemName: "circle.square.fill"),
                                                titleFont: RoadmapTemplate.standard.style.titleFont.italic(),
                                                numberFont: RoadmapTemplate.standard.style.numberFont,
                                                statusFont: RoadmapTemplate.standard.style.statusFont,
                                                statusTintColor: lookupStatusTintColor, // closure
                                                cornerRadius: 10,
                                                cellColor: RoadmapTemplate.standard.style.cellColor, // cell background
                                                selectedColor: RoadmapTemplate.standard.style.selectedForegroundColor,
                                                tint: RoadmapTemplate.standard.style.tintColor), // voting icon
                            shuffledOrder: true,
                            allowVotes: true,
                            allowSearching: false)
    private let title = String(localized: "Vote on Roadmap Items", comment: "Title of Roadmap screen")
    @State var isCollapsed: Bool = true // overwritten in init()
    private var textFull = "" // overwritten in init()
    private var textCollapsed = "" // overwritten in init()

    init() {
        _isCollapsed = State(initialValue: UIDevice.isIPhone) // tricky to initialize an @State variable
        textFull = String(localized:
                          """
                          You can vote below on which roadmap items you would like to see. \
                          Please read the entire list before voting: you cannot undo a vote. \
                          Don't waste your vote by voting for almost all items: \
                          this is about prioritization rather than liking.
                          """,
                          comment: "Text at top of Roadmap screen")
        textCollapsed = textFull + " " + String(localized: "[ more ]",
                                                comment: "At end of text on Roadmap screen when text is truncated")
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text(isCollapsed ? textCollapsed : textFull)
                    .lineLimit(isCollapsed ? (UIDevice.isIPad ? 3 : 2) : 10) // don't waste non-scrolling iPhone space
                    .truncationMode(.middle)
                .onTapGesture {
                    isCollapsed.toggle()
                }
                .italic()
                .foregroundColor(.blue)
                .padding(.horizontal)
                RoadmapView(configuration: configuration)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(UIDevice.isIPhone ? .inline : .large)
        }
    }

    static func lookupStatusTintColor(string: String) -> Color {
        switch string.localizedLowercase {
        case "planned": return .plannedColor
        case "?": return .unplannedColor
        default: return Color.secondary
        }
    }

}

struct MyRoadmapView_Previews: PreviewProvider {
    @State static private var title = "MyRoadmapView_Preview"

    static var previews: some View {
        VoteOnRoadmapView()
            .navigationTitle(title)
    }
}
