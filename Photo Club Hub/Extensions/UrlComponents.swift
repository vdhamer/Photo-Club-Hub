//
//  UrlComponents.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

struct UrlComponents {

    static let dataSourcePath = """
                                https://raw.githubusercontent.com/\
                                vdhamer/Photo-Club-Hub/\
                                main/JSON/
                                """

    var dataSourceFile: String // fgDeGender, can be overruled when testing
    let fileSubType: String // level2 (part of name)
    let fileType: String // json (actual file system type)

    var fullURLstring: String {
        // https://raw.githubusercontent.com/vdhamer/Photo-Club-Hub/main/ +
        // JSON/fgDeGender.level2.json
        return UrlComponents.dataSourcePath+dataSourceFile+"."+fileSubType+"."+fileType
    }

    var shortName: String {
        // fgDeGender.level2.json
        return dataSourceFile+"."+fileSubType+"."+fileType
    }

    // MARK: - Fotogroep de Gender

    static let deGender = UrlComponents(
        dataSourceFile: "fgDeGender",
        fileSubType: "level2",
        fileType: "json"
    )

    // MARK: - Waalre

    static let waalre = UrlComponents(
        dataSourceFile: "fgWaalre",
        fileSubType: "level2",
        fileType: "json"
    )

    // MARK: - XampleMin

    static let xampleMin = UrlComponents(
        dataSourceFile: "xampleMin",
        fileSubType: "level2",
        fileType: "json"
    )

    // MARK: - XampleMax

    static let xampleMax = UrlComponents(
        dataSourceFile: "xampleMax",
        fileSubType: "level2",
        fileType: "json"
    )

    // MARK: - Bellus Imago

    static let bellusImago = UrlComponents(
        dataSourceFile: "fcBellusImago",
        fileSubType: "level2",
        fileType: "json"
    )

}
