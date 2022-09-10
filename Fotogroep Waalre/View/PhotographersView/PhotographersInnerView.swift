//
//  PhotographersInner.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI

struct PhotographersInnerView: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchRequest: FetchedResults<Photographer>
    private let dateFormatter: DateFormatter
    @State private var showPhoneMail = false
    private let isDeletePhotographersEnabled = false // disables .delete() functionality for this section
    let searchText: Binding<String>

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>) {
        _fetchRequest = FetchRequest<Photographer>(sortDescriptors: [ // replaces previous fetchRequest
                                                SortDescriptor(\.givenName_, order: .forward),
                                                SortDescriptor(\.familyName_, order: .forward)
                                            ],
                                             predicate: predicate,
                                             animation: .default)

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM" // used here for birthdays only, so year is hidden
        self.searchText = searchText
    }

    var body: some View {
        ForEach(filteredPhotographers, id: \.id) { filteredPhotographer in
            HStack(alignment: .center) {
                PhotographerImage(isDeceased: filteredPhotographer.isDeceased)
                    .foregroundStyle(.photographerColor, .gray, .red) // red tertiary color should not show up
                    .font(.title3)
                    .padding([.trailing], 5)
                VStack(alignment: .leading) {
                    let alive = filteredPhotographer.isDeceased ? " - " + MemberStatus.deceased.localizedString() : ""
                    let deviceOwner = filteredPhotographer.isDeviceOwner ?
                                      " - " + MemberStatus.deviceOwner.localizedString() : ""
                    Text(verbatim: "\(filteredPhotographer.fullName)\(alive)\(deviceOwner)")
                        .font(.title3)
                        .tracking(1)
                        .foregroundColor(chooseColor(accentColor: .accentColor,
                                                     isDeceased: filteredPhotographer.isDeceased))
                    if let date: Date = filteredPhotographer.bornDT {
                        let locBirthday = String(localized: "Birthday:",
                                          comment: "Birthday of member (without year). Date not currently localized?")
                        Text(verbatim: "\(locBirthday) \(dateFormatter.string(from: date))")
                            .font(.subheadline)
                            .foregroundColor(filteredPhotographer.isDeceased ? .deceasedColor : .primary)
                    }
                    if let phoneNumber = filteredPhotographer.phoneNumber, phoneNumber != "",
                                         showPhoneMail, !filteredPhotographer.isDeceased {
                        let locPhone = String(localized: "Phone:", comment: "Telephone number (usually invisible)")
                        Text(verbatim: "\(locPhone): \(phoneNumber)")
                            .font(.subheadline)
                            .foregroundColor(.primary) // we don't show phone numbers for deceased people
                    }
                    if let eMail = filteredPhotographer.eMail, eMail != "",
                       showPhoneMail, !filteredPhotographer.isDeceased {
                        Text(verbatim: "mailto://\(eMail)")
                            .font(.subheadline)
                            .foregroundColor(.primary) // we don't show phone numbers for deceased people
                    }
                    if let url: URL = filteredPhotographer.photographerWebsite {
                        Link(destination: url, label: {
                            Text(url.absoluteString)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .font(.subheadline)
                                .foregroundColor(.linkColor)
                        })
                            .buttonStyle(.plain) // to avoid entire List element to be clickable
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
            .accentColor(.photographerColor)
        }
        .onDelete(perform: deletePhotographers) // can be disabled using isDeletedPhotographerEnabled flag
    }

    private var filteredPhotographers: [Photographer] {
        if searchText.wrappedValue.isEmpty {
            return fetchRequest.filter { _ in
                true
            }
        } else {
            return fetchRequest.filter { photographer in
                photographer.fullName.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

    private func chooseColor(accentColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : .photographerColor
    }

    private func deletePhotographers(offsets: IndexSet) {
        guard isDeletePhotographersEnabled else { return }
        let fullName: String = offsets.map { fetchRequest[$0] }.first?.fullName ?? "noName"
        offsets.map { fetchRequest[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save()
                print("Deleted photographer \(fullName) and any associated memberships")
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error deleting photographer \(fullName): \(nsError), \(nsError.userInfo)")
        }
    }

    private struct PhotographerImage: View {
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

struct PhotographersInnerView_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "familyName_ = %@ || familyName_ = %@ || familyName_ = %@",
                                       argumentArray: ["D'Eau1", "D'Eau2", "D'Eau10"])
    @State static var searchText: String = "Eau1"

    static var previews: some View {
        NavigationView {
            List {
                PhotographersInnerView(predicate: predicate, searchText: $searchText)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("PhotographersInnerView"))) // prevent localization
        }
        .navigationViewStyle(.stack)
//        .searchable(text: $searchText)
    }
}
