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
                .navigationTitle("Today")
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
                Text("TODAY")
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
                .navigationTitle("Meal Plan")
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
                Text("MEAL PLAN")
            }
            .tag(1)
            
            NavigationStack {
                ProfileView(state: state)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.large)
                    .modifier(NBNavBarModifier())
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("PROFILE")
            }
            .tag(2)
        }
        .modifier(NBTabBarModifier())
        .tint(FoodiaryDesign.coral)
        .font(FoodiaryTypography.label)
    }
}
