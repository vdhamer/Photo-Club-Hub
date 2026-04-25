//
//  ReadmeView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/03/2022.
//

import SwiftUI

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

@available(iOS, obsoleted: 19.0, message: "Please use 'ReadmeView2626' for versions about iOS 18.x")
struct ReadmeView1718: View {

    private let title = String(localized: "Readme", table: "PhotoClubHub.Readme", comment: "Title of Readme screen")
    @Environment(\.dismiss) var dismiss: DismissAction // \.dismiss requires iOS 15
    @State private var showingRoadmap = false // controls visibility of Preferences screen
    @State private var selectedRoadmapDetent = PresentationDetent.large // careful: must be element of detentsList
    private var detentsList: Set<PresentationDetent> = [ .fraction(0.5), .fraction(0.70), .fraction(0.90), .large ]

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ReadmeSectionOnApp1718(geo: geo)
                        ReadmeSectionOnConcept1718(geo: geo)
                        ReadmeSectionOnFeaturesAndTips1718(geo: geo)
                        ReadmeSectionOnSupportedPlatforms1718(geo: geo)
                        ReadmeSectionOnHowYouCanHelp1718(geo: geo)

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

@available(iOS, obsoleted: 19.0, message: "Please use 'ReadmeView2626_Previews' for versions about iOS 18.x")
struct ReadmeView1718_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        ReadmeView1718()
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .previewInterfaceOrientation(.portrait)
    }
}
