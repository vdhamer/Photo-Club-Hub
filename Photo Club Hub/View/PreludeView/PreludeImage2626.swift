//
//  PreludeImage.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/11/2025.
//

@available(iOS 26.0, *)
struct PreludeImage2626 {
    let assetName: String // name in assets (e.g. "2021_FotogroepWaalre_058_square")
    let copyright: String // who made the image (e.g. "© Greetje van Son")
    var copyrightAlignment: PreludeAlignment = PreludeAlignment.bottomLeading
    let whiteCoordinates: OffsetVectorInCells2626 // where to find a pure white location
}

enum PreludeAlignment {
    case topTrailing
    case topLeading
    case bottomLeading
    case bottomTrailing

    var isLeading: Bool {
        switch self {
        case .topLeading, .bottomLeading:
            return true
        default:
            return false
        }
    }

    var isTrailing: Bool {
        switch self {
        case .topTrailing, .bottomTrailing:
            return true
        default:
            return false
        }
    }

    var isTop: Bool {
        switch self {
        case .topTrailing, .topLeading:
            return true
        default:
            return false
        }
    }

    var isBottom: Bool {
        switch self {
        case .bottomTrailing, .bottomLeading:
            return true
        default:
            return false
        }
    }

}
