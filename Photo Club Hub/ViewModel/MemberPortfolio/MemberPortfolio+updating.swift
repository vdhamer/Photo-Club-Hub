//
//  MemberPortfolio+upating.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 20/10/2023.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext

extension MemberPortfolio { // findCreateUpdate() records in Member table

    // Find existing object or create a new object
    // Update existing attributes or fill the new object
    static func findCreateUpdate(bgContext: NSManagedObjectContext, intermediateCoreDataSaves: Bool,
                                 // identifying attributes of a Member:
                                 organization: Organization, photographer: Photographer,
                                 // non-identifying attributes of a Member:
                                 memberRolesAndStatus: MemberRolesAndStatus,
                                 dateInterval: DateInterval? = nil,
                                 memberWebsite: URL? = nil,
                                 latestImage: URL? = nil,
                                 latestThumbnail: URL? = nil
                                ) -> MemberPortfolio {

        let predicateFormat: String = "organization_ = %@ AND photographer_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [organization, photographer]
                                   )
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
            if update(bgContext: bgContext, memberPortfolio: memberPortfolio,
                      memberRolesAndStatus: memberRolesAndStatus,
                      dateInterval: dateInterval,
                      memberWebsite: memberWebsite,
                      latestImage: latestImage,
                      latestThumbnail: latestThumbnail,
                      intermediateCoreDataSaves: intermediateCoreDataSaves) {
                print("""
                      \(memberPortfolio.organization.fullName): \
                      Updated info for member \(memberPortfolio.photographer.fullNameFirstLast)
                      """)
            }
             return memberPortfolio
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "MemberPortfolio", in: bgContext)!
            let memberPortfolio = MemberPortfolio(entity: entity, insertInto: bgContext) // bg needs special .init()
            memberPortfolio.organization_ = organization
            memberPortfolio.photographer_ = photographer
            _ = update(bgContext: bgContext, memberPortfolio: memberPortfolio,
                       memberRolesAndStatus: memberRolesAndStatus,
                       dateInterval: dateInterval,
                       memberWebsite: memberWebsite,
                       latestImage: latestImage,
                       latestThumbnail: latestThumbnail,
                       intermediateCoreDataSaves: intermediateCoreDataSaves)
            print("""
                  \(memberPortfolio.organization.fullNameTown): \
                  Created new membership for \(memberPortfolio.photographer.fullNameFirstLast)
                  """)
            return memberPortfolio
        }
    }

    // Update non-identifying attributes/properties within existing instance of class MemberPortfolio
    // swiftlint:disable:next function_parameter_count function_body_length
    private static func update(bgContext: NSManagedObjectContext, memberPortfolio: MemberPortfolio,
                               memberRolesAndStatus: MemberRolesAndStatus,
                               dateInterval: DateInterval?,
                               memberWebsite: URL?,
                               latestImage: URL?,
                               latestThumbnail: URL?,
                               intermediateCoreDataSaves: Bool) -> Bool {
        var needsSaving: Bool = false

        // function only works for non-optional Types.
        // If optional support needed, create variant with "inout Type?" instead of "inout Type"
        func updateIfChanged<Type>(update persistedValue: inout Type,
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

        func updateIfChangedOptional<Type>(update persistedValue: inout Type?,
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

        let oldMemberRolesAndStatus = memberPortfolio.memberRolesAndStatus // copy of original value
        // actually this setter does merging (overload + or += operators for this?)
        memberPortfolio.memberRolesAndStatus = memberRolesAndStatus
        let newMemberRolesAndStatus = memberPortfolio.memberRolesAndStatus // copy after possible changes

        let changed1 = oldMemberRolesAndStatus != newMemberRolesAndStatus
        let changed2 = updateIfChanged(update: &memberPortfolio.dateIntervalStart, with: dateInterval?.start)
        let changed3 = updateIfChanged(update: &memberPortfolio.dateIntervalEnd, with: dateInterval?.end)
        let changed4 = updateIfChanged(update: &memberPortfolio.level3URL, with: memberWebsite)
        let changed5 = updateIfChangedOptional(update: &memberPortfolio.featuredImage, with: latestImage)
        let changed6 = updateIfChangedOptional(update: &memberPortfolio.featuredImageThumbnail, with: latestThumbnail)
        needsSaving = changed1 || changed2 || changed3 ||
                      changed4 || changed5 || changed6 // forces execution of updateIfChanged()

        if needsSaving && intermediateCoreDataSaves {
            do {
                try bgContext.save() // persist just to be sure?
                if changed1 { print("""
                                    \(memberPortfolio.organization.fullNameTown): \
                                    Changed roles for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed2 { print("""
                                    \(memberPortfolio.organization.fullNameTown): \
                                    Changed start date for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed3 { print("""
                                    \(memberPortfolio.organization.fullNameTown): \
                                    Changed end date for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed4 { print("""
                                    \(memberPortfolio.organization.fullNameTown): \
                                    Changed club website for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed5 { print("""
                                    \(memberPortfolio.organization.fullNameTown): \
                                    Changed latest image for \(memberPortfolio.photographer.fullNameFirstLast) \
                                    to \(latestImage?.lastPathComponent ?? "<noLatestImage>")
                                    """)}
                if changed6 { print("""
                                    \(memberPortfolio.organization.fullNameTown): \
                                    Changed latest thumbnail for \(memberPortfolio.photographer.fullNameFirstLast) \
                                    to \(latestThumbnail?.lastPathComponent ?? "<noLatestThumbnail>")
                                    """)}
            } catch {
                ifDebugFatalError("Update failed for member \(memberPortfolio.photographer.fullNameFirstLast) " +
                                  "in club \(memberPortfolio.organization.fullNameTown): \(error)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, failure to update this data is only logged. And the app doesn't stop.
            }
        }

        return needsSaving
    }

}
