//
//  NSPredicate+all.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 28/12/2022.
//

import Foundation

extension NSPredicate {

    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")

}
