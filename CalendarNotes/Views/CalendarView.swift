import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    let notes: [Note]
    var refreshID: UUID? // This property forces the view to update
    @State private var currentMonth: Date = Date()
    
    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            // Month/Year Header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Day Headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if date.month != currentMonth.month {
                        Text("")
                            .frame(width: 30, height: 30)
                    } else {
                        Button(action: { selectedDate = date }) {
                            VStack(spacing: 2) {
                                Text("\(date.day)")
                                    .frame(width: 30, height: 30)
                                    .background(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.7) : Color.clear)
                                    .clipShape(Circle())
                                    .foregroundColor(dateForegroundColor(for: date))

                                if hasNote(for: date) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    private func dateForegroundColor(for date: Date) -> Color {
        if Calendar.current.isDate(date, inSameDayAs: selectedDate) {
            return .white
                } else if Calendar.current.isDateInToday(date) {
            return .red
        } else {
            return .primary
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date] {
        var dates = [Date]()
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        
        let firstDay = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDay)
        
        // Add padding for days before the first day of the month
        if weekday > 1 {
            for i in (1..<weekday).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: firstDay) {
                    dates.append(date)
                }
            }
        }
        
        // Add days in the month
        for dayOffset in 0..<(calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0) {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDay) {
                dates.append(date)
            }
        }
        
        // Add padding for days after the last day of the month to fill the grid
        let requiredCells = 42 // 6 weeks * 7 days
        let remainingCells = requiredCells - dates.count
        
        if let lastDay = dates.last, remainingCells > 0 {
            for i in 1...remainingCells {
                if let date = calendar.date(byAdding: .day, value: i, to: lastDay) {
                    dates.append(date)
                }
            }
        }
        
        return dates
    }
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
    }

    private func hasNote(for date: Date) -> Bool {
        notes.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
}
