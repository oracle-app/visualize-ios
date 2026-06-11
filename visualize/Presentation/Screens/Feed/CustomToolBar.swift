//
//  CustomToolBar.swift
//  visualize
//
//  Created by Jorge Flores on 22/04/26.
//
//  This file extends SwiftUI's View with a reusable customToolBar modifier that
//  standardizes the configuration of navigation toolbars across the app.
//
//  It provides a flexible API that allows injecting custom views for the leading,
//  trailing, principal, and primary action areas of the toolbar. Internally, it
//  wraps SwiftUI's native .toolbar API using a ViewModifier to centralize and
//  simplify toolbar configuration.
//
//  The modifier also supports conditional visibility for a primary action button
//  and allows dynamic title handling for contextual UI updates.
//

import SwiftUI

extension View {
    @ViewBuilder
    func customToolBar<Leading: View, Trailing: View, Principal: View, PrimaryAction: View>(
        isPrimaryActionVisible: Bool,
        title: String?,
        
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing,
        @ViewBuilder principal: @escaping () -> Principal,
        @ViewBuilder primaryAction: @escaping () -> PrimaryAction
    ) -> some View {
        self
            .modifier(
                CustomToolBarModifier(
                    isPrimaryActionVisible: isPrimaryActionVisible,
                    title: title,
                    leading: leading,
                    trailing: trailing,
                    principal: principal,
                    primaryAction: primaryAction
                )
            )
    }
}

private struct  CustomToolBarModifier<Leading: View, Trailing: View, Principal: View, PrimaryAction: View>: ViewModifier {
    
    var isPrimaryActionVisible: Bool
    var title: String?
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing
    @ViewBuilder var principal: Principal
    @ViewBuilder var primaryAction: PrimaryAction
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leading
                }
                
                ToolbarItem(placement: .principal) {
                    principal
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    trailing
                }
                
                if isPrimaryActionVisible {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        primaryAction
                    }
                }
                
            }
    }
    
}
