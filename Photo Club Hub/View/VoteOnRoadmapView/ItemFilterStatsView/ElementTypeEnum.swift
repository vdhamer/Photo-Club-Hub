//
//  ElementTypeEnum.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 31/03/2024.
//

enum ElementTypeEnum: String {
    case photographer   // photographers (independent of any club context)
    case organization   // photography clubs or photo musea
    case club           // photography clubs
    case museum         // photo musea
    case member         // club members = photographers that are/were members of a particular club
}
