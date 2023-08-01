//
//  FotogroepWaalreMembersProvide+enumHTMLPageLoadingState.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/12/2022.
//

import Foundation

extension FotogroepWaalreMembersProvider { // private utitity functions

    ///////////////////////////////////////////////////////////////////////////////////////////
    // MARK: - Load members/ex-members/mentors from password-protected website page
    // swiftlint:disable line_length

    /*
    Excerpt from PRIVATELEDENURL file (but with extra indentation and comments)
    <table> <!-- found .tableStart, now search for .tableHeader -->
    <tbody>
       <tr>
          <th>Groepslid</th> <!-- found .tableHeader, now search for .rowStart -->
          <th>E-mail</th>
          <th>Telefoon</th>
          <th>Eigen website</th>
       </tr>
       <tr> <!-- found .rowStart, now search for .personName -->
          <td>Bart van Stekelenburg (lid)</td> <!-- found .personName, now search for .eMail -->
          <td><a href="mailto:x@gmail.com">x@gmail.com</a></td> <!-- found .eMail, now search for .phoneNumber -->
          <td>040-1234567</td> <!-- found .phoneNumber, now search for .externalURL -->
          <td><a title="" <="" a=""></a></td> <!-- found .externalURL, now search for .rowStart -->
       </tr>
    </tbody>
    </table>
    <table>
    <tbody>
       <tr> <!-- found .rowStart, now search for .personName -->
          <th>Ex-lid</th>
          <th>E-mail</th>
          <th>Telefoon</th>
          <th>Eigen website</th>
       </tr>
       <tr>
          <td>Joop Postema</td> <!-- found .personName, now search for .eMail -->
          <td><a href="mailto:x@gmail.com">x@gmail.com</a></td> <!-- found .eMail, now search for .phoneNumber -->
          <td>[overleden]</td> <!-- found .phoneNumber, now search for .externalURL -->
          <td><a title="" href="http://www.flickr.com/photos/jooppostema/" target="_blank" rel="noopener noreferrer">extern</a></td> <!-- found .externalURL, now search for .rowStart -->
       </tr>
    </tbody> <!-- if we can't find a next .rawStart, the looping stops -->
    </table>
    */

    // swiftlint:enable line_length

    enum HTMLPageLoadingState {
        // rawValues are target search strings in the HTML file
        case tableStart
        case tableHeader
        case rowStart
        case personName
        case eMail
        case phoneNumber
        case externalURL
        case birthDate

        // returns search string needed to find HTMLPageLoadingState
        func targetString() -> String {
            switch self {
            case .tableStart:   return "<table>"     // finds start of 1st table (we are parsing multiple tables)
            case .tableHeader:  return "Groepslid"   // finds expected table header of 1st table
            case .rowStart:     return "<tr>"        // ignores rest of table header, and searches for rows
            case .personName:   return "<td>"        // assumes personName is 1st field, no special way to identifier
            case .eMail:        return "<td><a href" // recognize URL using HTML tag
            case .phoneNumber:  return "<td>"        // table cell after .email (no special identifier)
            case .externalURL:  return "<td>"        // no special identifier ("<td><a title" works, but is fragile)
            case .birthDate:    return "<td>"        // table cell after .externalURL (no special identifier)
            }
        }

        // define next state based on the preceding state
        func nextState() -> HTMLPageLoadingState {
            switch self {
            case .tableStart:   return .tableHeader
            case .tableHeader:  return .rowStart
            case .rowStart:     return .personName
            case .personName:   return .eMail
            case .eMail:        return .phoneNumber
            case .phoneNumber:  return .externalURL
            case .externalURL:  return .birthDate
            case .birthDate:    return .rowStart
            }
        }
    }

}
