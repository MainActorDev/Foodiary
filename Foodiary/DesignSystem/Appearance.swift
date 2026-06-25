import SwiftUI

// MARK: - Tab Bar Modifier

struct RingTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(FoodiaryDesign.pulseBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(FoodiaryDesign.pulseBackground)
                appearance.shadowColor = UIColor(FoodiaryDesign.pulseBorder)
                appearance.shadowImage = UIImage()
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
    }
}

// MARK: - Nav Bar Modifier

struct RingNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.shadowColor = .clear
                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                    .foregroundColor: UIColor(FoodiaryDesign.pulseInk)
                ]
                appearance.largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                    .foregroundColor: UIColor(FoodiaryDesign.pulseInk)
                ]
                let navBar = UINavigationBar.appearance()
                navBar.standardAppearance = appearance
                navBar.scrollEdgeAppearance = appearance
                navBar.compactAppearance = appearance
                navBar.tintColor = UIColor(FoodiaryDesign.pulseInk)
            }
    }
}
