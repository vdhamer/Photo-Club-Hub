//
//  MemberPortfolio+upating.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/10/2023.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext

extension MemberPortfolio { // findCreateUpdate() records in Member table

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // Find existing object or create a new object
    // Update existing attributes or fill the new object
    public static func findCreateUpdate(bgContext: NSManagedObjectContext,
                                        // identifying attributes of a Member:
                                        organization: Organization,
                                        photographer: Photographer,
                                        // remove records for members that disappeared from lists:
                                        removeMember: Bool = false,
                                        // non-identifying attributes of a Member:
                                        optionalFields: MemberOptionalFields = MemberOptionalFields() // empty default
    ) -> MemberPortfolio {

        let predicateFormat: String = "organization_ = %@ AND photographer_ = %@" // avoid localization of query string
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [organization, photographer])
        let fetchRequest: NSFetchRequest<MemberPortfolio> = MemberPortfolio.fetchRequest()
        fetchRequest.predicate = predicate
        let memberPortfolios: [MemberPortfolio] = (try? bgContext.fetch(fetchRequest)) ?? [] // nil = absolute failure

        if memberPortfolios.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(memberPortfolios.count)) memberPortfolios for " +
                              "\(photographer.fullNameFirstLast) in \(organization.fullNameTown)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let memberPortfolio = memberPortfolios.first {
            // already exists, so make sure secondary attributes are up to date
            if memberPortfolio.update(bgContext: bgContext,
                                      removeMember: removeMember,
                                      optionalFields: optionalFields) {
                print("""
                      \(memberPortfolio.organization.fullName): \
                      Updated info for member \(memberPortfolio.photographer.fullNameFirstLast)
                      """)
            }
            return memberPortfolio
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "MemberPortfolio", in: bgContext)!
            let memberPortfolio = MemberPortfolio(entity: entity, insertInto: bgContext) // backgr needs special .init()
            memberPortfolio.organization_ = organization
            memberPortfolio.photographer_ = photographer
            _ = memberPortfolio.update(bgContext: bgContext,
                                       removeMember: removeMember,
                                       optionalFields: optionalFields
                                       )
            print("""
                  \(memberPortfolio.organization.fullNameTown): \
                  Created new membership for \(memberPortfolio.photographer.fullNameFirstLast)
                  """)
            return memberPortfolio
        }
    }

    // Update non-identifying attributes/properties within existing instance of class MemberPortfolio
    // swiftlint:disable:next function_body_length
    private func update(bgContext: NSManagedObjectContext,
                        removeMember: Bool, // used to remove club members that disappeared from lists
                        optionalFields: MemberOptionalFields
                ) -> Bool {
        var needsSaving: Bool = false

        let oldMemberRolesAndStatus = self.memberRolesAndStatus // copy of original value
        // actually this setter does merging (is might be better to overload + or += operators for this?)
        self.memberRolesAndStatus = optionalFields.memberRolesAndStatus
        let newMemberRolesAndStatus = self.memberRolesAndStatus // copy after possible changes

        let changed1 = oldMemberRolesAndStatus != newMemberRolesAndStatus
        let changed2 = updateIfChanged(update: &self.membershipStartDate, with: optionalFields.membershipStartDate)
        let changed3 = updateIfChanged(update: &self.membershipEndDate, with: optionalFields.membershipEndDate)
        let changed4 = updateIfChanged(update: &self.level3URL, with: optionalFields.level3URL)
        let changed5 = updateIfChangedOptional(update: &self.featuredImage, with: optionalFields.featuredImage)
        let changed6 = updateIfChanged(update: &self.featuredImageThumbnail,
                                       with: optionalFields.featuredImageThumbnail)
        let changed7 = updateIfChanged(update: &self.removeMember, with: removeMember)
        let changed8 = updateIfChanged(update: &self.fotobondNumber, with: optionalFields.fotobondNumber)
        needsSaving = changed1 || changed2 || changed3 || changed4 ||
                      changed5 || changed6 || changed7 || changed8 // forces execution of updateIfChanged()

        if needsSaving && Settings.extraCoreDataSaves {
            do {
                try bgContext.save() // persist just to be sure?
                if changed1 { print("""
                                    \(organization.fullNameTown): Changed roles for \(photographer.fullNameFirstLast)
                                    """) }
                if changed2 { print("""
                                    \(organization.fullNameTown): \
                                    Changed start date for \(photographer.fullNameFirstLast)
                                    """) }
                if changed3 { print("""
                                    \(organization.fullNameTown): Changed end date for \(photographer.fullNameFirstLast)
                                    """) }
                if changed4 { print("""
                                    \(organization.fullNameTown): \
                                    Changed club website for \(photographer.fullNameFirstLast)
                                    """) }
                if changed5 { print("""
                                    \(organization.fullNameTown): \
                                    Changed latest image for \(photographer.fullNameFirstLast) \
                                    to \(optionalFields.featuredImage?.lastPathComponent ?? "<noLatestImage>")
                                    """)}
                if changed6 { print("""
                                    \(organization.fullNameTown): \
                                    Changed latest thumbnail for \(photographer.fullNameFirstLast) \
                                    to \(optionalFields.featuredImageThumbnail?.lastPathComponent ??
                                    "<noLatestThumbnail>")
                                    """)}
                if changed7 { print("""
                                    \(organization.fullNameTown): \
                                    Changed removeMember flag for \(photographer.fullNameFirstLast) \
                                    to \(removeMember) ??
                                    "<noLatestRemoveMember>")
                                    """)}
                if changed8 { print("""
                                    \(organization.fullNameTown): \
                                    Changed latest fotobondNumber for \(photographer.fullNameFirstLast) \
                                    to \(optionalFields.fotobondNumber ?? 0)
                                    """)}
            } catch {
                ifDebugFatalError("Update failed for member \(photographer.fullNameFirstLast) " +
                                  "in club \(organization.fullNameTown): \(error)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, failure to update this data is only logged. And the app doesn't stop.
            }
        }

        return needsSaving
    }

    // If optional support needed, use updateIfChangedOptional instead. updateIfChanged doesn't work for optionals.
    private func updateIfChanged<Type>(update persistedValue: inout Type,
                                       with newValue: Type?) -> Bool // true only if needsSaving
                                    where Type: Equatable {
        if let newValue { // nil means no new value known - and thus doesn't erase existing value
            if persistedValue != newValue {
                persistedValue = newValue // actual update
                return true // update needs to be saved
            }
        }
        return false
    }

    private func updateIfChangedOptional<Type>(update persistedValue: inout Type?,
                                               with newValue: Type?) -> Bool // true only if needsSaving
                                               where Type?: Equatable {
        if let newValue { // nil means no new value known - and thus doesn't erase existing value
            if persistedValue != newValue {
                persistedValue = newValue // actual update
                return true // update needs to be saved
            }
        }
        return false
    }

}
