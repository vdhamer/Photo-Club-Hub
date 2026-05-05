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

    let filteredOrganization: Organization

    var body: some View {
        if #available(iOS 26, *) {
            Text(filteredOrganization.localizedRemark) // display remark in preferred language (if possible)
                .padding(.top, 5)
                .font(.footnote)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .frame(height: 40)
        } else if #available(iOS 18, *) {
            Text(filteredOrganization.localizedRemark) // display remark in preferred language (if possible)
                .padding(.top, 5)
        } else { // iOS 17 - we don't support older versions
            Text(filteredOrganization.localizedRemark) // display remark in preferred language (if possible)
                .padding(.top, 5)
                .frame(height: 70) // iOS 17 smart scrolling can't (couldn't?) handle variable size views
        }
    }
}
