//
//  ReadmeButton.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/07/2026.
//

import SwiftUI

/// Toolbar button (info icon) that presents the built-in Readme in a sheet.
///
/// Hosted on the People, Clubs and Organizations tabs (not on Settings).
/// Each instance owns its own sheet visibility state, but the selected sheet detent is
/// shared across all instances (and across app launches) via UserDefaults.
struct ReadmeButton: View {

    let fractionNonLarge: CGFloat = 0.70

    /// Available sheet detents for the Readme sheet. Only has impact on iPhone, not on iPad.
    private let detentsList: Set<PresentationDetent>

    // init() only define value of franctionNonLarge in a single location (it is used twice)
    init() {
        detentsList = [.large, .fraction(fractionNonLarge)] // we only support .large and one numeric value
    }

    /// Controls visibility of the Readme sheet.
    @State private var showingReadme = false

    /// Persisted detent choice: all ReadmeButton instances read/write the same UserDefaults key.
    @AppStorage("readmeDetentIsLarge") private var readmeDetentIsLarge = false

    /// Maps the persisted Bool onto the `PresentationDetent` type that `presentationDetents()` needs.
    private var selectedReadmeDetent: Binding<PresentationDetent> {
        Binding(
            get: { readmeDetentIsLarge ? .large : .fraction(fractionNonLarge) },
            set: { readmeDetentIsLarge = ($0 == .large) }
        )
    }

    var body: some View {
        Button(String(localized: "Built-in Readme",
                      table: "PhotoClubHub.SwiftUI",
                      comment: "Toolbar button (info icon) that opens the built-in Readme sheet"),
               systemImage: "info.circle") {
            showingReadme = true
        }
        .font(.title)
        .foregroundStyle(.linkColor)
        // Readme sheet with shared detents and visual presentation options.
        .sheet(isPresented: $showingReadme, content: {
            ReadmeView()
            // the detents don't do anything on an iPad
                .presentationDetents(detentsList, selection: selectedReadmeDetent)
                .presentationBackground(.thickMaterial) // don't know if this really works
                .presentationCornerRadius(40)
                .presentationDragIndicator(.visible) // show drag indicator
        })
    }

}

// MARK: - Preview

// Believe it or not, this preview works.

#Preview {
    NavigationStack {
        Text(verbatim: "Tap the (i) button")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ReadmeButton()
                }
            }
    }
}
