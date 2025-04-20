import SwiftUI

/// A simplified version of UserDataStore used for SwiftUI previews
class UserData: ObservableObject {
    @Published var breaks: [Break] = []
    
    init(sampleData: Bool = true) {
        if sampleData {
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        // Generate some sample breaks for the last 7 days
        let calendar = Calendar.current
        let today = Date()
        
        // Mindfulness breaks
        breaks.append(Break(
            type: .mindfulness,
            startTime: calendar.date(byAdding: .hour, value: -3, to: today)!,
            endTime: calendar.date(byAdding: .hour, value: -3, to: today)!.addingTimeInterval(180),
            mood: .great,
            notes: "Felt really refreshed after this meditation session",
            isCompleted: true
        ))
        
        breaks.append(Break(
            type: .mindfulness,
            startTime: calendar.date(byAdding: .day, value: -1, to: today)!,
            endTime: calendar.date(byAdding: .day, value: -1, to: today)!.addingTimeInterval(300),
            mood: .good,
            isCompleted: true
        ))
        
        // Walking breaks
        breaks.append(Break(
            type: .walk,
            startTime: calendar.date(byAdding: .day, value: -2, to: today)!,
            endTime: calendar.date(byAdding: .day, value: -2, to: today)!.addingTimeInterval(600),
            mood: .great,
            notes: "Nice walk around the block, saw some birds",
            isCompleted: true
        ))
        
        // Stretch breaks
        breaks.append(Break(
            type: .stretch,
            startTime: calendar.date(byAdding: .day, value: -1, to: today)!.addingTimeInterval(14400),
            endTime: calendar.date(byAdding: .day, value: -1, to: today)!.addingTimeInterval(14400 + 180),
            mood: .neutral,
            isCompleted: true
        ))
        
        // Water breaks
        breaks.append(Break(
            type: .water,
            startTime: calendar.date(byAdding: .hour, value: -5, to: today)!,
            endTime: calendar.date(byAdding: .hour, value: -5, to: today)!.addingTimeInterval(60),
            mood: .neutral,
            isCompleted: true
        ))
        
        // Music breaks
        breaks.append(Break(
            type: .music,
            startTime: calendar.date(byAdding: .day, value: -3, to: today)!,
            endTime: calendar.date(byAdding: .day, value: -3, to: today)!.addingTimeInterval(300),
            mood: .great,
            notes: "Listened to my favorite playlist",
            isCompleted: true
        ))
        
        // Some breaks from 4-7 days ago
        for i in 4...7 {
            let randomBreakType = BreakType.allCases.randomElement()!
            let randomMood = Mood.allCases.randomElement()!
            let breakStart = calendar.date(byAdding: .day, value: -i, to: today)!
            let breakDuration = Double(Int.random(in: 2...10) * 60)
            
            breaks.append(Break(
                type: randomBreakType,
                startTime: breakStart,
                endTime: breakStart.addingTimeInterval(breakDuration),
                mood: randomMood,
                isCompleted: true
            ))
        }
        
        // An incomplete break
        breaks.append(Break(
            type: .stretch,
            startTime: calendar.date(byAdding: .hour, value: -1, to: today)!,
            isCompleted: false
        ))
    }
} 