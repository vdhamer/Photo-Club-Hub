//
//  PhotographersInner.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI

struct WhoIsWhoInnerView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchRequest: FetchedResults<Photographer>
    private let dateFormatter: DateFormatter
    @State private var showPhoneMail = false
    private let isDeletePhotographersEnabled = false // disables .delete() functionality for this section
    let searchText: Binding<String>

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>) {
        _fetchRequest = FetchRequest<Photographer>(sortDescriptors: [ // replaces previous fetchRequest
                                                        SortDescriptor(\.familyName_, order: .forward),
                                                        SortDescriptor(\.givenName_, order: .forward)
                                                   ],
                                                   predicate: predicate,
                                                   animation: .default)

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM" // used here for birthdays only, so year is hidden
        self.searchText = searchText
    }

    var body: some View {
        Section {
            ForEach(filteredPhotographers, id: \.id) { filteredPhotographer in
                VStack {
                    HStack(alignment: .top) {
                        PhotographerIconView(isDeceased: filteredPhotographer.isDeceased)
                            .foregroundStyle(.photographerColor, .gray, .red) // red tertiary color should not show up
                            .font(.title3)
                            .padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 5))
                        VStack(alignment: .leading) {

                            // first green line with icon and name of photographer
                            let alive: String = filteredPhotographer.isDeceased ? // generate name suffix
                            (" - " + MemberStatus.deceased.localizedString()) : ""
                            Text(verbatim: "\(filteredPhotographer.fullNameLastFirst)\(alive)")
                                .font(.title3)
                                .tracking(1)
                                .foregroundColor(chooseColor(accentColor: .accentColor,
                                                             isDeceased: filteredPhotographer.isDeceased))

                            // birthday if available (year of birth is not shown)
                            if let date: Date = filteredPhotographer.bornDT {
                                let locBirthday = String(localized: "Birthday:",
                                                         comment: """
                                                                  Birthday of member (without year). \
                                                                  Date not currently localized?
                                                                  """)
                                Text(verbatim: "\(locBirthday) \(dateFormatter.string(from: date))")
                                    .font(.subheadline)
                                    .foregroundColor(filteredPhotographer.isDeceased ? .deceasedColor : .primary)
                            }

                            // phone number if available (and allowed)
                            if filteredPhotographer.phoneNumber != "", showPhoneMail, !filteredPhotographer.isDeceased {
                                let locPhone = String(localized: "Phone:",
                                                      comment: "Telephone number (usually invisible)")
                                Text(verbatim: "\(locPhone): \(filteredPhotographer.phoneNumber)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary) // don't show phone numbers for deceased people
                            }

                            // phone number if available (and allowed)
                            if filteredPhotographer.eMail != "", showPhoneMail, !filteredPhotographer.isDeceased {
                                Text(verbatim: "mailto://\(filteredPhotographer.eMail)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary) // don't show e-mail addresses for deceased people
                            }

                            // personal (not club-related) web site if available
                            if let url: URL = filteredPhotographer.photographerWebsite {
                                Link(destination: url, label: {
                                    Text(url.absoluteString)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .font(.subheadline)
                                        .foregroundColor(.linkColor)
                                })
                                .buttonStyle(.plain) // prevents entire List element from becoming clickable
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(filteredPhotographer.memberships.sorted(), id: \.id) { membership in
                                        Link(destination: membership.memberWebsite, label: {
                                            AsyncImage(url: membership.latestImageURL) { phase in
                                                if let image = phase.image {
                                                    ZStack(alignment: .bottom) {
                                                        image // Displays the loaded image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(height: 160)
                                                        Text(verbatim: "\(membership.roleDescriptionOfClubTown)")
                                                            .font(.caption)
                                                            .padding(EdgeInsets(top: 3,
                                                                                leading: 5,
                                                                                bottom: 3,
                                                                                trailing: 5))
                                                            .lineLimit(3)
                                                            .truncationMode(.middle)
                                                            .background(.thinMaterial)
                                                            .foregroundColor(.black)
                                                            .frame(width: 160)
                                                    }
                                                } else if phase.error != nil ||
                                                            membership.latestImageURL == nil {
                                                    Image("Question-mark") // image indicates an error occurred
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                } else {
                                                    ZStack {
                                                        Image("Embarrassed-snail") // placeholder while loading
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .opacity(0.4)
                                                        ProgressView()
                                                            .scaleEffect(x: 2, y: 2, anchor: .center)
                                                            .blendMode(BlendMode.difference)
                                                    }
                                                }
                                            }
                                            .frame(width: 160, height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                            .shadow(color: .accentColor.opacity(0.5), radius: 3)
                                        })
                                    }
                                }
                            }
                        }
                        Spacer()
                        if let url: URL = filteredPhotographer.photographerWebsite {
                            Link(destination: url, label: {
                                Image(systemName: "link")
                                    .foregroundColor(.linkColor)
                            })
                            .buttonStyle(.plain) // to avoid entire List element to be clickable
                        }
                    }
                }
                .accentColor(.photographerColor)
            }
            .onDelete(perform: deletePhotographers) // can be disabled using isDeletedPhotographerEnabled flag
        } header: {
            Text(makeHeaderString(count: filteredPhotographers.count))
                .textCase(nil) // arguably a bug
        }
    }

    private func makeHeaderString(count: Int) -> String {
        let singular = String(localized: "One photographer", comment: "Header of section of Who's Who screen")
        let plural = String(localized: "\(count) photographers", comment: "Header of section of Who's Who screen")
        return count==1 ? singular : plural
    }

    private var filteredPhotographers: [Photographer] {
        if searchText.wrappedValue.isEmpty {
            return fetchRequest.filter { _ in
                true
            }
        } else {
            return fetchRequest.filter { photographer in
                photographer.fullNameFirstLast.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

    private func chooseColor(accentColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : .photographerColor
    }

    private func deletePhotographers(offsets: IndexSet) {
        guard isDeletePhotographersEnabled else { return }
        let fullName: String = offsets.map { fetchRequest[$0] }.first?.fullNameFirstLast ?? "noName"
        offsets.map { fetchRequest[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save()
                print("Deleted photographer \(fullName) and any associated memberships")
            }
        } catch {
            let nsError = error as NSError
            ifDebugFatalError("Unresolved error deleting photographer \(fullName): \(nsError), \(nsError.userInfo)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed deletion is only logged. App doesn't stop.
        }
    }

    private struct PhotographerIconView: View {
        let isDeceased: Bool

        var body: some View {
            if isDeceased {
                Image("deceased.photographer")
            } else {
                Image(systemName: "person.text.rectangle")
            }
        }
    }
}

struct WhoIsWhoInnerViewWrapper: View {
    var body: some View {
        let predicate = NSPredicate(format: "familyName_ = %@ || familyName_ = %@ || familyName_ = %@",
                                    argumentArray: ["Eau1", "Eau2", "Eau10"])
        @State var searchText: String = "Eau1"

        return WhoIsWhoInnerView(predicate: predicate, searchText: $searchText)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

#Preview {
    NavigationStack {
        List {
            WhoIsWhoInnerViewWrapper()
        }
    }
    .searchable(text: .constant("Name"))
}
