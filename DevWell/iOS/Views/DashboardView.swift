import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    @AppStorage("username") private var username: String = "there"
    
    // Wellness stats
    @State private var totalBreaksToday: Int = 0
    @State private var totalBreakMinutes: Int = 0
    @State private var currentStreak: Int = 0
    @State private var showingBreakSheet = false
    
    // For chart animation
    @State private var showCharts = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header Section with welcome and headline
                VStack(spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if !username.isEmpty {
                                Text("Hello, \(username)!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color.theme.primaryText)
                            } else {
                                Text("Hello!")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(Color.theme.primaryText)
                            }
                            
                            Text("Today is \(formattedDate)")
                                .font(.subheadline)
                                .foregroundColor(Color.theme.secondaryText)
                        }
                        
                        Spacer()
                        
                        ProfileAvatarView()
                    }
                    .padding(.horizontal)
                    
                    // App Purpose Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.theme.primary, Color.theme.primary.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: Color.theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mindful Breaks, Better Code")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Take strategic breaks to boost productivity and wellness throughout your development day.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                // Quick Stats Section
                HStack(spacing: 15) {
                    StatisticCard(
                        icon: "figure.walk",
                        iconColor: Color.theme.secondary,
                        number: String(totalBreaksToday),
                        label: "Today's Breaks",
                        trend: "+\(totalBreaksToday > 0 ? "1" : "0")"
                    )
                    
                    StatisticCard(
                        icon: "clock",
                        iconColor: Color.theme.primary,
                        number: "\(totalBreakMinutes)m",
                        label: "Break Time",
                        trend: "↑ \(totalBreakMinutes > 0 ? "5m" : "0m")"
                    )
                }
                .padding(.horizontal)
                
                // Streak Card
                StreakCard(currentStreak: currentStreak)
                    .padding(.horizontal)
                
                // Recommendations Section
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Recommendations", icon: "lightbulb.fill", color: Color.theme.accent)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        RecommendationCard(
                            type: .mindfulness,
                            action: { showBreakSheet(type: .mindfulness) }
                        )
                        
                        RecommendationCard(
                            type: .stretch,
                            action: { showBreakSheet(type: .stretch) }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Wellness Insights
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Wellness Insights", icon: "chart.bar.fill", color: Color.theme.primary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.theme.surface)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text("Mood Trends")
                                    .font(.headline)
                                    .foregroundColor(Color.theme.primaryText)
                                
                                Spacer()
                                
                                NavigationLink(destination: BreakHistoryView().environmentObject(UserData())) {
                                    Text("See More")
                                        .font(.caption)
                                        .foregroundColor(Color.theme.primary)
                                }
                            }
                            
                            BarChartView()
                                .frame(height: 150)
                                .padding(.top, 5)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 15) {
                    SectionHeader(title: "Quick Actions", icon: "bolt.fill", color: Color.theme.accent)
                    
                    HStack(spacing: 15) {
                        ActionButton(
                            title: "Start Break",
                            icon: "play.fill",
                            color: Color.theme.primary
                        ) {
                            showingBreakSheet = true
                        }
                        
                        ActionButton(
                            title: "Schedule",
                            icon: "calendar.badge.clock",
                            color: Color.theme.secondary
                        ) {
                            // Open scheduler
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
            .onAppear {
                loadStats()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.7)) {
                        showCharts = true
                    }
                }
            }
            .sheet(isPresented: $showingBreakSheet) {
                BreakTypeSelectionSheet { breakType in
                    startBreak(type: breakType)
                    showingBreakSheet = false
                }
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private func loadStats() {
        // Calculate statistics from user data store
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Count today's breaks
        totalBreaksToday = userDataStore.breakHistory.filter { 
            calendar.isDate($0.startTime, inSameDayAs: today) && $0.isCompleted 
        }.count
        
        // Calculate total break minutes
        totalBreakMinutes = Int(userDataStore.breakHistory.filter { 
            calendar.isDate($0.startTime, inSameDayAs: today) && $0.isCompleted 
        }.reduce(0) { $0 + $1.duration } / 60)
        
        // Calculate streak (simplified for demo - would be more complex in production)
        var streak = 0
        let pastDays = 5 // Look back 5 days max
        
        for dayOffset in 0..<pastDays {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let breaksOnDay = userDataStore.breakHistory.filter {
                calendar.isDate($0.startTime, inSameDayAs: date) && $0.isCompleted
            }
            
            if breaksOnDay.isEmpty {
                break
            }
            
            streak += 1
        }
        
        currentStreak = max(streak, 1) // Always show at least 1 day streak for demo
    }
    
    private func showBreakSheet(type: BreakType) {
        userDataStore.startBreak(type: type)
    }
    
    private func startBreak(type: BreakType) {
        userDataStore.startBreak(type: type)
        // Navigate to the active break view
        NavigationUtil.navigate(to: ActiveBreakView(breakType: type))
    }
}

// MARK: - Dashboard Component Views

struct ProfileAvatarView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.theme.primary.opacity(0.2))
                .frame(width: 50, height: 50)
            
            Text("S")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color.theme.primary)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .semibold))
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.primaryText)
        }
    }
}

