import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var username = ""
    @State private var selectedGoal = WellnessGoal.productivity
    @State private var selectedWorkStyle = WorkStyle.regular
    @State private var preferredNotificationTime = NotificationTime.morning
    @State private var selectedWorkHours = WorkHours.standard
    @State private var preferredBreakTypes: [BreakType] = []
    
    // Track which screens we've completed for proper navigation
    @State private var hasCompletedWelcome = false
    @State private var hasCompletedPersonalization = false
    @State private var hasCompletedWorkStyle = false
    @State private var hasCompletedPreferences = false
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress and navigation
                HStack {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(Color.theme.primary)
                            .padding(.leading)
                        }
                    } else {
                        // Empty view to maintain layout
                        Text("")
                            .padding(.leading)
                    }
                    
                    Spacer()
                    
                    // Progress indicators
                    HStack(spacing: 6) {
                        ForEach(0..<5) { index in
                            Capsule()
                                .fill(currentPage >= index ? Color.theme.primary : Color.theme.secondary.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 18, height: 5)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    Spacer()
                    
                    // Skip button
                    if currentPage < 4 {
                        Button(action: {
                            onComplete()
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        .padding(.trailing)
                    } else {
                        // Empty view to maintain layout
                        Text("")
                            .padding(.trailing)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Content area
                ScrollView {
                    VStack(spacing: 0) {
                        switch currentPage {
                        case 0:
                            WelcomeView(username: $username)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading))
                                )
                        case 1:
                            GoalSelectionView(selectedGoal: $selectedGoal)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading))
                                )
                        case 2:
                            WorkStyleView(selectedWorkStyle: $selectedWorkStyle)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading))
                                )
                        case 3:
                            WorkScheduleView(
                                preferredNotificationTime: $preferredNotificationTime,
                                selectedWorkHours: $selectedWorkHours
                            )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading))
                                )
                        case 4:
                            BreakPreferencesView(preferredBreakTypes: $preferredBreakTypes)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading))
                                )
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .animation(.easeInOut, value: currentPage)
                }
                .frame(maxWidth: .infinity)
                
                // Action buttons
                VStack(spacing: 15) {
                    PrimaryButton(
                        title: buttonTitle,
                        isEnabled: canContinue
                    ) {
                        if currentPage == 4 {
                            // Save user preferences
                            saveUserPreferences()
                            onComplete()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var canContinue: Bool {
        switch currentPage {
        case 0:
            return !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 1, 2, 3:
            return true // These always have selections
        case 4:
            return !preferredBreakTypes.isEmpty
        default:
            return true
        }
    }
    
    private var buttonTitle: String {
        return currentPage == 4 ? "Get Started" : "Continue"
    }
    
    private func saveUserPreferences() {
        // Save all user preferences to UserDefaults
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(selectedGoal.rawValue, forKey: "selectedGoal")
        UserDefaults.standard.set(selectedWorkStyle.rawValue, forKey: "selectedWorkStyle")
        UserDefaults.standard.set(preferredNotificationTime.rawValue, forKey: "preferredNotificationTime")
        UserDefaults.standard.set(selectedWorkHours.rawValue, forKey: "selectedWorkHours")
        
        // Save break types
        let breakTypeValues = preferredBreakTypes.map { $0.rawValue }
        UserDefaults.standard.set(breakTypeValues, forKey: "preferredBreakTypes")
    }
}

// MARK: - Onboarding Views

struct WelcomeView: View {
    @Binding var username: String
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and welcome header
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.theme.primary.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.theme.primary)
                }
                .padding(.top, 30)
                
                Text("Welcome to DevWell")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Your personal wellness companion for productive breaks and mindful development.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Name input
            VStack(alignment: .leading, spacing: 10) {
                Text("What should we call you?")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                
                TextField("Enter your name", text: $username)
                    .font(.system(size: 18))
                    .padding()
                    .background(Color.theme.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.theme.primary.opacity(0.3), lineWidth: 1)
                    )
                    .autocapitalization(.words)
                
                Text("This helps us personalize your experience")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                    .padding(.leading, 3)
            }
            .padding(.horizontal, 15)
        }
    }
}

