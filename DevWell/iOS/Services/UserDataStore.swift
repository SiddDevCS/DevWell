import Foundation
import Combine

class UserDataStore: ObservableObject {
    // Current wellness data
    @Published var currentWellnessData: WellnessData = WellnessData()
    
    // Historical wellness data (daily summaries)
    @Published var historicalData: [HistoricalWellnessData] = []
    
    // Break records
    @Published var breakHistory: [Break] = []
    @Published var activeBreak: Break?
    
    // User settings
    @Published var breakNotificationsEnabled: Bool = true
    @Published var stressNotificationsEnabled: Bool = true
    @Published var inactivityNotificationsEnabled: Bool = true
    @Published var preferredBreakTypes: [BreakType] = BreakType.allCases
    
    private let historicalDataKey = "historicalWellnessData"
    private let breakHistoryKey = "breakHistory"
    private let userSettingsKey = "userSettings"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Save historical data when it changes
        $historicalData
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] data in
                self?.saveHistoricalData(data)
            }
            .store(in: &cancellables)
        
        // Save break history when it changes
        $breakHistory
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] breaks in
                self?.saveBreakHistory(breaks)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Break Management
    
    func startBreak(type: BreakType) {
        activeBreak = Break(type: type)
    }
    
    func completeBreak(withMood mood: Mood, notes: String? = nil) {
        guard var break_ = activeBreak else { return }
        
        break_.endTime = Date()
        break_.mood = mood
        break_.notes = notes
        break_.isCompleted = true
        
        breakHistory.append(break_)
        activeBreak = nil
    }
    
    func cancelBreak() {
        activeBreak = nil
    }
    
    // MARK: - Wellness Data Management
    
    func updateWellnessData(_ data: WellnessData) {
        currentWellnessData = data
        
        // Update historical data
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = historicalData.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            // Update existing entry for today
            var updatedDailyData = historicalData[index].dailyData
            updatedDailyData.append(data)
            
            let averageScore = calculateAverageScore(from: updatedDailyData)
            historicalData[index] = HistoricalWellnessData(
                id: historicalData[index].id,
                date: today,
                dailyData: updatedDailyData
            )
        } else {
            // Create new entry for today
            let newHistoricalData = HistoricalWellnessData(
                date: today,
                dailyData: [data]
            )
            historicalData.append(newHistoricalData)
        }
    }
    
    private func calculateAverageScore(from data: [WellnessData]) -> Int {
        guard !data.isEmpty else { return 0 }
        let sum = data.reduce(0) { $0 + $1.wellnessScore }
        return sum / data.count
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadHistoricalData()
        loadBreakHistory()
        loadUserSettings()
    }
    
    private func loadHistoricalData() {
        guard let data = UserDefaults.standard.data(forKey: historicalDataKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([HistoricalWellnessData].self, from: data)
            historicalData = decoded
        } catch {
            print("Failed to load historical wellness data: \(error.localizedDescription)")
        }
    }
    
    private func loadBreakHistory() {
        guard let data = UserDefaults.standard.data(forKey: breakHistoryKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([Break].self, from: data)
            breakHistory = decoded
        } catch {
            print("Failed to load break history: \(error.localizedDescription)")
        }
    }
    
    private func loadUserSettings() {
        breakNotificationsEnabled = UserDefaults.standard.bool(forKey: "breakNotificationsEnabled")
        stressNotificationsEnabled = UserDefaults.standard.bool(forKey: "stressNotificationsEnabled")
        inactivityNotificationsEnabled = UserDefaults.standard.bool(forKey: "inactivityNotificationsEnabled")
        
        if let data = UserDefaults.standard.data(forKey: "preferredBreakTypes") {
            do {
                let decoded = try JSONDecoder().decode([BreakType].self, from: data)
                preferredBreakTypes = decoded
            } catch {
                print("Failed to load preferred break types: \(error.localizedDescription)")
                preferredBreakTypes = BreakType.allCases
            }
        }
    }
    
    private func saveHistoricalData(_ data: [HistoricalWellnessData]) {
        do {
            let encoded = try JSONEncoder().encode(data)
            UserDefaults.standard.set(encoded, forKey: historicalDataKey)
        } catch {
            print("Failed to save historical wellness data: \(error.localizedDescription)")
        }
    }
    
    private func saveBreakHistory(_ breaks: [Break]) {
        do {
            let encoded = try JSONEncoder().encode(breaks)
            UserDefaults.standard.set(encoded, forKey: breakHistoryKey)
        } catch {
            print("Failed to save break history: \(error.localizedDescription)")
        }
    }
    
    func saveUserSettings() {
        UserDefaults.standard.set(breakNotificationsEnabled, forKey: "breakNotificationsEnabled")
        UserDefaults.standard.set(stressNotificationsEnabled, forKey: "stressNotificationsEnabled")
        UserDefaults.standard.set(inactivityNotificationsEnabled, forKey: "inactivityNotificationsEnabled")
        
        do {
            let encoded = try JSONEncoder().encode(preferredBreakTypes)
            UserDefaults.standard.set(encoded, forKey: "preferredBreakTypes")
        } catch {
            print("Failed to save preferred break types: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Break Recommendation
    
    func recommendBreak(based on: WellnessData) -> BreakType {
        // Simple recommendation logic based on wellness data
        if on.stressLevel == .high {
            return preferredBreakTypes.contains(.mindfulness) ? .mindfulness : .stretch
        }
        
        if on.stepCount < 2000 && Calendar.current.component(.hour, from: Date()) > 12 {
            return preferredBreakTypes.contains(.walk) ? .walk : .stretch
        }
        
        if on.codeSessionDuration > 5400 { // 90 minutes
            return preferredBreakTypes.contains(.music) ? .music : .water
        }
        
        // Default recommendation - rotate through preferred types
        let currentHour = Calendar.current.component(.hour, from: Date())
        let index = currentHour % preferredBreakTypes.count
        return preferredBreakTypes[index]
    }
} 