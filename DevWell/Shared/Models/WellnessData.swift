import Foundation
import SwiftUI

struct WellnessData: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let heartRate: Int
    let heartRateVariability: Double
    let stepCount: Int
    let standHours: Int
    let codeSessionDuration: TimeInterval
    let stressLevel: StressLevel
    
    var wellnessScore: Int {
        // Simple algorithm to calculate wellness score based on various factors
        var score = 50 // Base score
        
        // Heart rate factor - normal resting HR is roughly 60-100
        if heartRate < 60 {
            score += 5 // Athlete-level resting heart rate
        } else if heartRate < 70 {
            score += 4
        } else if heartRate < 80 {
            score += 2
        } else if heartRate > 100 {
            score -= 5 // Elevated heart rate might indicate stress
        }
        
        // HRV factor - higher is generally better
        if heartRateVariability > 50 {
            score += 5
        } else if heartRateVariability > 30 {
            score += 3
        } else if heartRateVariability < 15 {
            score -= 3
        }
        
        // Step count factor - 10,000 steps is a common daily goal
        let stepScore = min(5, Int(stepCount / 2000))
        score += stepScore
        
        // Stand hours factor
        let standScore = min(5, standHours / 2)
        score += standScore
        
        // Code session duration factor - long sessions might indicate overwork
        if codeSessionDuration > 7200 { // 2 hours
            score -= 3
        } else if codeSessionDuration > 3600 { // 1 hour
            score -= 1
        }
        
        // Stress level factor
        switch stressLevel {
        case .low:
            score += 5
        case .medium:
            score += 0 // Neutral case needs an executable statement
        case .high:
            score -= 5
        }
        
        // Ensure score is within range
        return min(100, max(0, score))
    }
    
    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         heartRate: Int = 75,
         heartRateVariability: Double = 25.0,
         stepCount: Int = 5000,
         standHours: Int = 6,
         codeSessionDuration: TimeInterval = 3600,
         stressLevel: StressLevel = .medium) {
        self.id = id
        self.timestamp = timestamp
        self.heartRate = heartRate
        self.heartRateVariability = heartRateVariability
        self.stepCount = stepCount
        self.standHours = standHours
        self.codeSessionDuration = codeSessionDuration
        self.stressLevel = stressLevel
    }
}

enum StressLevel: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low:
            return Color("GreenAccent")
        case .medium:
            return Color("YellowAccent")
        case .high:
            return Color("RedAccent")
        }
    }
}

struct HistoricalWellnessData: Codable, Identifiable {
    let id: UUID
    let date: Date
    var dailyData: [WellnessData]
    
    var averageWellnessScore: Int {
        guard !dailyData.isEmpty else { return 0 }
        let totalScore = dailyData.reduce(0) { $0 + $1.wellnessScore }
        return totalScore / dailyData.count
    }
    
    init(id: UUID = UUID(), date: Date, dailyData: [WellnessData] = []) {
        self.id = id
        self.date = date
        self.dailyData = dailyData
    }
} 