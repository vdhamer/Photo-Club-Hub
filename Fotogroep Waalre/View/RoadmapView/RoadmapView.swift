//
//  RoadmapView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/03/2023.
//

import SwiftUI
import Roadmap

struct MyRoadmapView: View {
    let configuration = RoadmapConfiguration(
        roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/u6i9frt5lfa")!
    )
    private let title = String(localized: "Roadmap", comment: "Title of Roadmap screen")

    var body: some View {
//        NavigationStack { TODO
//            ScrollView(.vertical, showsIndicators: true) {
                RoadmapView(configuration: configuration)
//            }
//                .navigationTitle(title)
//                .navigationBarTitleDisplayMode(UIDevice.isIPhone ? .inline : .large)
//        }
    }
}
