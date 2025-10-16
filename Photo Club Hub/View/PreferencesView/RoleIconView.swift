//
//  RoleIconView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 08/01/2022.
//

import SwiftUI

struct RoleStatusIconView: View {

    fileprivate let memberRoleToImage: [MemberRole: Image] =  [ // dictionary
        .admin: Image(systemName: "wifi.square"),
        .chairman: Image("chairman"),
        .secretary: Image(systemName: "square.text.square"),
        .treasurer: Image(systemName: "eurosign.square"),
        .viceChairman: Image("vice-chairman")
    ]

    fileprivate let memberStatusToImage: [MemberStatus: Image] = [ // dictionary
        .coach: Image(systemName: "mic.square"),
        .deceased: Image("deceased.member"),
        .former: Image("former.member"),
        .honorary: Image(systemName: "star.square"),
        .current: Image(systemName: "dot.square"),
        .prospective: Image(systemName: "dot.viewfinder")
    ]

    fileprivate var iconImage = Image(systemName: "exclamationmark.triangle.fill")

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

    fileprivate func chooseOneMemberRole(memberRolesAndStatus: MemberRolesAndStatus) -> MemberRole? {
        if memberRolesAndStatus.roles[.chairman] == true { return .chairman }
        if memberRolesAndStatus.roles[.viceChairman] == true { return .viceChairman }
        if memberRolesAndStatus.roles[.treasurer] == true { return .treasurer}
        if memberRolesAndStatus.roles[.secretary] == true { return .secretary}
        if memberRolesAndStatus.roles[.admin] == true { return .admin}
        return nil // member may not have any official managerial Role
    }

    fileprivate func chooseOneMemberStatus(memberRolesAndStatus: MemberRolesAndStatus) -> MemberStatus {
        if memberRolesAndStatus.status[.deceased] == true { return .deceased }
        if memberRolesAndStatus.status[.honorary] == true { return .honorary }
        if memberRolesAndStatus.status[.prospective] == true { return .prospective }
        if memberRolesAndStatus.status[.coach] == true { return .coach}
        if memberRolesAndStatus.status[.former] == true { return .former}
        // member is a computed property (if you are none of the above), it doesn't occur in the Core Data store
        return .current // by default, the person is a member
    }

    var body: some View {
        iconImage.font(.title2)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.memberPortfolioColor, .gray, .red)
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
                                Text(memberRole
                                    .localizedString(unused: "PhotoClubHub.SwiftUI")
                                    .capitalizingFirstLetter())
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
                            .foregroundStyle(.memberPortfolioColor, .gray, .red) // red tertiary color is not used
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
