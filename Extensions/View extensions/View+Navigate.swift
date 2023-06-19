//
//  View+Navigate.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/03/2022.
//

import SwiftUI

extension View {

    /// Navigate to a new view.
    /// - Parameters:
    ///   - to: View to navigate to.
    ///   - when: Only navigates when this condition is `true`.
    ///   - horSizeClass: if SizeClass is .compact, hide back button to save space
    func navigate<NewView: View>(to view: NewView,
                                 when binding: Binding<Bool>,
                                 horSizeClass: UserInterfaceSizeClass?) -> some View {
        NavigationStack {
            NavigationLink(value: 0) { // `value` is not used, and may cause a negligible (32 Byte) memory leak
                self // tapping this sets off the link
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: binding) {
                view
                    .navigationBarBackButtonHidden(hideBackButton(horSizeClass: horSizeClass))
            }
        }
    }

    // hide "<" or "< Intro" if there is not enough space for all the icons
    func hideBackButton(horSizeClass: UserInterfaceSizeClass?) -> Bool {
        guard horSizeClass != nil else { return true } // don't know
        return horSizeClass == UserInterfaceSizeClass.compact // .regular on iPad and iPhone 14 Plus or Pro Max
    }

}
