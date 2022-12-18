//
//  Sounds.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 28/05/2022.
//

import AVFoundation

enum OpenClose {
    case open
    case close
}

func openCloseSound(openClose: OpenClose) {
    AudioServicesPlaySystemSound(openClose == .open ? 1100 : 1100)
}
