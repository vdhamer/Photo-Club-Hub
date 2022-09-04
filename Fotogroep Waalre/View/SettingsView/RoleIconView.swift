//
//  RoleIconView.swift
//  Fotogroep Waalre 2
//
//  Created by Peter van den Hamer on 08/01/2022.
//

import SwiftUI

struct RoleStatusIconView: View {

    private let memberRoleToImage: [MemberRole: Image] =  [ // dictionary
        .admin: Image(systemName: "wifi.square"),
        .chairman: Image("chairman"),
        .secretary: Image(systemName: "square.text.square"),
        .treasurer: Image(systemName: "eurosign.square"),
        .viceChairman: Image("vice-chairman")
    ]

    private let memberStatusToImage: [MemberStatus: Image] = [ // dictionary
        .coach: Image(systemName: "mic.square"),
        .deceased: Image("deceased.member"),
        .deviceOwner: Image(systemName: "questionmark.square"),
        .former: Image("former.member"),
        .honorary: Image(systemName: "star.square"),
        .current: Image(systemName: "dot.square"),
        .prospective: Image(systemName: "dot.viewfinder")
    ]

    private var iconImage = Image(systemName: "exclamationmark.triangle.fill")

    init(memberStatus: MemberStatus) { // construct icon for memberStatus
        iconImage = memberStatusToImage[memberStatus, default: iconImage]
    }

    init(memberRole: MemberRole) { // construct icon for memberRole
        iconImage = memberRoleToImage[memberRole, default: iconImage]
    }

    // Chooses one icon to show from a set of alternatives (member can have mult. Roles and Status values).
    // MemberStatus.deceased is ignored, because it is handled using image's color rather than a special icon.
    // This is because someone is a deceased former Member or deceased (former) Coach.
    init(memberRolesAndStatus: MemberRolesAndStatus) {
        // if available, return role like MemberRole.chairman
        if let chosenRole = chooseOneMemberRole(memberRolesAndStatus: memberRolesAndStatus) {
            iconImage = memberRoleToImage[chosenRole, default: iconImage]
        } else { // otherwise return status like MemberStatus.member or MemberStatus.former
            let chosenStatus = chooseOneMemberStatus(memberRolesAndStatus: memberRolesAndStatus)
            iconImage = memberStatusToImage[chosenStatus, default: iconImage]
        }
    }

    private func chooseOneMemberRole(memberRolesAndStatus: MemberRolesAndStatus) -> MemberRole? {
        if memberRolesAndStatus.role[.chairman] == true { return .chairman }
        if memberRolesAndStatus.role[.viceChairman] == true { return .viceChairman }
        if memberRolesAndStatus.role[.treasurer] == true { return .treasurer}
        if memberRolesAndStatus.role[.secretary] == true { return .secretary}
        if memberRolesAndStatus.role[.admin] == true { return .admin}
        return nil // member may not have any official managerial Role
    }

    private func chooseOneMemberStatus(memberRolesAndStatus: MemberRolesAndStatus) -> MemberStatus {
        if memberRolesAndStatus.stat[.deceased] == true { return .deceased }
        if memberRolesAndStatus.stat[.honorary] == true { return .honorary }
        if memberRolesAndStatus.stat[.prospective] == true { return .prospective }
        if memberRolesAndStatus.stat[.coach] == true { return .coach}
        if memberRolesAndStatus.stat[.former] == true { return .former}
        // member is a computed property (if you are none of the above), it doesn't occur in the Core Data store
        return .current // by default, the person is a member
    }

    var body: some View {
        iconImage.font(.title2)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.memberColor, .gray, .red)
    }
}

struct RoleStatusIconView_Previews: PreviewProvider {
    static let layout: [GridItem] = [GridItem(.adaptive(minimum: 200, maximum: .infinity))]

    static var previews: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVGrid(columns: layout) {

                    Section(content: {
                        ForEach(MemberRole.allCases.sorted(by: <)) { memberRole in
                            HStack {
                                RoleStatusIconView(memberRole: memberRole)
                                Text(memberRole.localizedString().capitalizingFirstLetter())
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                            }
                        }
                    }, header: {
                        HStack {
                            Text(verbatim: "Roles") // seen by developers only, so no localization needed
                                .font(.title).foregroundColor(.primary)
                            Spacer()
                        }
                    })

                    Section { Text(verbatim: "") }

                    Section(content: {
                        ForEach(MemberStatus.allCases.sorted(by: <)) { memberStatus in
                            HStack {
                                RoleStatusIconView(memberStatus: memberStatus)
                                Text(memberStatus.localizedString().capitalizingFirstLetter())
                                Spacer()
                            }
                            .foregroundStyle(.memberColor, .gray, .red) // red tertiary color should not show up
                        }
                    }, header: {
                        HStack {
                            Text(verbatim: "Status") // seen by developers only, so no localization needed
                                .font(.title).foregroundColor(.primary)
                            Spacer()
                        }
                    })
                }
                .padding()
                .padding()
                .frame(minWidth: geo.size.width*0.5, idealWidth: geo.size.width*0.8, maxWidth: .infinity)
                .frame(width: geo.size.width*0.8, height: geo.size.height, alignment: .center)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)

        }
    }
}
