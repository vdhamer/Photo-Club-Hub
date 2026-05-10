//
//  MemberListSectionHeader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/05/2026.
//

import SwiftUI

/// Centered capsule label used as a section header in the Members list.
/// Displays the club name inside a pill-shaped gradient capsule, centered and capped at 400 pt wide.
/// Used by both `FilteredMemberPortfoliosView2626` and `FilteredMemberPortfoliosView1718`.
struct MemberListSectionHeader: View {
    @Environment(\.colorScheme) private var colorScheme // to detect dark mode

    var title: String // club name identifying the section/club

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Capsule(style: .continuous)
                    .fill(Gradient(colors: [.gray.opacity(0.5),
                                            .gray.opacity(0.1),
                                            .gray.opacity(0.2),
                                            .gray.opacity(0.5)]))
                    .frame(maxWidth: 400, alignment: .center)
                Text(title) // String used to group the elements into Sections
                    .font(.title2)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
             }
            Spacer()
        }
    }
}

// MARK: - Previews

struct MemberListSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MemberListSectionHeader(title: "Fotogroep de Gender (Eindhoven)")
                .previewDisplayName("Normal club name")
            MemberListSectionHeader(title: "A Very Long Photo Club Name That Might Overflow The Capsule Width")
                .previewDisplayName("Long name (truncation)")
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .frame(height: 40)
    }
}
