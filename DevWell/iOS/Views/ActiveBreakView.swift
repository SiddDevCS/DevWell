import SwiftUI

struct ActiveBreakView: View {
    let breakType: BreakType
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userDataStore: UserDataStore
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var selectedMood: Mood?
    @State private var breakNotes: String = ""
    @State private var isShowingCompletionSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: breakType.icon)
                        .font(.system(size: 70))
                        .foregroundColor(breakType.color)
                        .frame(width: 120, height: 120)
                        .background(
                            Circle()
                                .fill(breakType.color.opacity(0.15))
                        )
                    
                    Text(breakType.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(breakType.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                // Timer
                VStack(spacing: 5) {
                    Text(timeString(from: elapsedTime))
                        .font(.system(size: 70, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Elapsed Time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
                
                // Recommended duration
                VStack(spacing: 8) {
                    Text("Recommended Duration")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(breakType.recommendedDuration / 60)) minutes")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 10)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: completeBreak) {
                        Text("Complete Break")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(breakType.color)
                                    .shadow(color: breakType.color.opacity(0.4), radius: 10, x: 0, y: 5)
                            )
                    }
                    
                    Button(action: cancelBreak) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Active Break")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $isShowingCompletionSheet) {
            completionSheet
        }
    }
    
    private var completionSheet: some View {
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
                                                    .fill(selectedMood == mood ? mood.color.opacity(0.15) : Color(.systemBackground))
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
                        )
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Save button
                Button(action: finishBreak) {
                    Text("Save and Complete")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.accentColor)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .disabled(selectedMood == nil)
                .opacity(selectedMood == nil ? 0.6 : 1.0)
            }
            .navigationTitle("How was your break?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isShowingCompletionSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func completeBreak() {
        stopTimer()
        isShowingCompletionSheet = true
    }
    
    private func cancelBreak() {
        stopTimer()
        userDataStore.cancelBreak()
        dismiss()
    }
    
    private func finishBreak() {
        if let mood = selectedMood {
            userDataStore.completeBreak(withMood: mood, notes: breakNotes.isEmpty ? nil : breakNotes)
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        ActiveBreakView(breakType: .mindfulness)
            .environmentObject(UserDataStore())
    }
} 