struct GoalSelectionView: View {
    @Binding var selectedGoal: WellnessGoal
    
    var body: some View {
        VStack(spacing: 30) {
            // Section header
            VStack(spacing: 10) {
                Text("What's your primary goal?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Text("We'll customize your experience based on what matters most to you.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Goal options
            VStack(spacing: 15) {
                ForEach(WellnessGoal.allCases) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: selectedGoal == goal,
                        action: { selectedGoal = goal }
                    )
                }
            }
        }
    }
}

struct WorkStyleView: View {
    @Binding var selectedWorkStyle: WorkStyle
    
    var body: some View {
        VStack(spacing: 30) {
            // Section header
            VStack(spacing: 10) {
                Text("How do you work?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Text("Tell us about your typical workday so we can recommend optimal break schedules.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Work style options
            VStack(spacing: 15) {
                ForEach(WorkStyle.allCases) { workStyle in
                    WorkStyleCard(
                        workStyle: workStyle,
                        isSelected: selectedWorkStyle == workStyle,
                        action: { selectedWorkStyle = workStyle }
                    )
                }
            }
        }
    }
}

struct WorkScheduleView: View {
    @Binding var preferredNotificationTime: NotificationTime
    @Binding var selectedWorkHours: WorkHours
    
    var body: some View {
        VStack(spacing: 30) {
            // Section header
            VStack(spacing: 10) {
                Text("When do you work?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Text("This helps us schedule your breaks at the most effective times.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Work hours selection
            VStack(alignment: .leading, spacing: 20) {
                Text("Your typical work hours:")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(WorkHours.allCases) { workHours in
                        Button(action: {
                            selectedWorkHours = workHours
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workHours.title)
                                        .font(.headline)
                                        .foregroundColor(Color.theme.primaryText)
                                    
                                    Text(workHours.timeRange)
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.secondaryText)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedWorkHours == workHours ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedWorkHours == workHours ? Color.theme.primary : Color.theme.secondaryText.opacity(0.5))
                                    .font(.title3)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.theme.surface)
                                    .shadow(color: selectedWorkHours == workHours ? Color.theme.primary.opacity(0.2) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedWorkHours == workHours ? Color.theme.primary : Color.clear, lineWidth: selectedWorkHours == workHours ? 1.5 : 0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                // Notification time preference
                VStack(alignment: .leading, spacing: 15) {
                    Text("When would you like break reminders?")
                        .font(.headline)
                        .foregroundColor(Color.theme.primaryText)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    HStack(spacing: 12) {
                        ForEach(NotificationTime.allCases) { time in
                            Button(action: {
                                preferredNotificationTime = time
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: time.icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(preferredNotificationTime == time ? .white : Color.theme.primary)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(preferredNotificationTime == time ? Color.theme.primary : Color.theme.primary.opacity(0.1))
                                        )
                                    
                                    Text(time.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.theme.primaryText)
                                }
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.theme.surface)
                                        .shadow(color: preferredNotificationTime == time ? Color.theme.primary.opacity(0.2) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(preferredNotificationTime == time ? Color.theme.primary : Color.clear, lineWidth: preferredNotificationTime == time ? 1.5 : 0)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct BreakPreferencesView: View {
    @Binding var preferredBreakTypes: [BreakType]
    
    var body: some View {
        VStack(spacing: 30) {
            // Section header
            VStack(spacing: 10) {
                Text("Break Preferences")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                
                Text("Select your preferred break types to help us personalize your recommendations.")
                    .font(.system(size: 17))
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            
            // Break type selection grid
            VStack(alignment: .leading, spacing: 15) {
                Text("Select at least one:")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(BreakType.allCases) { breakType in
                        BreakTypeSelectionCard(
                            breakType: breakType,
                            isSelected: preferredBreakTypes.contains(breakType),
                            action: {
                                toggleBreakType(breakType)
                            }
                        )
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    private func toggleBreakType(_ breakType: BreakType) {
        if preferredBreakTypes.contains(breakType) {
            preferredBreakTypes.removeAll { $0 == breakType }
        } else {
            preferredBreakTypes.append(breakType)
        }
    }
}

// MARK: - Component Views

struct GoalOptionCard: View {
    let goal: WellnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color.theme.primary)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.theme.primary : Color.theme.primary.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text(goal.description)
                        .font(.subheadline)
                        .foregroundColor(Color.theme.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.secondaryText.opacity(0.5))
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .shadow(color: isSelected ? Color.theme.primary.opacity(0.2) : Color.black.opacity(0.05), radius: isSelected ? 8 : 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WorkStyleCard: View {
    let workStyle: WorkStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: workStyle.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color.theme.primary)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.theme.primary : Color.theme.primary.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(workStyle.title)
                        .font(.headline)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text(workStyle.description)
                        .font(.subheadline)
                        .foregroundColor(Color.theme.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.secondaryText.opacity(0.5))
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .shadow(color: isSelected ? Color.theme.primary.opacity(0.2) : Color.black.opacity(0.05), radius: isSelected ? 8 : 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BreakTypeSelectionCard: View {
    let breakType: BreakType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? breakType.color : Color.theme.primary.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: breakType.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : breakType.color)
                }
                
                Text(breakType.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.theme.primaryText)
                
                Text("\(Int(breakType.recommendedDuration / 60)) min")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
            .padding()
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .shadow(color: isSelected ? breakType.color.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? breakType.color : Color.clear, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Button Styles

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(height: 56)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? Color.theme.primary : Color.theme.secondaryText.opacity(0.3))
                )
                .animation(.easeInOut, value: isEnabled)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Models

enum WellnessGoal: String, CaseIterable, Identifiable {
    case productivity = "productivity"
    case stress = "stress"
    case health = "health"
    case focus = "focus"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .productivity: return "Boost Productivity"
        case .stress: return "Reduce Stress"
        case .health: return "Improve Health"
        case .focus: return "Enhance Focus"
        }
    }
    
    var description: String {
        switch self {
        case .productivity: return "Take strategic breaks to maximize output and energy."
        case .stress: return "Use mindful practices to lower stress and anxiety."
        case .health: return "Combat sedentary work habits with movement breaks."
        case .focus: return "Structure work sessions for deeper concentration."
        }
    }
    
    var icon: String {
        switch self {
        case .productivity: return "bolt.fill"
        case .stress: return "heart.fill"
        case .health: return "figure.walk"
        case .focus: return "brain"
        }
    }
}

enum WorkStyle: String, CaseIterable, Identifiable {
    case regular = "regular"
    case intense = "intense"
    case flexible = "flexible"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .regular: return "Regular Schedule"
        case .intense: return "Intense Focus"
        case .flexible: return "Flexible Timing"
        }
    }
    
    var description: String {
        switch self {
        case .regular: return "Standard 9-5 workday with consistent break patterns."
        case .intense: return "Long focus periods with fewer, strategic breaks."
        case .flexible: return "Variable schedule with adaptable break timing."
        }
    }
    
    var icon: String {
        switch self {
        case .regular: return "clock.fill"
        case .intense: return "flame.fill"
        case .flexible: return "slider.horizontal.3"
        }
    }
}

enum NotificationTime: String, CaseIterable, Identifiable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        }
    }
}

enum WorkHours: String, CaseIterable, Identifiable {
    case early = "early"
    case standard = "standard"
    case late = "late"
    case variable = "variable"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .early: return "Early Bird"
        case .standard: return "Standard Hours"
        case .late: return "Night Owl"
        case .variable: return "Variable Hours"
        }
    }
    
    var timeRange: String {
        switch self {
        case .early: return "6:00 AM - 2:00 PM"
        case .standard: return "9:00 AM - 5:00 PM"
        case .late: return "12:00 PM - 8:00 PM"
        case .variable: return "Changing schedule"
        }
    }
}

// MARK: - Color Theme Extension

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Light mode colors
    let primary = Color("PrimaryColor")
    let secondary = Color("SecondaryColor")
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let surface = Color("SurfaceColor")
    let primaryText = Color("PrimaryTextColor")
    let secondaryText = Color("SecondaryTextColor")
    let error = Color("ErrorColor")
} 