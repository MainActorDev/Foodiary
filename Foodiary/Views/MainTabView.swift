import SwiftUI

struct MainTabView: View {
    @Bindable var state: AppState
    @State private var selectedTab = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0
    @EnvironmentObject private var localeManager: LocaleManager

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Today
            NavigationStack {
                TodayDashboardView(
                    state: state,
                    onCreateMealPlan: { state.createTodayMealPlan() },
                    onTapMeal: { index in
                        selectedMealIndex = index
                        showMealDetail = true
                    }
                )
                .navigationDestination(isPresented: $showMealDetail) {
                    MealDetailView(state: state, mealIndex: selectedMealIndex, isPresented: $showMealDetail)
                }
                .toolbar(showMealDetail ? .hidden : .visible, for: .tabBar)
                .animation(.easeInOut(duration: 0.25), value: showMealDetail)
                .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Image(systemName: "flame.fill")
                Text(L10n["tab.today"])
            }
            .tag(0)

            // Tab 1: Plan
            NavigationStack {
                PlanView(state: state)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text(L10n["tab.plan"])
            }
            .tag(1)

            // Tab 2: Insights
            NavigationStack {
                InsightsView(state: state)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text(L10n["tab.insights"])
            }
            .tag(2)

            // Tab 3: Profile
            NavigationStack {
                ProfileView(state: state)
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text(L10n["tab.profile"])
            }
            .tag(3)
        }
        .modifier(RingTabBarModifier())
        .tint(FoodiaryDesign.pulsePrimary)
        .font(FoodiaryTypography.label)
    }
}
