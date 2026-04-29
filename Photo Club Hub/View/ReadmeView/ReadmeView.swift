//
//  ReadmeView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/03/2022.
//

import SwiftUI

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

struct ReadmeView: View {

    @Environment(\.dismiss) var dismiss: DismissAction
    @State private var showingRoadmap = false // controls visibility of Preferences screen

    private let title = String(localized: "Readme",
                               table: "PhotoClubHub.Readme",
                               comment: "Title of Readme screen")

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ReadmeSectionOnApp(geo: geo)
                        ReadmeSectionOnConcept(geo: geo)
                        ReadmeSectionOnFeaturesAndTips(geo: geo)
                        ReadmeSectionOnSupportedPlatforms(geo: geo)
                        ReadmeSectionOnHowYouCanHelp(geo: geo)

                        ReadmeSectionHeader(LocalizedStringResource("",
                                                              table: "PhotoClubHub.Readme",
                                                              comment: "Empty section header"),
                                      geo: geo)

                    } // outer VStack

                } // ScrollView
                .navigationTitle(title)
                .toolbar { // toolbar is not essential but added because PreferenceView needed one
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Done",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Close button for dismissing Readme view")
                        ) {
                            dismiss()
                        }
                        .buttonStyle(BorderedButtonStyle()) // ternary operator doesn't work here
                    }
                }
            }
            .padding(.init(top: 0, leading: 0, bottom: 15, trailing: 0))
            .apply {
                if #available(iOS 18.0, *) {
                    $0.presentationSizing(.page)
                } else {
                    $0
                }
            }
        } // GeometryReader
    }

}

// MARK: - Preview

// Believe it or not, the following Preview actually works
struct ReadmeView_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        ReadmeView()
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .previewInterfaceOrientation(.portrait)
    }
}
