//
//  UIDevice+IsIPad.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/04/2022.
//

import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
