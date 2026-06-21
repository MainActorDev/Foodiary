import SwiftUI

struct MainTabView: View {
    @ObservedObject var state: AppState
    @State private var selectedTab = 0
    @State private var showMealDetail = false
    @State private var selectedMealIndex = 0
    
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
                .navigationTitle(L10n["nav.today"])
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(isPresented: $showMealDetail) {
                    MealDetailView(
                        state: state,
                        mealIndex: selectedMealIndex,
                        isPresented: $showMealDetail
                    )
                }
                .modifier(RingNavBarModifier())
            }
            .tabItem {
                Image(systemName: "circle.circle.fill")
                Text(L10n["tab.today"])
            }
            .tag(0)
            
            // Tab 1: Plan (week calendar + date-based meal planning)
            NavigationStack {
                PlanView(state: state)
                    .navigationTitle(L10n["nav.plan"])
                    .navigationBarTitleDisplayMode(.large)
                    .modifier(RingNavBarModifier())
            }
            .tabItem {
                Image(systemName: "calendar")
                Text(L10n["tab.plan"])
            }
            .tag(1)
            
            // Tab 2: Insights
            NavigationStack {
                InsightsView(state: state)
                    .navigationTitle(L10n["nav.insights"])
                    .navigationBarTitleDisplayMode(.large)
                    .modifier(RingNavBarModifier())
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text(L10n["tab.insights"])
            }
            .tag(2)
            
            // Tab 3: Profile
            NavigationStack {
                ProfileView(state: state)
                    .navigationTitle(L10n["nav.profile"])
                    .navigationBarTitleDisplayMode(.large)
                    .modifier(RingNavBarModifier())
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text(L10n["tab.profile"])
            }
            .tag(3)
        }
        .modifier(RingTabBarModifier())
        .tint(FoodiaryDesign.accent)
        .font(FoodiaryTypography.label)
    }
}

// MARK: - Insights View (macro breakdown + calorie summary)

struct InsightsView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Calorie breakdown
                VStack(spacing: 12) {
                    Text(L10n["label.calories"])
                        .sectionLabel()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 8) {
                        statBox(value: "\(state.plannedCalories)", label: L10n["label.consumed"], color: FoodiaryDesign.accent)
                        statBox(value: "\(state.targetCalories)", label: L10n["label.target"], color: FoodiaryDesign.black)
                    }
                }
                .ringCard()
                
                // Macro breakdown
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n["label.today_macros"])
                        .sectionLabel()
                    MacroBar(label: "Protein", value: state.totalProtein, maxValue: state.maxMacro, color: Color(hex: "2563EB"))
                    MacroBar(label: "Carbs", value: state.totalCarbs, maxValue: state.maxMacro, color: Color(hex: "D97706"))
                    MacroBar(label: "Fat", value: state.totalFat, maxValue: state.maxMacro, color: Color(hex: "DC2626"))
                }
                .ringCardCompact()
                
                // Status
                if state.hasTodayMealPlan {
                    let (bg, text): (Color, String) = {
                        if state.plannedCalories == 0 {
                            return (FoodiaryDesign.muted, "No food logged yet")
                        } else if state.isOverTarget {
                            return (Color(hex: "FEE2E2"), state.localizedStatusMessage.uppercased())
                        } else {
                            return (FoodiaryDesign.secondaryLight, state.localizedStatusMessage.uppercased())
                        }
                    }()
                    Text(text).ringBadge(bg: bg)
                }
            }
            .padding(20)
        }
        .background(FoodiaryDesign.background)
    }
    
    func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(color)
            Text(label)
                .font(FoodiaryTypography.label)
                .foregroundColor(FoodiaryDesign.mutedFg)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(FoodiaryDesign.muted)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
