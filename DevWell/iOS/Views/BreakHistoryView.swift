import SwiftUI

struct BreakHistoryView: View {
    @EnvironmentObject var userData: UserData
    
    @State private var selectedDate: Date = Date()
    @State private var viewMode: ViewMode = .list
    @State private var animateCalendar = false
    @State private var showFilterSheet = false
    @State private var selectedFilter: BreakType? = nil
    
    private let calendar = Calendar(identifier: .gregorian)
    
    enum ViewMode: String, CaseIterable, Identifiable {
        case list = "List"
        case calendar = "Calendar"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("View", selection: $viewMode) {
                    ForEach(ViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                if viewMode == .calendar {
                    calendarView
                } else {
                    listView
                }
            }
            .navigationTitle("Break History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilterSheet = true
                    }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                filterView
            }
        }
    }
    
    // MARK: - Calendar View
    
    private var calendarView: some View {
        VStack(spacing: 0) {
            CalendarView(
                selectedDate: $selectedDate,
                calendar: calendar,
                breaks: userData.breaks
            )
            .padding(.horizontal)
            
            // Break list for selected date
            let selectedDateBreaks = filteredBreaks.filter { 
                calendar.isDate($0.startTime, inSameDayAs: selectedDate)
            }
            
            if selectedDateBreaks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    
                    Text("No breaks on \(dateFormatter.string(from: selectedDate))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Take a break to see it here!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(selectedDateBreaks) { breakItem in
                        BreakHistoryCard(breakItem: breakItem)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        Group {
            if filteredBreaks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No break history found")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Take breaks throughout your day to build a history")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(groupedBreaks, id: \.0) { date, breaks in
                        Section(header: Text(relativeDateFormatter(date: date))) {
                            ForEach(breaks) { breakItem in
                                BreakHistoryRow(breakItem: breakItem)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    // MARK: - Filter View
    
    private var filterView: some View {
        NavigationView {
            List {
                Section(header: Text("Filter by break type")) {
                    Button(action: {
                        selectedFilter = nil
                        showFilterSheet = false
                    }) {
                        HStack {
                            Text("All breaks")
                            Spacer()
                            if selectedFilter == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    ForEach(BreakType.allCases, id: \.self) { breakType in
                        Button(action: {
                            selectedFilter = breakType
                            showFilterSheet = false
                        }) {
                            HStack {
                                Image(systemName: breakType.icon)
                                    .foregroundColor(Color(breakType.color))
                                    .frame(width: 30, height: 30)
                                    .background(
                                        Circle()
                                            .fill(Color(breakType.color).opacity(0.2))
                                    )
                                
                                Text(breakType.rawValue.capitalized)
                                
                                Spacer()
                                
                                if selectedFilter == breakType {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Filter Breaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showFilterSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var filteredBreaks: [Break] {
        let completedBreaks = userData.breaks.filter { $0.isCompleted }
        
        if let filter = selectedFilter {
            return completedBreaks.filter { $0.type == filter }
        } else {
            return completedBreaks
        }
    }
    
    private var groupedBreaks: [(Date, [Break])] {
        let grouped = Dictionary(grouping: filteredBreaks) { breakItem in
            calendar.startOfDay(for: breakItem.startTime)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private func relativeDateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Components

struct CalendarView: View {
    @Binding var selectedDate: Date
    let calendar: Calendar
    let breaks: [Break]
    
    @State private var currentMonth: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 8)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                
                let daysInMonth = daysInCurrentMonth()
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasBreaks: hasBreaksOnDate(date),
                            onTap: {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                        )
                    } else {
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.bottom)
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var weekdaySymbols: [String] {
        return calendar.shortWeekdaySymbols.map { String($0.prefix(1)) }
    }
    
    private func hasBreaksOnDate(_ date: Date) -> Bool {
        return breaks.contains { calendar.isDate($0.startTime, inSameDayAs: date) && $0.isCompleted }
    }
    
    private func daysInCurrentMonth() -> [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)!.start
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        // Adjust weekday to match calendar's first weekday
        let adjustedFirstWeekday = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count
        
        var days = [Date?](repeating: nil, count: adjustedFirstWeekday)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Fill the rest of the grid if needed
        let totalCells = 42 // 6 rows of 7 days
        if days.count < totalCells {
            days.append(contentsOf: [Date?](repeating: nil, count: totalCells - days.count))
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
}

struct CalendarCell: View {
    let date: Date
    let isSelected: Bool
    let hasBreaks: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 36, height: 36)
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if hasBreaks {
                    Circle()
                        .fill(isSelected ? Color.white : Color.accentColor)
                        .frame(width: 5, height: 5)
                        .offset(y: 12)
                }
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Break Card Components

struct BreakHistoryCard: View {
    let breakItem: Break
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: breakItem.type.icon)
                    .font(.title2)
                    .foregroundColor(Color(breakItem.type.color))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(breakItem.type.color).opacity(0.2))
                    )
                
                VStack(alignment: .leading) {
                    Text(breakItem.type.rawValue.capitalized)
                        .font(.headline)
                    
                    Text("\(formatTime(breakItem.startTime)) • \(Int(breakItem.duration / 60)) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let mood = breakItem.mood {
                    Text(mood.emoji)
                        .font(.title)
                }
            }
            
            if let notes = breakItem.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct BreakHistoryRow: View {
    let breakItem: Break
    
    var body: some View {
        HStack {
            Image(systemName: breakItem.type.icon)
                .font(.headline)
                .foregroundColor(Color(breakItem.type.color))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(breakItem.type.color).opacity(0.2))
                )
            
            VStack(alignment: .leading) {
                Text(breakItem.type.rawValue.capitalized)
                    .font(.headline)
                
                Text("\(formatTime(breakItem.startTime)) • \(Int(breakItem.duration / 60)) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let mood = breakItem.mood {
                Text(mood.emoji)
                    .font(.title3)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Previews
struct BreakHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        BreakHistoryView()
            .environmentObject(UserData())
    }
} 