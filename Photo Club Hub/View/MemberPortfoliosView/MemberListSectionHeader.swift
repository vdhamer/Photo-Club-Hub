//
//  MemberListSectionHeader.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/05/2026.
//

import SwiftUI

/// Centered capsule label used as a section header in the Members list.
/// Displays the club name inside a pill-shaped capsule, centered and capped at 400 pt wide,
/// with any trailing "(town)" set one font size smaller than the club name itself.
/// Used by `FilteredMemberPortfoliosView` as the `header` of each club's `Section`.
///
/// Minor differences between the iOS 26 and 17/18 versions are handled by logic rather than having 2 file copies:
/// - on iOS 26+ the capsule is Liquid Glass tinted with the Clubs tab color, while
/// - iOS 17/18 gets a gradient of system fill colors.
struct MemberListSectionHeader: View {

    let title: String // club name identifying the section/club

    /// Splits `title` into the club name and, when present, the trailing `" (town)"`.
    ///
    /// `title` is `Organization.fullNameTown`, which appends `" (town)"` *only* when the club name
    /// does not already name its own town ("Fotogroep Waalre" in Waalre stays unsuffixed, while
    /// "Fotogroep Aalst" in Waalre becomes "Fotogroep Aalst (Waalre)"). So the suffix is optional,
    /// and a title without one is left entirely as the name.
    ///
    /// This re-splits a string the Data package composed. Passing name and town down separately
    /// would be cleaner, but the caller deliberately holds only the section id: reaching back to
    /// `organization_` traps on a row deleted mid-scroll (#802).
    private var titleParts: (name: String, town: String?) {
        guard title.hasSuffix(")"),
              let openParen = title.range(of: " (", options: .backwards) else { return (title, nil) }
        return (String(title[title.startIndex..<openParen.lowerBound]), String(title[openParen.lowerBound...]))
    }

    /// The club name at `.title2` with any `" (town)"` one step smaller at `.title3`.
    ///
    /// Concatenating with `+` keeps this a single `Text`, so `lineLimit`, wrapping and
    /// `multilineTextAlignment` still apply across both parts. Neither part sets a color: the
    /// whole label takes `Color.primary` from `body`.
    private var styledTitle: Text {
        let parts = titleParts
        let name = Text(verbatim: parts.name).font(.title2)
        guard let town = parts.town else { return name }
        return name + Text(verbatim: town).font(.title3)
    }

    var body: some View {
        HStack {
            Spacer()
            styledTitle // club name identifying the section, with any "(town)" a size smaller
                .lineLimit(2) // overflows to 2 lines when needed
                .multilineTextAlignment(.center) // centers line 2 under line 1; .frame() alignment doesn't
                .foregroundStyle(Color.primary)   // Color.primary, not the hierarchical .primary
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .frame(maxWidth: 400, alignment: .center) // grows to the row width, capped at 400 pt
                .capsuleFill()
            Spacer()
        }
            .frame(maxWidth: .infinity)
            .headerBackdrop()
            .accessibilityAddTraits(.isHeader) // lets VoiceOver's rotor jump from club to club
    }
}

private extension View {

    /// Draws the pill behind the club name.
    ///
    /// `.clubsColor` is a fixed bright orange (#FF8000) in both light and dark mode. At full
    /// strength the pill is too vivid on device, so the tint is held back to 70%: the pill lightens
    /// towards the page in light mode and darkens towards it in dark mode, which also lets the
    /// label color stay legible on both (black on #FFA54C, white on #B25900).
    ///
    /// The iOS 17/18 pill is instead built from system fill colors, which - unlike `Color.gray` -
    /// adapt to dark mode and to the Increase Contrast setting.
    @ViewBuilder
    func capsuleFill() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular.tint(.clubsColor.opacity(0.7)), in: .capsule)
        } else {
            self.background(Gradient(colors: [Color(.secondarySystemFill),
                                              Color(.quaternarySystemFill),
                                              Color(.tertiarySystemFill),
                                              Color(.secondarySystemFill)]),
                            in: Capsule(style: .continuous))
        }
    }

    /// `MemberPortfolioView` uses `.listStyle(.plain)`, which pins section headers while the rows
    /// scroll past them. The iOS 17/18 gradient is partially transparent, so it needs an opaque-ish
    /// backdrop to stop member names showing through. Liquid Glass needs no such help: refracting
    /// the content that passes behind it is the point of the material.
    @ViewBuilder
    func headerBackdrop() -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            self.background(.bar)
        }
    }

}

// MARK: - Previews

// Believe it or not, the following Previews actually work.

/// Reproduces the context the header actually ships in: the `header` of a `Section` in a
/// `.plain` List. Rendering the header on its own is misleading, because a standalone `Shape`
/// sizes itself differently and `List` supplies its own foreground style to section headers.
private struct HeaderInPlainList: View {
    let title: String

    var body: some View {
        List {
            Section {
                Text(verbatim: "Jan Jansen")
                Text(verbatim: "Piet Pietersen")
            } header: {
                MemberListSectionHeader(title: title)
            }
        }
            .listStyle(.plain) // as used by MemberPortfolioView, which pins the header while scrolling
    }
}

#Preview("Light mode") {
    HeaderInPlainList(title: "Fotogroep de Gender (Eindhoven)")
        .preferredColorScheme(.light)
}

#Preview("Dark mode") {
    HeaderInPlainList(title: "Fotogroep de Gender (Eindhoven)")
        .preferredColorScheme(.dark)
}

#Preview("Long name (wraps to 2 lines)") {
    HeaderInPlainList(title: "A Very Long Photo Club Name That Might Overflow The Capsule Width (Istanbul)")
}

/// The other branch of `titleParts`: `fullNameTown` omits the town when the club name already
/// contains it, so there is no "(town)" to shrink and the whole title stays at `.title2`.
#Preview("No town suffix") {
    HeaderInPlainList(title: "Fotogroep Waalre")
}
