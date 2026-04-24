//
//  ReadmeSectionOnSupportedPlatforms.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

struct ReadmeSectionOnSupportedPlatforms: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ReadmeSectionOnSupportedPlatforms()
}
