//
//  View+OnTapGesture.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/03/2022.
//

import SwiftUI

// https://stackoverflow.com/questions/56513942/how-to-detect-a-tap-gesture-location-in-swiftui/69759653#69759653

struct OnTap: ViewModifier {
    let response: (CGPoint) -> Void
    @State private var location: CGPoint = .zero

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                response(location)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { location = $0.location }
            )
    }
}

extension View {
    func onTapGesture(_ handler: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(OnTap(response: handler))
    }
}
