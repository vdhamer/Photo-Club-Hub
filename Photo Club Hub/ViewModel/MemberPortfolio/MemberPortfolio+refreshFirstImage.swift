//
//  MemberPortfolio+refreshFirstImage.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 20/10/2023.
//

import Foundation // for URL, URLSession, Data
import RegexBuilder // for OneOrMore, Capture, etc

extension MemberPortfolio {

    func refreshFirstImage() {
        let organizationTown: String = self.organization.fullNameTown
        guard organizationTown == "Fotogroep Waalre" else { return }

        if let urlIndex = URL(string: self.website.absoluteString + "config.xml") { // assume JuiceBox Pro
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
        let imageURL = URL(string: self.website.absoluteString + imageSuffix)
        let thumbURL = URL(string: self.website.absoluteString + thumbSuffix)

        if member.latestImageURL != imageURL && imageURL != nil {
            member.latestImageURL = imageURL // this is where it happens. Note that there is context.save()
            print("\(organization.fullName): found new image \(imageURL!)")
        }
        if member.latestThumbURL != thumbURL && thumbURL != nil {
            member.latestThumbURL = thumbURL // this is where it happens. Note that there is context.save()
            print("\(organization.fullName): found new thumbnail \(thumbURL!)")
        }
    }

}
