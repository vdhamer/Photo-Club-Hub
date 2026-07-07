//
//  OrganizationViewTitle.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View

/// First line of Text: club/museum name plus optional Wikipedia icon. Used in FilteredOrganizationView.
@MainActor
struct OrganizationViewTitle: View {

    let filteredOrganization: Organization?
    let fullName: String
    let wikipedia: URL?

    init(organization: Organization) {
        filteredOrganization = organization
        fullName = organization.fullName
        wikipedia = organization.wikipedia
    }

    init(organizationFullName: String, wikipediaURL: URL?) {
        filteredOrganization = nil // unused
        fullName = organizationFullName
        wikipedia = wikipediaURL
    }

    var body: some View {
        HStack {
            Text(verbatim: "\(fullName)") // name of club or museum (left aligned)
                .font(UIDevice.isIPad ? .title : .title2)
                .tracking(1)
                .lineLimit(3)
                .truncationMode(.tail)
                .foregroundColor(.mapsColor)
            Spacer()
            if let wikipedia { // optional Wikipedia logo (right aligned)
                Link(destination: wikipedia, label: {
                    Image("Wikipedia", label: Text(verbatim: "Wikipedia"))
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(.trailing, 5)
                })
                .buttonStyle(.plain) // to avoid entire List element to be clickable
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Previews

// Believe it or not, these previews actually works.
#Preview {
    VStack(alignment: .leading) {
        OrganizationViewTitle(organizationFullName: "Fotogroep Waalre",
                              wikipediaURL: URL(string: "https://en.wikipedia.org/wiki/Waalre"))

        Divider()
        OrganizationViewTitle(organizationFullName: "Fotoclub Den Dungen",
                              wikipediaURL: nil)

        Divider()
        OrganizationViewTitle(organizationFullName: "A Very Long Photo Club Name That Must Truncate Eventually",
                              wikipediaURL: nil)
    }
    .padding()
}
