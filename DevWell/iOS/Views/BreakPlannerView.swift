import SwiftUI

struct BreakPlannerView: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    
    @State private var isShowingActiveBreak = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isShowingCompletionSheet = false
    @State private var selectedMood: Mood?
    @State private var breakNotes: String = ""
    @State private var isShowingScheduler = false
    @State private var scheduledTime: Date = Date().addingTimeInterval(3600) // 1 hour from now
    @State private var selectedBreakType: BreakType = .mindfulness
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Welcome section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Take a moment for yourself today.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Quick start break section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Quick Start Break")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "sparkles")
                            .foregroundColor(Color("AccentColor"))
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(BreakType.allCases) { breakType in
                                ModernBreakTypeCard(type: breakType) {
                                    startBreak(type: breakType)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    }
                }
                
                // Active break section
                if userDataStore.activeBreak != nil {
                    ModernActiveBreakCard(
                        breakType: userDataStore.activeBreak!.type,
                        elapsedTime: elapsedTime,
                        onComplete: {
                            completeBreak()
                        },
                        onCancel: {
                            cancelBreak()
                        }
                    )
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Schedule section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Schedule a Break")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(Color("AccentColor"))
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        isShowingScheduler = true
                    }) {
                        HStack {
                            Image(systemName: "alarm")
                                .font(.title3)
                                .foregroundColor(Color("AccentColor"))
                            
                            Text("Schedule Break Reminder")
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .padding(.horizontal)
                    }
                }
                
                // Tip of the day
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color.yellow)
                        
                        Text("Tip of the day")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("Taking 5-minute breaks every hour can improve your focus by up to 30% and reduce stress levels throughout the day.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $isShowingCompletionSheet) {
            ModernBreakCompletionSheet(
                selectedMood: $selectedMood,
                breakNotes: $breakNotes,
                onComplete: finishBreak,
                onCancel: {
                    isShowingCompletionSheet = false
                }
            )
        }
        .sheet(isPresented: $isShowingScheduler) {
            ModernBreakSchedulerSheet(
                scheduledTime: $scheduledTime,
                selectedBreakType: $selectedBreakType,
                onSchedule: scheduleBreak,
                onCancel: {
                    isShowingScheduler = false
                }
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func startBreak(type: BreakType) {
        withAnimation {
            userDataStore.startBreak(type: type)
            startTimer()
        }
    }
    
    private func completeBreak() {
        stopTimer()
        isShowingCompletionSheet = true
    }
    
    private func cancelBreak() {
        withAnimation {
            stopTimer()
            userDataStore.cancelBreak()
        }
    }
    
    private func finishBreak() {
        if let mood = selectedMood {
            userDataStore.completeBreak(withMood: mood, notes: breakNotes.isEmpty ? nil : breakNotes)
            
            // Reset state
            selectedMood = nil
            breakNotes = ""
            isShowingCompletionSheet = false
        }
    }
    
    private func scheduleBreak() {
        // In a real app, this would connect to a notification manager
        // We'll just close the sheet for this example
        isShowingScheduler = false
    }
    
    private func startTimer() {
        elapsedTime = userDataStore.activeBreak?.duration ?? 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1.0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ModernBreakTypeCard: View {
    let type: BreakType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 28))
                        .foregroundColor(type.color)
                }
                
                VStack(spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(Int(type.recommendedDuration / 60)) min")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 110, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct ModernActiveBreakCard: View {
    let breakType: BreakType
    let elapsedTime: TimeInterval
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Break")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(breakType.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(breakType.color.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                    
                    Image(systemName: breakType.icon)
                        .font(.title2)
                        .foregroundColor(breakType.color)
                }
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
            }
            
            // Timer
            VStack(spacing: 5) {
                Text(timeString(from: elapsedTime))
                    .font(.system(.largeTitle, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Elapsed Time")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 5)
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.8))
                        )
                }
                
                Button(action: onComplete) {
                    Text("Complete")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(breakType.color)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ModernBreakCompletionSheet: View {
    @Binding var selectedMood: Mood?
    @Binding var breakNotes: String
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color("GreenAccent"))
                    .padding(.top, 20)
                
                Text("Break Completed!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Mood Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("How do you feel now?")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Mood.allCases) { mood in
                                Button(action: {
                                    selectedMood = mood
                                }) {
                                    VStack(spacing: 8) {
                                        Text(mood.emoji)
                                            .font(.system(size: 36))
                                        
                                        Text(mood.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedMood == mood ? mood.color : Color.gray.opacity(0.3), lineWidth: 2)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(selectedMood == mood ? mood.color.opacity(0.15) : (colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.5)))
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add notes (optional)")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    TextEditor(text: $breakNotes)
                        .frame(height: 120)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                                )
                        )
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Action buttons
                Button(action: onComplete) {
                    Text("Save and Complete")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedMood != nil ? Color("AccentColor") : Color.gray)
                        )
                        .padding(.horizontal)
                }
                .disabled(selectedMood == nil)
                .padding(.bottom, 20)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            })
        }
    }
}

struct ModernBreakSchedulerSheet: View {
    @Binding var scheduledTime: Date
    @Binding var selectedBreakType: BreakType
    let onSchedule: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Header
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.largeTitle)
                        .foregroundColor(Color("AccentColor"))
                    
                    Text("Schedule a Break")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Time Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Time")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    DatePicker(
                        "",
                        selection: $scheduledTime,
                        displayedComponents: [.hourAndMinute, .date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(Color("AccentColor"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                
                // Break Type Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Break Type")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(BreakType.allCases) { type in
                                Button(action: {
                                    selectedBreakType = type
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: type.icon)
                                            .foregroundColor(selectedBreakType == type ? .white : type.color)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(selectedBreakType == type ? type.color : type.color.opacity(0.2))
                                            )
                                        
                                        Text(type.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(selectedBreakType == type ? .primary : .secondary)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedBreakType == type ? type.color.opacity(0.1) : Color.clear)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedBreakType == type ? type.color : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Schedule Button
                Button(action: onSchedule) {
                    Text("Schedule Break")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("AccentColor"))
                        )
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            })
        }
    }
} 