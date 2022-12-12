//
//  View+Navigate.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/03/2022.
//

import SwiftUI

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView,
                                 when binding: Binding<Bool>,
                                 enableBack: Bool = true) // for testing
                                 -> some View {
        NavigationStack {

//            NavigationLink {
//                view // destination
//                    .navigationBarHidden(enableBack == false) // prevents returning to original View
//            } label: {
//                self
//                    .navigationBarHidden(true) // no navigationTitle on screen itself
//            }

            NavigationLink(value: 0) { // `value` is not used
                self // tapping this sets off the link
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: binding) {
                view
                    .navigationBarBackButtonHidden(enableBack == false)
            }
        }
    }
}
