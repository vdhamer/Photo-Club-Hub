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
        roadmapJSONURL: URL(string: "https://simplejsoncms.com/api/u6i9frt5lfa")!,
        style: RoadmapTemplate.standard.style
    )
    private let title = String(localized: "Roadmap voting booth", comment: "Title of Roadmap screen")

    var body: some View {
        NavigationStack {
            VStack {
                RoadmapView(configuration: configuration)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(UIDevice.isIPhone ? .inline : .large)
        }
    }
}

struct MyRoadmapView_Previews: PreviewProvider {
    @State static private var title = "MyRoadmapView_Preview"

    static var previews: some View {
        MyRoadmapView()
            .navigationTitle(title)
    }
}
