//
//  MemberPortfolio+refreshFirstImage.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/10/2023.
//

import Foundation // for URL, URLSession, Data
import RegexBuilder // for OneOrMore, Capture, etc

extension MemberPortfolio {

    func refreshFirstImage() {
        let clubsUsingJuiceBox: [OrganizationID] = [ // strings have to be precise ;-)
            OrganizationID(fullName: "Fotogroep Waalre", town: "Waalre"),
            OrganizationID(fullName: "Fotogroep de Gender", town: "Eindhoven")
        ]
        guard clubsUsingJuiceBox.contains(organization.id) else { return }
        let organizationTown: String = self.organization.fullNameTown

        if let urlIndex = URL(string: self.level3URL.absoluteString + "config.xml") { // assume JuiceBox Pro
            ifDebugPrint("\(organizationTown): starting refreshFirstImage() \(urlIndex.absoluteString) in background")

            // swiftlint:disable:next large_tuple
            var results: (utfContent: Data?, urlResponse: URLResponse?, error: (any Error)?)? = (nil, nil, nil)
            results = URLSession.shared.synchronousDataTask(from: urlIndex)
            guard results != nil && results!.utfContent != nil else {
                print("\(organizationTown): ERROR - loading refreshFirstImage() \(urlIndex.absoluteString) failed")
                return
            }

            let xmlContent = String(data: results!.utfContent! as Data,
                                    encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseXMLContent(xmlContent: xmlContent, member: self)
            ifDebugPrint("\(organizationTown): completed refreshFirstImage() \(urlIndex.absoluteString)")
        }
    }

    fileprivate func parseXMLContent(xmlContent: String, member: MemberPortfolio) { // sample data
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
            member.featuredImageThumbnail = thumbURL // this is where it happens.
            print("\(organization.fullName): found new thumbnail \(thumbURL!)")
        }
    }

}
