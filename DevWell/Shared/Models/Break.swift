import Foundation
import SwiftUI

struct Break: Identifiable, Codable {
    let id: UUID
    let type: BreakType
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval {
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        } else {
            return Date().timeIntervalSince(startTime)
        }
    }
    var mood: Mood?
    var notes: String?
    var isCompleted: Bool
    
    init(id: UUID = UUID(), 
         type: BreakType,
         startTime: Date = Date(),
         endTime: Date? = nil,
         mood: Mood? = nil,
         notes: String? = nil,
         isCompleted: Bool = false) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.mood = mood
        self.notes = notes
        self.isCompleted = isCompleted
    }
}

enum BreakType: String, Codable, CaseIterable, Identifiable {
    case mindfulness = "Mindfulness"
    case walk = "Walk"
    case water = "Water"
    case stretch = "Stretch"
    case music = "Music"
    case custom = "Custom"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .mindfulness:
            return "brain.head.profile"
        case .walk:
            return "figure.walk"
        case .water:
            return "drop.fill"
        case .stretch:
            return "figure.flexibility"
        case .music:
            return "music.note"
        case .custom:
            return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .mindfulness:
            return Color("BlueAccent")
        case .walk:
            return Color("GreenAccent")
        case .water:
            return Color("LightBlueAccent")
        case .stretch:
            return Color("PurpleAccent")
        case .music:
            return Color("OrangeAccent")
        case .custom:
            return Color("GrayAccent")
        }
    }
    
    var description: String {
        switch self {
        case .mindfulness:
            return "Take a moment to breathe and center yourself"
        case .walk:
            return "Get up and take a short walk"
        case .water:
            return "Hydrate with a glass of water"
        case .stretch:
            return "Stretch your body to reduce tension"
        case .music:
            return "Listen to some relaxing music"
        case .custom:
            return "Your personalized break"
        }
    }
    
    var recommendedDuration: TimeInterval {
        switch self {
        case .mindfulness:
            return 180 // 3 minutes
        case .walk:
            return 300 // 5 minutes
        case .water:
            return 60 // 1 minute
        case .stretch:
            return 120 // 2 minutes
        case .music:
            return 300 // 5 minutes
        case .custom:
            return 300 // 5 minutes
        }
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case great = "Great"
    case good = "Good"
    case neutral = "Neutral"
    case tired = "Tired"
    case stressed = "Stressed"
    
    var id: String { self.rawValue }
    
    var emoji: String {
        switch self {
        case .great:
            return "😄"
        case .good:
            return "🙂"
        case .neutral:
            return "😐"
        case .tired:
            return "😴"
        case .stressed:
            return "😰"
        }
    }
    
    var color: Color {
        switch self {
        case .great:
            return Color("GreenAccent")
        case .good:
            return Color("LightGreenAccent")
        case .neutral:
            return Color("YellowAccent")
        case .tired:
            return Color("OrangeAccent")
        case .stressed:
            return Color("RedAccent")
        }
    }
} 