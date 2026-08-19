//
//  MemberListSectionHeader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/05/2026.
//

import SwiftUI

/// Centered capsule label used as a section header in the Members list.
/// Displays the club name inside a pill-shaped gradient capsule, centered and capped at 400 pt wide.
/// Used by both `FilteredMemberPortfoliosView2627` and `FilteredMemberPortfoliosView1718`.
struct MemberListSectionHeader: View {

    let title: String // club name identifying the section/club

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
                    .background(.bar)
                Text(verbatim: title) // String used to group the elements into Sections
                    .font(.title2)
                    .lineLimit(1)
                    .foregroundStyle(Color.primary)   // Color.primary, not the hierarchical .primary
                    .padding(.horizontal)
             }
            Spacer()
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Previews actually work.

#Preview("In a plain List (as shipped)") {
    List {
        Section {
            Text(verbatim: "Jan Jansen")
            Text(verbatim: "Piet Pietersen")
        } header: {
            MemberListSectionHeader(title: "Fotogroep de Gender (Eindhoven)")
        }
    }
    .listStyle(.plain)
}

#Preview("Normal club name", traits: .sizeThatFitsLayout) {
    MemberListSectionHeader(title: "Fotogroep de Gender (Eindhoven)")
        .padding()
        .frame(height: 40)
}

#Preview("Long name (truncation)", traits: .sizeThatFitsLayout) {
    MemberListSectionHeader(title: "A Very Long Photo Club Name That Might Overflow The Capsule Width")
        .padding()
        .frame(height: 40)
}
