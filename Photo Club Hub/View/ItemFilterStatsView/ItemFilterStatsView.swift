//
//  ItemFilterStatsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/03/2024.
//

import SwiftUI

struct ItemFilterStatsView: View { // display right-aligned string like "12 entries (of 123)" or "123 entries"

    private let filteredCount: Int
    private let unfilteredCount: Int
    private let elementType: ElementTypeEnum
    private let comment: StaticString

    init(filteredCount: Int, unfilteredCount: Int, elementType: ElementTypeEnum) {
        self.filteredCount = filteredCount
        self.unfilteredCount = unfilteredCount
        self.elementType = elementType

        // somehow use of variable Comment of type StaticString gives warnings in the build log, but the results do work
        if elementType == ElementTypeEnum.photographer {
            comment = "Stats header displayed at top of Who's who screen"
        } else {
            comment = "Stats header displayed at top of Organizations screen"
        }
    }

    var body: some View {
        HStack {
            Spacer() // allign to trailing edge

            if elementType == ElementTypeEnum.organization {
                if (filteredCount == 1) && unfiltered {
                    Text("1 organization",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                } else if (filteredCount != 1) && unfiltered {
                    Text("\(filteredCount) organizations",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                } else if (filteredCount == 1) && filtered {
                    Text("1 organization (of \(unfilteredCount))",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                } else {
                    Text("\(filteredCount) organizations (of \(unfilteredCount))",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                }
            } else {
                if (filteredCount == 1) && unfiltered {
                    Text("1 photographer",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                } else if (filteredCount != 1) && unfiltered {
                    Text("\(filteredCount) photographers",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                } else if (filteredCount == 1) && filtered {
                    Text("1 photographer (of \(unfilteredCount))",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                } else {
                    Text("\(filteredCount) photographers (of \(unfilteredCount))",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: comment)
                }
            }
        }
        .padding(.trailing)
        .font(.callout) // small font

        var filtered: Bool { filteredCount != unfilteredCount }
        var unfiltered: Bool { !filtered }
    }
}

#Preview {
    VStack {
        ItemFilterStatsView(filteredCount: 100, unfilteredCount: 100, elementType: ElementTypeEnum.organization)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 1, elementType: ElementTypeEnum.organization)
        ItemFilterStatsView(filteredCount: 12, unfilteredCount: 100, elementType: ElementTypeEnum.organization)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 100, elementType: ElementTypeEnum.organization)
    }
}
