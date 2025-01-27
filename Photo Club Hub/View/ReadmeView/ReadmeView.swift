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
    fileprivate let comment: StaticString = "§x.y is subsection y of section x of text on Readme screen"
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

                            ReadmeSection("§1.1", comment: comment, geo: geo)
                            ReadmeSection("§1.2", comment: comment, geo: geo)
                            ReadmeSection("§1.3", comment: comment, geo: geo)

                            Image("app_screenshots_EN")
                                .resizable()
                                .border(.gray, width: 1)
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, alignment: .center)
                            Text("Clubs, their Members, and their Portfolios\n",
                                 comment: "Caption of an image on the Readme page")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            ReadmeSection("§1.4", comment: comment, geo: geo)
                            ReadmeSection("§1.5", comment: comment, geo: geo)
                            ReadmeSection("§1.6", comment: comment, geo: geo)
                        }

                        Group {
                            SectionHeader(String(localized: "The Concept", comment: "Section title on Readme page"),
                                                 geo: geo)

                            ReadmeSection("§2.1", comment: comment, geo: geo)
                            ReadmeSection("§2.2", comment: comment, geo: geo)
                            ReadmeSection("§2.3", comment: comment, geo: geo)
                            ReadmeSection("§2.4", comment: comment, geo: geo)
                            ReadmeSection("§2.5", comment: comment, geo: geo)

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

                            ReadmeSection("§3.1.a", comment: comment, geo: geo)
                            ReadmeSection("§3.1.b", comment: comment, geo: geo)

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

                            ReadmeSection("§3.2.a", comment: comment, geo: geo)
                            ReadmeSection("§3.2.b", comment: comment, geo: geo)

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

                            ReadmeSection("§3.3.a", comment: comment, geo: geo)
                            ReadmeSection("§3.3.b", comment: comment, geo: geo)
                            ReadmeSection("§3.3.c", comment: comment, geo: geo)

                            ReadmeSection("§3.4.a", comment: comment, geo: geo)
                            ReadmeSection("§3.4.b", comment: comment, geo: geo)
                            ReadmeSection("§3.4.c", comment: comment, geo: geo)
                            ReadmeSection("§3.4.d", comment: comment, geo: geo)

                            ReadmeSection("§3.5.a", comment: comment, geo: geo)
                            ReadmeSection("§3.5.b", comment: comment, geo: geo)
                            ReadmeSection("§3.5.c", comment: comment, geo: geo)

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

                            ReadmeSection("§3.6.a", comment: comment, geo: geo)
                            ReadmeSection("§3.6.b", comment: comment, geo: geo)

                            ReadmeSection("§3.7.a", comment: comment, geo: geo)
                            ReadmeSection("§3.7.b", comment: comment, geo: geo)

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

                            ReadmeSection("§3.8.a", comment: comment, geo: geo)
                            ReadmeSection("§3.8.b", comment: comment, geo: geo)
                            ReadmeSection("§3.8.c", comment: comment, geo: geo)
                            ReadmeSection("§3.8.d", comment: comment, geo: geo)
                            ReadmeSection("§3.8.e", comment: comment, geo: geo)

                            Image("2021_FotogroepWaalre_058")
                                .resizable()
                                .frame(width: 250, height: 375, alignment: .center)
                                .scaledToFill()
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "© 2021 Greetje van Son\n")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            ReadmeSection("§3.9.a", comment: comment, geo: geo)
                            ReadmeSection("§3.9.b", comment: comment, geo: geo)
                            ReadmeSection("§3.9.c", comment: comment, geo: geo)

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

                            ReadmeSection("§3.10.a", comment: comment, geo: geo)
                            ReadmeSection("§3.10.b", comment: comment, geo: geo)
                            ReadmeSection("§3.10.c", comment: comment, geo: geo)

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

                            ReadmeSection("§3.11.a", comment: comment, geo: geo)
                            ReadmeSection("§3.11.b", comment: comment, geo: geo,
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

                            ReadmeSection("§3.11.c", comment: comment, geo: geo)
                        }

                        Group {
                            SectionHeader(String(localized: "Supported Platforms",
                                                 comment: "Section title on Readme page"),
                                          geo: geo)

                            ReadmeSection("§4.1", comment: comment, geo: geo)
                            ReadmeSection("§4.2", comment: comment, geo: geo)
                            ReadmeSection("§4.3", comment: comment, geo: geo)
                            ReadmeSection("§4.4", comment: comment, geo: geo)
                        }

                        Group {
                            SectionHeader(String(localized: "How you can help",
                                                 comment: "Section title on Readme page"),
                                          geo: geo)

                            ReadmeSection("§5.1", comment: comment, geo: geo)
                            ReadmeSection("§5.2", comment: comment, geo: geo)

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

                            ReadmeSection("§5.3", comment: comment, geo: geo)
                            ReadmeSection("§5.4", comment: comment, geo: geo)
                            ReadmeSection("§5.5", comment: comment, geo: geo,
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
    struct ReadmeSection: View {
        private var localizedStringKey: LocalizedStringKey
        private let comment: StaticString
        private let geo: GeometryProxy
        private var bottomPaddingAmount: CGFloat // defaults to value of horizontal padding

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
