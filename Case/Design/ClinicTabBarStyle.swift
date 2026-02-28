//
//  ClinicTabBarStyle.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// ✅ Drop-in fix: make TabBar icons/text bright + add colored circular glow behind selected icon
// Put this file anywhere: ClinicTabBarStyle.swift
// Then in ClinicDashboardRootView() add: .modifier(ClinicTabBarStyle())

import SwiftUI

// MARK: - 1) Tab bar global tint (icons/text) + nicer background
struct ClinicTabBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(.white) // selected icon/text
            .onAppear {
                let tabBar = UITabBar.appearance()
                tabBar.isTranslucent = true

                // Dark glass background so icons pop
                tabBar.backgroundColor = UIColor.black.withAlphaComponent(0.18)

                // Selected / unselected colors
                tabBar.tintColor = UIColor.white
                tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.55)

                // Optional: remove default top shadow line
                tabBar.backgroundImage = UIImage()
                tabBar.shadowImage = UIImage()
            }
    }
}