struct StatisticCard: View {
    let icon: String
    let iconColor: Color
    let number: String
    let label: String
    let trend: String
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showDetail.toggle()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 10) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(iconColor)
                    }
                    
                    // Stat
                    VStack(alignment: .leading, spacing: 4) {
                        Text(number)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.primaryText)
                        
                        Text(label)
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                    
                    // Trend
                    Text(trend)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.theme.secondary)
                        .padding(6)
                        .background(
                            Capsule()
                                .fill(Color.theme.secondary.opacity(0.1))
                        )
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .sheet(isPresented: $showDetail) {
            StatDetailView(icon: icon, iconColor: iconColor, title: label, value: number, trend: trend)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StreakCard: View {
    let currentStreak: Int
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showDetail.toggle()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.theme.accent.opacity(0.9), Color.theme.accent.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(color: Color.theme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Streak")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("\(currentStreak) day\(currentStreak == 1 ? "" : "s")")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Keep it up! 🔥")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 4)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .trim(from: 0, to: min(CGFloat(currentStreak) / 7.0, 1.0))
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                        
                        Image(systemName: "flame.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showDetail) {
            StreakDetailView(currentStreak: currentStreak)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecommendationCard: View {
    let type: BreakType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.theme.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: type.icon)
                            .font(.system(size: 24))
                            .foregroundColor(type.color)
                    }
                    
                    Text(type.rawValue)
                        .font(.headline)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text("\(Int(type.recommendedDuration / 60)) min")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
                .padding(.vertical, 15)
            }
            .frame(height: 150)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
            )
        }
    }
}

struct BarChartView: View {
    @State private var animateChart = false
    
    let data: [CGFloat] = [0.4, 0.6, 0.3, 0.8, 0.5, 0.7, 0.2]
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<data.count, id: \.self) { index in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.theme.primary.opacity(0.7 + 0.3 * data[index]))
                        .frame(height: animateChart ? data[index] * 130 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateChart)
                    
                    Text(days[index])
                        .font(.caption2)
                        .foregroundColor(Color.theme.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateChart = true
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
        .environmentObject(UserDataStore())
    }
}

// MARK: - Navigation Utility
struct NavigationUtil {
    static func navigate<Destination: View>(to destination: Destination) {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
        
        if let rootViewController = keyWindow?.rootViewController as? UIHostingController<AnyView> {
            let hostingController = UIHostingController(rootView: destination)
            rootViewController.present(hostingController, animated: true)
        }
    }
}

// Detailed views for when cards are tapped
struct StatDetailView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let trend: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(iconColor)
            }
            .padding(.top, 20)
            
            // Title and value
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.primaryText)
            
            Text(value)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(Color.theme.primaryText)
            
            // Trend with animation
            HStack {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(Color.theme.secondary)
                
                Text(trend)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.theme.secondary.opacity(0.1))
            )
            
            // Additional info
            VStack(alignment: .leading, spacing: 15) {
                Text("Insights")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                
                HStack(spacing: 15) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(Color.theme.primary)
                    
                    VStack(alignment: .leading) {
                        Text(title == "Today's Breaks" ? "Break Pattern" : "Time Distribution")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.theme.primaryText)
                        
                        Text(title == "Today's Breaks" ? 
                            "You tend to take breaks in the afternoon" : 
                            "Most of your break time is spent on mindfulness")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.theme.surface)
                )
                
                HStack(spacing: 15) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color.theme.accent)
                    
                    VStack(alignment: .leading) {
                        Text("Recommendation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.theme.primaryText)
                        
                        Text(title == "Today's Breaks" ? 
                            "Try adding a morning break to start your day right" : 
                            "Consider adding variety with different break types")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.theme.surface)
                )
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color.theme.background.ignoresSafeArea())
    }
}

struct StreakDetailView: View {
    let currentStreak: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            // Header
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Streak icon
            ZStack {
                Circle()
                    .fill(Color.theme.accent.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.theme.accent)
            }
            
            // Streak info
            Text("Current Streak")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.primaryText)
            
            Text("\(currentStreak) day\(currentStreak == 1 ? "" : "s")")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(Color.theme.primaryText)
            
            // Weekly progress
            VStack(alignment: .leading, spacing: 15) {
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.theme.accent, Color.theme.primary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: min(CGFloat(currentStreak) / 7.0 * UIScreen.main.bounds.width - 40, UIScreen.main.bounds.width - 40), height: 20)
                }
                
                HStack {
                    Text("0 days")
                    Spacer()
                    Text("7 days")
                }
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
            }
            .padding()
            
            // Achievements
            VStack(alignment: .leading, spacing: 15) {
                Text("Achievements")
                    .font(.headline)
                    .foregroundColor(Color.theme.primaryText)
                
                HStack(spacing: 15) {
                    ForEach(0..<3) { i in
                        let isAchieved = i == 0 || (i == 1 && currentStreak >= 3)
                        
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(isAchieved ? Color.theme.primary.opacity(0.2) : Color.gray.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: i == 0 ? "1.circle.fill" : (i == 1 ? "3.circle.fill" : "7.circle.fill"))
                                    .font(.title)
                                    .foregroundColor(isAchieved ? Color.theme.primary : Color.gray)
                            }
                            
                            Text(i == 0 ? "First Day" : (i == 1 ? "3 Day Streak" : "7 Day Streak"))
                                .font(.caption)
                                .foregroundColor(isAchieved ? Color.theme.primaryText : Color.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color.theme.background.ignoresSafeArea())
    }
} 