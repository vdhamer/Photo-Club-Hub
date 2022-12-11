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
                                 returnable: Bool = false) -> some View {
        NavigationStack {
            NavigationLink(value: "") { // value not used
                self
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: binding) {
                view
                    .navigationBarHidden(returnable == false) // prevents returning to original View
            }
        }
    }
}
