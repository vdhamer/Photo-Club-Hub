//
//  OrganizationViewRemark.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View

/// Remark describing club or museum (is a bit tricky due to unpredictable length).
@MainActor
struct OrganizationViewRemark: View {

    let localizedRemark: String

    init(organization: Organization) { // higher level initializer for production
        localizedRemark = organization.localizedRemark
    }

    fileprivate init(localizedRemark: String) { // lower level initializer used by preview
        self.localizedRemark = localizedRemark
    }

    var body: some View {
        if #available(iOS 26, *) {
            Text(localizedRemark) // display remark in preferred language (if possible)
                .padding(.top, 5)
                .font(.footnote)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .frame(height: 40)
        } else if #available(iOS 18, *) {
            Text(localizedRemark) // display remark in preferred language (if possible)
                .padding(.top, 5)
        } else { // iOS 17 - we don't support older versions
            Text(localizedRemark) // display remark in preferred language (if possible)
                .padding(.top, 5)
                .frame(height: 70) // iOS 17 smart scrolling can't (couldn't?) handle variable size views
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        Divider()
        OrganizationViewRemark(localizedRemark:
            "Fotogroep Waalre is a small photography club based in the south of the Netherlands.")
        Divider()
        OrganizationViewRemark(localizedRemark: """
            A long remark that exercises the lineLimit and minimumScaleFactor modifiers, \
            useful for checking how the layout behaves when the text doesn't fit on a single line.
            """)
        Divider()
        OrganizationViewRemark(localizedRemark: "")
        Divider()
        HStack {
            Spacer()
            Text(verbatim: "Note that the 3rd remark received an empty string.")
                .italic()
                .font(.caption)
            Spacer()
        }
    }
    .padding()
}
