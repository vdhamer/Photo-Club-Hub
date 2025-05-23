//
//  ItemFilterStatsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/03/2024.
//

import SwiftUI

struct ItemFilterStatsView: View { // display right-aligned string like "12 entries (of 123)" or "123 entries"

    let filteredCount: Int
    let unfilteredCount: Int
    let elementType: ItemFilterStatsEnum
    let comment: StaticString

    init(filteredCount: Int, unfilteredCount: Int, elementType: ItemFilterStatsEnum) {
        self.filteredCount = filteredCount
        self.unfilteredCount = unfilteredCount
        self.elementType = elementType

        // somehow use of variable Comment of type StaticString gives warnings in the build log, but the results do work
        if elementType == ItemFilterStatsEnum.organization {
            comment = "Stats header displayed at top of Clubs and Museums screen"
        } else {
            comment = "Stats header displayed at top of Who's who screen"
        }
    }

    var body: some View {
        HStack {
            Spacer() // allign to right

            if elementType == ItemFilterStatsEnum.organization {
                if (filteredCount == 1) && unfiltered {
                    Text("1 organization", comment: comment)
                } else if (filteredCount != 1) && unfiltered {
                    Text("\(filteredCount) organizations", comment: comment)
                } else if (filteredCount == 1) && filtered {
                    Text("1 organization (of \(unfilteredCount))", comment: comment)
                } else {
                    Text("\(filteredCount) organizations (of \(unfilteredCount))", comment: comment)
                }
            } else {
                if (filteredCount == 1) && unfiltered {
                    Text("1 photographer", comment: comment)
                } else if (filteredCount != 1) && unfiltered {
                    Text("\(filteredCount) photographers", comment: comment)
                } else if (filteredCount == 1) && filtered {
                    Text("1 photographer (of \(unfilteredCount))", comment: comment)
                } else {
                    Text("\(filteredCount) photographers (of \(unfilteredCount))", comment: comment)
                }
            }

        }
        .padding(.horizontal, 0)
        .font(.callout) // small font

        var filtered: Bool { filteredCount != unfilteredCount }
        var unfiltered: Bool { !filtered }
    }
}

#Preview {
    VStack {
        ItemFilterStatsView(filteredCount: 100, unfilteredCount: 100, elementType: ItemFilterStatsEnum.organization)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 1, elementType: ItemFilterStatsEnum.organization)
        ItemFilterStatsView(filteredCount: 12, unfilteredCount: 100, elementType: ItemFilterStatsEnum.organization)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 100, elementType: ItemFilterStatsEnum.organization)
    }
}
