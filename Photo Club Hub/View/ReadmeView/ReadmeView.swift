//
//  ReadmeView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/03/2022.
//

import SwiftUI

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

// swiftlint:disable:next type_body_length
struct ReadmeView: View {

    fileprivate static let paddingConstant: CGFloat = 20
    fileprivate let title = String(localized: "Readme", table: "Readme", comment: "Title of Readme screen")
    fileprivate let comment = "Content of section §x.y of text on Readme screen"
    @Environment(\.dismiss) var dismiss: DismissAction // \.dismiss requires iOS 15
    @State fileprivate var showingRoadmap = false // controls visibility of Preferences screen
    @State fileprivate var selectedRoadmapDetent = PresentationDetent.large // careful: must be element of detentsList
    fileprivate var detentsList: Set<PresentationDetent> = [ .fraction(0.5), .fraction(0.70), .fraction(0.90), .large ]

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        Group {
                            SectionHeader(String(localized: "The App", comment: "Section title on Readme page"),
                                          geo: geo)

                            Section("§1.1", comment: "First paragraph in The-app section of Readme page", geo: geo)
                            Section("§1.2", comment: "Second paragraph in The-app section of Readme page", geo: geo)
                            Section("§1.3", comment: "Third paragraph in The-app section of Readme page", geo: geo)

                            Image("app_screenshots_EN")
                                .resizable()
                                .border(.gray, width: 1)
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, alignment: .center)
                            Text("Clubs, their Members, and their Portfolios\n",
                                 comment: "Caption of an image on the Readme page")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            Section("§1.4", comment: "Fourth section in The-app section of Readme page", geo: geo)
                            Section("§1.5", comment: "Fifth section in The-app section of Readme page", geo: geo)
                            Section("§1.6", comment: "Sixth section in The-app section of Readme page", geo: geo)
                        }

                        Group {
                            SectionHeader(String(localized: "The Concept", comment: "Section title on Readme page"),
                                                 geo: geo)

                            Section("§2.1", comment: "First section in Concept section of Readme page", geo: geo)
                            Section("§2.2", comment: "Second section in Concept section of Readme page", geo: geo)
                            Section("§2.3", comment: "Third section in Concept section of Readme page", geo: geo)
                            Section("§2.4", comment: "Fourth section in Concept section of Readme page", geo: geo)
                            Section("§2.5", comment: "Fifth section in Concept section of Readme page", geo: geo)

                            Image("Waalre_AppIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.4, alignment: .center)
                                .border(.gray, width: 1)
                            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                                    Text("App version \(version) (build \(build))",
                                         comment: "Shown on Readme page.")
                                    .font(.callout.italic())
                                    .frame(width: geo.size.width, alignment: .center)
                                    Text(verbatim: "")
                                }
                            }
                        }

                        Group {
                            SectionHeader(String(localized: "Features and Tips",
                                                 comment: "Section title on Readme page"),
                                          geo: geo)

                            Section("§3.1.a", comment: "Section 3.1.a of the Readme screen", geo: geo)
                            Section("§3.1.b", comment: "Section 3.1.b of the Readme screen", geo: geo)

                            Image("Localizations") // belongs to Section 3.1
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, alignment: .center)
                            Text("Part of the internal translation table",
                                 comment: "Caption of Localizations image on Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "")
                            Text(verbatim: "")

                            Section("§3.2.a", comment: "Section 3.2.a of the Readme screen", geo: geo)
                            Section("§3.2.b", comment: "Section 3.2.b of the Readme screen", geo: geo)

                            Image("3D_map") // belongs to Section 3.2
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, alignment: .center)
                                .border(.gray, width: 1)
                            Text("Maps can be viewed in 3D",
                                 comment: "Caption of 3D image on Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "")

                            Section("§3.3.a", comment: "Section 3.3.a of the Readme screen", geo: geo)
                            Section("§3.3.b", comment: "Section 3.3.b of the Readme screen", geo: geo)
                            Section("§3.3.c", comment: "Section 3.3.c of the Readme screen", geo: geo)

                            Section("§3.4.a", comment: "Section 3.4.a of the Readme screen", geo: geo)
                            Section("§3.4.b", comment: "Section 3.4.b of the Readme screen", geo: geo)
                            Section("§3.4.c", comment: "Section 3.4.c of the Readme screen", geo: geo)
                            Section("§3.4.d", comment: "Section 3.4.d of the Readme screen", geo: geo)

                            Section("§3.5.a", comment: "Section 3.5.a of the Readme screen", geo: geo)
                            Section("§3.5.b", comment: "Section 3.5.b of the Readme screen", geo: geo)
                            Section("§3.5.c", comment: "Section 3.5.b of the Readme screen", geo: geo)

                            Image("Maps") // belongs to Section 3.5
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, alignment: .center)
                                .border(.gray, width: 1)
                            Text("Amsterdam has two photography museums.",
                                 comment: "Caption of Museums image on Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "")

                            Section("§3.6.a", comment: "Section 3.6.a of the Readme screen", geo: geo)
                            Section("§3.6.b", comment: "Section 3.6.b of the Readme screen", geo: geo)

                            Section("§3.7.a", comment: "Section 3.7.a of the Readme screen", geo: geo)
                            Section("§3.7.b", comment: "Section 3.7.b of the Readme screen", geo: geo)

                            Image("Website")
                                .resizable()
                                .scaledToFit()
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width * 0.6, alignment: .center)
                            Text("Example of a link to a club web site",
                                 comment: "Caption of Websites image on Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "")

                            Section("§3.8.a", comment: "Section 3.8.a of the Readme screen", geo: geo)
                            Section("§3.8.b", comment: "Section 3.8.b of the Readme screen", geo: geo)
                            Section("§3.8.c", comment: "Section 3.8.c of the Readme screen", geo: geo)
                            Section("§3.8.d", comment: "Section 3.8.d of the Readme screen", geo: geo)
                            Section("§3.8.e", comment: "Section 3.8.e of the Readme screen", geo: geo)

                            Image("2021_FotogroepWaalre_058")
                                .resizable()
                                .frame(width: 250, height: 375, alignment: .center)
                                .scaledToFill()
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "© 2021 Greetje van Son\n")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            Section("§3.9.a", comment: "Section 3.9.a of the Readme screen", geo: geo)
                            Section("§3.9.b", comment: "Section 3.9.b of the Readme screen", geo: geo)
                            Section("§3.9.c", comment: "Section 3.9.b of the Readme screen", geo: geo)

                            Image("Preferences")
                                .resizable()
                                .border(.gray, width: 1)
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, height: 300, alignment: .center)
                            Text("The Preferences screen.",
                                 comment: "Caption of an image on the Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width * 0.8, alignment: .center)
                            Text(verbatim: "")

                            Section("§3.10.a", comment: "Section 3.10.a of the Readme screen", geo: geo)
                            Section("§3.10.b", comment: "Section 3.10.b of the Readme screen", geo: geo)
                            Section("§3.10.c", comment: "Section 3.10.c of the Readme screen", geo: geo)

                            Image("Play-button")
                                .resizable()
                                .border(.gray, width: 1)
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, height: 300, alignment: .center)
                            Text("Buttons for the automatic slide show",
                                 comment: "Caption about Play button on the Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width * 0.8, alignment: .center)
                            Text(verbatim: "")

                            Section("§3.11.a", comment: "Section 3.11.a of the Readme screen", geo: geo)
                            Section("§3.11.b", comment: "Section 3.11.b of the Readme screen", geo: geo,
                                      bottomPaddingAmount: 0)

                            Image("Search-bar")
                                .resizable()
                                .border(.gray, width: 1)
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, height: 260, alignment: .center)
                            Text("Search bar at the top of _Portfolios_ screen",
                                 comment: "Caption about Search Bar on the Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width * 0.8, alignment: .center)
                            Text(verbatim: "")

                            Section("§3.11.c", comment: "Section 3.11.c of the Readme screen", geo: geo)
                        }

                        Group {
                            SectionHeader(String(localized: "Supported Platforms",
                                                 comment: "Section title on Readme page"),
                                          geo: geo)

                            Section("§4.1", comment: "First section in Platforms section of Readme page", geo: geo)
                            Section("§4.2", comment: "Second section in Platforms section of Readme page", geo: geo)
                            Section("§4.3", comment: "Third section in Platforms section of Readme page", geo: geo)
                            Section("§4.4", comment: "Fourth section in Platforms section of Readme page", geo: geo)
                        }

                        Group {
                            SectionHeader(String(localized: "How you can help",
                                                 comment: "Section title on Readme page"),
                                          geo: geo)

                            Section("§5.1", comment: "First section in OpenSource section of Readme page", geo: geo)
                            Section("§5.2", comment: "Second section in OpenSource section of Readme page", geo: geo)

                            VStack {
                                Image("Bellus_Imago_Level_1")
                                    .resizable()
                                    .border(.gray, width: 1)
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.8, alignment: .center)
                                Text("Configuring Level 1 data for a Dutch photo club",
                                     comment: "Caption for image on Readme page")
                                    .font(.callout.italic())
                                    .frame(width: geo.size.width, alignment: .center)
                                Text(verbatim: "")
                            }

                            Section("§5.3", comment: "Third section in OpenSource section of Readme page", geo: geo)
                            Section("§5.4", comment: "Fourth section in OpenSource section of Readme page", geo: geo)
                            Section("§5.5", comment: "Fifth section in OpenSource section of Readme page", geo: geo,
                                      bottomPaddingAmount: 0)

                            VStack {
                                Image("Swift_enum")
                                    .resizable()
                                    .border(.gray, width: 1)
                                    .scaledToFit()
                                    .frame(width: geo.size.width * 0.8, alignment: .center)
                                Text("Fragment of the Swift source code", comment: "Caption for image on Readme page")
                                    .font(.callout.italic())
                                    .frame(width: geo.size.width, alignment: .center)
                                Text(verbatim: "")
                            }
                        }

                        SectionHeader("", geo: geo)

                    } // outer VStack

                } // ScrollView
                .navigationTitle(title)
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

    struct SectionHeader: View {
        let localizedString: String
        let geo: GeometryProxy

        // explicit init() used here just to suppress localizedStringKey argument label
        init(_ localizedString: String, geo: GeometryProxy) {
            self.localizedString = localizedString
            self.geo = geo
        }

        var body: some View {
            let boxCount: Int = UIDevice.isIPad ? 7 : 3 // number of boxes to left or right of chapter title
            let const1: CGFloat = 0.8
            let const2: CGFloat = 0.05
            let const3: CGFloat = const1 - const2 * CGFloat(boxCount - 1)

            HStack {
                ForEach(0..<boxCount, id: \.self) { integer in
                    Image(systemName: "square.fill")
                        .foregroundColor((boxCount-integer-1) % 3 == 0 ? .fgwBlue :
                                         (boxCount-integer-1) % 3 == 1 ? .fgwGreen : .fgwRed)
                        .scaleEffect(const3 + const2 * CGFloat(integer))
                }
                Text(localizedString) // can receive an empty string
                    .foregroundColor(.linkColor)
                    .allowsTightening(true)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                ForEach(0..<boxCount, id: \.self) { integer in
                    Image(systemName: "square.fill")
                        .foregroundColor(integer % 3 == 0 ? .fgwBlue :
                                         integer % 3 == 1 ? .fgwGreen : .fgwRed)
                        .scaleEffect(const1 - const2 * CGFloat(integer))
                }
            }
            .frame(width: geo.size.width * 0.9, height: 50, alignment: .center)
            .padding(Edge.Set([.horizontal]), paddingConstant)
        }
    }

    // struct to define some standard view modifiers for use in Readme paragraphs
    struct Section: View {
        var localizedStringKey: LocalizedStringKey
        let comment: StaticString
        let geo: GeometryProxy
        var bottomPaddingAmount: CGFloat // defaults to value of horizontal padding

        // explicit init() used here just to suppress localizedStringKey argument label
        init(_ localizedStringKey: String,
             comment: StaticString,
             geo: GeometryProxy,
             bottomPaddingAmount: CGFloat = paddingConstant) {
            self.localizedStringKey = LocalizedStringKey(localizedStringKey)
            self.comment = comment
            self.geo = geo
            self.bottomPaddingAmount = bottomPaddingAmount
        }

        var body: some View {
            Text(localizedStringKey, tableName: "Readme", comment: comment)
                .padding([.horizontal], paddingConstant)
                .padding([.bottom], bottomPaddingAmount)
                .frame(width: geo.size.width, alignment: .leading)
                .fixedSize() // magic to get Text to wrap
        }
    }

}

struct ReadmeView_Previews: PreviewProvider { // This preview actually works reliably (most don't, for some reason)
    @State static fileprivate var title = "Info Preview"

    static var previews: some View {
        ReadmeView()
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .previewInterfaceOrientation(.portrait)
    }
}
