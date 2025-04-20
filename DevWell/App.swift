import SwiftUI

@main
struct DevWellMainApp: App {
    @StateObject private var userDataStore = UserDataStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView(onComplete: {
                    hasCompletedOnboarding = true
                })
            } else {
                MainTabView()
                    .environmentObject(userDataStore)
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab {
        case dashboard, breaks, history, settings
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    DashboardView()
                        .navigationTitle("Dashboard")
                }
                .tag(Tab.dashboard)
                
                NavigationView {
                    BreakPlannerView()
                        .navigationTitle("Breaks")
                }
                .tag(Tab.breaks)
                
                NavigationView {
                    BreakHistoryView()
                        .navigationTitle("History")
                }
                .tag(Tab.history)
                
                NavigationView {
                    SettingsView()
                        .navigationTitle("Settings")
                }
                .tag(Tab.settings)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    @Namespace private var animation
    
    var body: some View {
        HStack {
            ForEach([MainTabView.Tab.dashboard, .breaks, .history, .settings], id: \.self) { tab in
                Spacer()
                TabButton(tab: tab, selectedTab: $selectedTab, namespace: animation)
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Material.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .padding(.horizontal)
    }
}

struct TabButton: View {
    let tab: MainTabView.Tab
    @Binding var selectedTab: MainTabView.Tab
    var namespace: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedTab == tab ? Color.theme.primary : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.theme.primary.opacity(0.1))
                            .matchedGeometryEffect(id: "TAB", in: namespace)
                    }
                }
            )
        }
    }
    
    var icon: String {
        switch tab {
        case .dashboard:
            return "house.fill"
        case .breaks:
            return "timer"
        case .history:
            return "calendar"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    var title: String {
        switch tab {
        case .dashboard:
            return "Home"
        case .breaks:
            return "Breaks"
        case .history:
            return "History"
        case .settings:
            return "Settings"
        }
    }
} 