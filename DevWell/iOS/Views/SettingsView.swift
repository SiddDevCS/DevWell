import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showResetConfirmation = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "gearshape.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // Notification Settings
                SettingsSection(title: "Notifications", icon: "bell.fill", iconColor: Color.red) {
                    SettingsToggle(
                        title: "Break Reminders",
                        description: "Get notified when it's time to take a break",
                        isOn: $userDataStore.breakNotificationsEnabled
                    )
                    
                    SettingsToggle(
                        title: "Stress Notifications",
                        description: "Get notified when high stress is detected",
                        isOn: $userDataStore.stressNotificationsEnabled
                    )
                    
                    SettingsToggle(
                        title: "Inactivity Alerts",
                        description: "Get notified when you've been inactive too long",
                        isOn: $userDataStore.inactivityNotificationsEnabled
                    )
                }
                
                // Break Preferences
                SettingsSection(title: "Break Preferences", icon: "timer", iconColor: Color.blue) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Preferred Break Types")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Select which break types you prefer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(BreakType.allCases) { breakType in
                                BreakTypeToggle(
                                    breakType: breakType,
                                    isSelected: userDataStore.preferredBreakTypes.contains(breakType),
                                    onToggle: {
                                        toggleBreakType(breakType)
                                    }
                                )
                            }
                        }
                        .padding(.top, 5)
                    }
                }
                
                // App Settings
                SettingsSection(title: "App Settings", icon: "iphone", iconColor: Color.green) {
                    Button(action: {
                        hasCompletedOnboarding = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color("AccentColor"))
                            
                            Text("Restart Onboarding")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            
                            Text("Reset All Data")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // About
                SettingsSection(title: "About", icon: "info.circle.fill", iconColor: Color.purple) {
                    HStack {
                        Text("App Version")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build Number")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("100")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        // Open privacy policy
                    }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // Open terms of service
                    }) {
                        HStack {
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text("DevWell+ © 2023")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Reset All Data"),
                message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    resetAllData()
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: userDataStore.breakNotificationsEnabled) { _ in
            userDataStore.saveUserSettings()
        }
        .onChange(of: userDataStore.stressNotificationsEnabled) { _ in
            userDataStore.saveUserSettings()
        }
        .onChange(of: userDataStore.inactivityNotificationsEnabled) { _ in
            userDataStore.saveUserSettings()
        }
    }
    
    private func toggleBreakType(_ breakType: BreakType) {
        if userDataStore.preferredBreakTypes.contains(breakType) {
            // Don't allow removing if it's the last one
            if userDataStore.preferredBreakTypes.count > 1 {
                userDataStore.preferredBreakTypes.removeAll { $0 == breakType }
            }
        } else {
            userDataStore.preferredBreakTypes.append(breakType)
        }
        userDataStore.saveUserSettings()
    }
    
    private func resetAllData() {
        // Reset user data store
        UserDefaults.standard.removeObject(forKey: "historicalWellnessData")
        UserDefaults.standard.removeObject(forKey: "breakHistory")
        UserDefaults.standard.removeObject(forKey: "breakNotificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "stressNotificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "inactivityNotificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "preferredBreakTypes")
        
        // Reset the objects
        userDataStore.historicalData = []
        userDataStore.breakHistory = []
        userDataStore.preferredBreakTypes = BreakType.allCases
        
        // Reset default values
        userDataStore.breakNotificationsEnabled = true
        userDataStore.stressNotificationsEnabled = true
        userDataStore.inactivityNotificationsEnabled = true
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(iconColor)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 14) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                .labelsHidden()
        }
    }
}

struct BreakTypeToggle: View {
    let breakType: BreakType
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: breakType.icon)
                    .foregroundColor(isSelected ? .white : breakType.color)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(isSelected ? breakType.color : breakType.color.opacity(0.2))
                    )
                
                Text(breakType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(breakType.color)
                        .font(.caption)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? breakType.color : Color.gray.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? breakType.color.opacity(0.1) : Color.clear)
                    )
            )
        }
    }
} 