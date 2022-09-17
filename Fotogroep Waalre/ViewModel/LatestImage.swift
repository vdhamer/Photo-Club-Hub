//
//  LatestImage.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 11/09/2022.
//

import Foundation
import UIKit

///////////////////////////////////////////////////////////////////////////////////////////
// MARK: - add URL to a recent image for each member

// typical content of https://www.fotogroepwaalre.nl/fotos/Ariejan_van_Twisk/config.xml

// <juiceboxgallery galleryTitlePosition="NONE" captionPosition="BELOW_IMAGE"
//  enableAutoPlay="true" showAutoPlayButton="true" enableDirectLinks="true"
//  showImageNumber="false" splashShowImageCount="false" backButtonUrl="https://www.fotogroepwaalre.nl/leden"
//  displayTime="3.5" showNavButtons="true" showSplashPage="NEVER" captionBackColor="rgba(0,0,0,0)"
//  buttonBarPosition="TOP" textColor="rgba(255,255,255,0.25)" imageTransitionTime="0.5" stagePadding="9"
//  captionHAlign="CENTER" imagePreloading="NEXT" showSmallThumbsButton="false" galleryTitleHAlign="CENTER"
//  topAreaHeight="0" backButtonPosition="TOP" useFullscreenExpand="true" backButtonUseIcon="true"
//  imageCornerRadius="10" showOpenButton="false" maxCaptionHeight="30" imageTransitionType="CROSS_FADE">
//
// <image imageURL="images/2016_Bondsfotowedstrijd_06.jpg"
//  thumbURL="thumbs/2016_Bondsfotowedstrijd_06.jpg"
//  linkURL="" linkTarget="_blank"><title></title>
//  <caption>2015</caption>
// </image>

func parseImageListForGallery(urlSession: URLSession, givenName: String, familyName: String,
                              targetCount: Int, reloadData: Bool) {
    // this function can't return anything because it runs as an asynchronous task
    for (index, member) in members[section.rawValue].enumerated() { // find member
        if member[GIVENNAMEKEY] == givenName && member[FAMILYNAMEKEY] == familyName {
            if member[INTERNALURLKEY] == nil {
                print("Missing URL for internal photo gallery found for \(givenName) \(familyName)")
                return
            }
            if member[FIRSTIMAGEURLKEY] != nil {
                return // no point in running this func twice
            }

            let urlIndex: URL = URL(string: member[INTERNALURLKEY]!+"config.xml")! // fetch config file for JuiceBox Pro
            let request = NSMutableURLRequest(url: urlIndex)
            // let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            let task = urlSession.dataTask(with: request as URLRequest) { (data, _, error) in
                // completion handler
                if error != nil {
                    print(error as Any)
                } else {
                    if let utfContent = data { // e.g. no internet connection
                        let xmlContent = NSString(data: utfContent, encoding: String.Encoding.utf8.rawValue)! as String
                        let REGEX: String = "<image imageURL=\"(images\\/[^\"]*)\"" // get first image tag in XML file
                        var imageCount: Int = 0

                        xmlContent.enumerateLines(invoking: { (line, _) in
                            let relativePath: [String] = line.capturedGroups(withRegex: REGEX)
                            if relativePath.count>0 {
                                imageCount += 1
                                if imageCount == targetCount {
                                    let imageURL = URL(string: member[INTERNALURLKEY]! + relativePath[0])!
                                    let newURL = imageURL.absoluteString
                                    self.members[section.rawValue][index][FIRSTIMAGEURLKEY] = newURL
                                }
                            }
                        })
                        self.members[section.rawValue][index][IMAGECOUNTKEY] = String(imageCount)
                        print("Finished parsing gallery config.xml file for " +
                              "\(givenName) \(familyName) (\(imageCount) images)")
                        if reloadData {
                            self.memberTable.performSelector(onMainThread: #selector(UICollectionView.reloadData),
                                                             with: nil, waitUntilDone: true)
                            print("Refreshing display via reloadData()")
                        }
                    } else {
                        print("failed to access URL. Error: \(String(describing: error))")
                        self.displayAlert(title: NSLocalizedString("Internet connection required",
                                                                   comment: "Used in pop-up message"),
                                          message: "", buttons: ["OK": UIAlertAction.Style.cancel])
                    }
                }
            }
            task.resume() // note info.plist extended for NSAppTransportSecurity/NSAllowsArbitraryLoads

        }
    }
}
