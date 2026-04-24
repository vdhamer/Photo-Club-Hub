//
//  ReadmeView2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/03/2022.
//

import SwiftUI

@available(iOS 26.0, *)
struct ReadmeView2626: View {

    @Environment(\.dismiss) var dismiss: DismissAction
    @State private var showingRoadmap = false // controls visibility of Preferences screen

    static let paddingConstant: CGFloat = 20
    private let title = String(localized: "Readme",
                               table: "PhotoClubHub.Readme",
                               comment: "Title of Readme screen")

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ReadmeSectionOnApp2626(geo: geo)
                        ReadmeSectionOnConcept2626(geo: geo)
                        ReadmeSectionOnFeaturesAndTips2626(geo: geo)
                        ReadmeSectionOnSupportedPlatforms2626(geo: geo)
                        ReadmeSectionOnHowYouCanHelp2626(geo: geo)

                        SectionHeader2626(LocalizedStringResource("", table: "PhotoClubHub.Readme",
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
            .presentationSizing(.page)
        } // GeometryReader
    }

}

// MARK: - Preview

@available(iOS 26.0, *)
struct ReadmeView2626_Previews: PreviewProvider {
    @State static private var title = "Info Preview"

    static var previews: some View {
        ReadmeView2626()
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .previewInterfaceOrientation(.portrait)
    }
}
