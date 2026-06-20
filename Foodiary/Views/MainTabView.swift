import SwiftUI

struct MainTabView: View {
    @ObservedObject var state: AppState
    @State private var selectedTab = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayDashboardView(
                    state: state,
                    onCreateMealPlan: { state.createTodayMealPlan() },
                    onTapMeal: { index in
                        selectedMealIndex = index
                        showMealDetail = true
                    }
                )
                .navigationTitle(L10n["nav.today"])
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(isPresented: $showMealDetail) {
                    MealDetailView(
                        state: state,
                        mealIndex: selectedMealIndex,
                        isPresented: $showMealDetail
                    )
                }
                .modifier(NBNavBarModifier())
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text(L10n["tab.today"])
            }
            .tag(0)
            
            NavigationStack {
                MealPlanView(
                    state: state,
                    onCreateMealPlan: { state.createTodayMealPlan() },
                    onTapMeal: { index in
                        selectedMealIndex = index
                        showMealDetail = true
                    }
                )
                .navigationTitle(L10n["nav.meal_plan"])
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(isPresented: $showMealDetail) {
                    MealDetailView(
                        state: state,
                        mealIndex: selectedMealIndex,
                        isPresented: $showMealDetail
                    )
                }
                .modifier(NBNavBarModifier())
            }
            .tabItem {
                Image(systemName: "fork.knife")
                Text(L10n["tab.meal_plan"])
            }
            .tag(1)
            
            NavigationStack {
                ProfileView(state: state)
                    .navigationTitle(L10n["nav.profile"])
                    .navigationBarTitleDisplayMode(.large)
                    .modifier(NBNavBarModifier())
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text(L10n["tab.profile"])
            }
            .tag(2)
        }
        .modifier(NBTabBarModifier())
        .tint(FoodiaryDesign.coral)
        .font(FoodiaryTypography.label)
    }
}
