//
//  NSPredicate+all.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/12/2022.
//

import Foundation

extension NSPredicate {

    static let all = NSPredicate(format: "TRUEPREDICATE")
    static let none = NSPredicate(format: "FALSEPREDICATE")

}
