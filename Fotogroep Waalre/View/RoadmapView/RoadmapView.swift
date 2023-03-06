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

    var body: some View {
        RoadmapView(configuration: configuration)
    }
}
