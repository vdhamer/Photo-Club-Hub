//
//  String+paths.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/07/2022.
//

import Foundation

extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
