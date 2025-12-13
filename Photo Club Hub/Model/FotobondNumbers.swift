//
//  FotobondNumbers.swift
//  Photo Club Hub Data
//
//  Created by Peter van den Hamer on 03/12/2025.
//

/// These structs are only used in The Netherlands by the Fotobond ("nlSpecific" section of Json input data)

/// A typed wrapper for a Dutch Fotobond identifier for clubs.
/// Encapsulates the raw numeric club number as an Int16.
/// Helps prevent confusion with Fotobond club identifiers.
public struct FotobondClubNumber: Equatable {
    /// Raw Fotobond club number (0101...9999). Nil if no valid number found in JSON data.
    let id: Int16?

    public init?(id: Int16?) {
        guard let id else { return nil } // failable initializer returns nil if Fotobond club number isn't available.
        self.id = id
    }

    // format is DD.CC where D="department" and C=club and both are padded with leading 0
    // example: 1610 -> 16.10
    // example: 300 -> 03.Pers
    public var display: String {
        guard let id else { return "-" }
        let afdelingNr = String(format: "%02d", (id - (id % 100)) / 100)
        var clubNr = String(format: "%02d", id % 100)
        if (id % 100) == 0 {
            clubNr = "Pers"
        }
        return String(afdelingNr + "." + clubNr) // represent club 301 as "0301"
    }
}

/// A typed wrapper for a Dutch Fotobond identifier for club members..
/// Encapsulates the raw numeric member number as an Int32.
/// Helps prevent confusion with Fotobond member identifiers..
public struct FotobondMemberNumber: Equatable {
    /// Raw Fotobond member number (0...2,147,483,647).
    let id: Int32?

    public init?(id: Int32?) {
        guard let id else { return nil } // failable initializer returns nil if Fotobond member number isn't available.
        self.id = id
    }

    // format is DD.CC.MMM where D="department" and C=club and M=member and all are padded with leading 0's
    // example: 1610123 -> "16.10.123" (Brabant Oost)
    // exmpple:  304123 -> "03.04.123" (Drenthe-Vechtdal)
    // example: 3004321 -> "Pers.4321" (weird exception)
    public var display: String {
        guard let id else { return "N/A" }
        guard id % 1000000 != 3_000_000 else { return "Pers.\(id.description.suffix(4))" }

        let afdelingNr: Int32 = (id - (id % 100_000)) / 100_000
        let remainder: Int32 = id - afdelingNr * 100_000
        let clubNr: Int32 = remainder - (remainder - remainder % 100) / 100
        let memberNr3: Int32 = remainder % 1_000
        return String(format: "%02d.%02d.%03d", afdelingNr, clubNr, memberNr3)
    }
}
