//
//  MemberPortfolio+refreshFirstImage.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/10/2023.
//

import Foundation // for URL, URLSession, Data
import RegexBuilder // for OneOrMore, Capture, etc

extension MemberPortfolio {

    private static let clubsFullyUsingJuiceBox: [OrganizationID] = [ // careful: ID strings require an exact match
        OrganizationID(fullName: "Fotogroep de Gender", town: "Eindhoven")
    ]

    // if JuiceBox Pro is only used for former members
    private static let clubsPartiallyUsingJuiceBox: [OrganizationID] = [ // careful: ID strings require an exact match
        OrganizationID(fullName: "Fotogroep Waalre", town: "Waalre")
    ]

    public func refreshFirstImage() {

        if isUsingJuiceBox { return } // does this club use JuiceBox Pro's XML file for this member's portfolio?

        guard let urlOfImageIndex else { // nil should already have been ruled out by isUsingJuiceBox() and returning
            ifDebugFatalError("urlOfImageInex is nil")
            return
        }

        // assumes JuiceBox Pro is used
        ifDebugPrint("""
                     \(self.organization.fullNameTown): starting refreshFirstImage() \
                     \(urlOfImageIndex.absoluteString) in background
                     """)

        // swiftlint:disable:next large_tuple
        var results: (utfContent: Data?, urlResponse: URLResponse?, error: (any Error)?)? = (nil, nil, nil)
        results = URLSession.shared.synchronousDataTask(from: urlOfImageIndex)
        guard results != nil && results!.utfContent != nil else {
            print("""
                  \(organization.fullNameTown): ERROR - \
                  loading refreshFirstImage() \(urlOfImageIndex.absoluteString) failed
                  """)
            return
        }

        let xmlContent = String(data: results!.utfContent! as Data,
                                encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        parseXMLContent(xmlContent: xmlContent, member: self)
        ifDebugPrint("\(organization.fullNameTown): completed refreshFirstImage() \(urlOfImageIndex.absoluteString)")
    }

    private var isUsingJuiceBox: Bool {
        if urlOfImageIndex == nil { return false } // no data for finding JuiceBox XML file
        if MemberPortfolio.clubsFullyUsingJuiceBox.contains(organization.id) { return true }
        if MemberPortfolio.clubsPartiallyUsingJuiceBox.contains(organization.id) && isFormerMember { return true }
        return false
    }

    // remove a suffix like "#myanchor" if present, and append "config.xml"
    private var urlOfImageIndex: URL? {
        let url: URL? = URL(string: self.level3URL.absoluteString)
        guard let url else { return nil } // bad string

        guard let urlString = url.absoluteString.removingPercentEncoding else { return nil }
        if urlString.contains("#") { // force unwrap protected by guard
            let reducedString = urlString.components(separatedBy: "#")[0]
            guard let reducedURL = URL(string: String(reducedString)) else { return nil }
            return reducedURL.appendingPathComponent("config.xml")
        } else {
            return url.appendingPathComponent("config.xml")
        }
    }

    private func parseXMLContent(xmlContent: String, member: MemberPortfolio) { // sample data
        //    <?xml version="1.0" encoding="UTF-8"?>
        //    <juiceboxgallery
        //                 galleryTitlePosition="NONE"
        //                     showOverlayOnLoad="false"
        //                     :
        //                     imageTransitionType="CROSS_FADE"
        //         >
        //             <image imageURL="images/image1.jpg" thumbURL="thumbs/image1.jpg" linkURL="" linkTarget="_blank">
        //             <title><![CDATA[]]></title>
        //             <caption><![CDATA[2022]]></caption>
        //         </image>
        //             <image imageURL="images/image2.jpg" thumbURL="thumbs/image2.jpg" linkURL="" linkTarget="_blank">
        //             <title><![CDATA[]]></title>
        //             <caption><![CDATA[2022]]></caption>
        //     </juiceboxgallery>

        let regex = Regex {
            "<image imageURL=\""
            Capture {
                "images/"
                OneOrMore(.any, .reluctant)
            }
            "\"" // closing double quote
            OneOrMore(.horizontalWhitespace)
            "thumbURL=\""
            Capture {
                "thumbs/"
                OneOrMore(.any, .reluctant)
            }
            "\"" // closing double quote
        }

        guard let match = try? regex.firstMatch(in: xmlContent) else {
            print("\(organization.fullName): ERROR - could not find image in parseXMLContent() " +
                  "for \(member.photographer.fullNameFirstLast) in \(member.organization.fullName)")
            return
        }
        let (_, imageSuffix, thumbSuffix) = match.output
        let imageURL = URL(string: self.level3URL.absoluteString + imageSuffix)
        let thumbURL = URL(string: self.level3URL.absoluteString + thumbSuffix)

        if member.featuredImage != imageURL && imageURL != nil {
            member.featuredImage = imageURL // this is where it happens.
            print("\(organization.fullName): found new image \(imageURL!)")
        }
        if member.featuredImageThumbnail != thumbURL && thumbURL != nil {
            member.featuredImageThumbnail = thumbURL! // this is where it happens.
            print("\(organization.fullName): found new thumbnail \(thumbURL!)")
        }
    }

}
