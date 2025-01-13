import SwiftUI

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    let tasks: [Task]
    @State private var dragOffset: CGFloat = 0
    @State private var currentWeekOffset: Int = 0
    private let calendar = Calendar.current
    private let weekDays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 20) {
            // 周视图
            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    VStack {
                        Text(weekDays[index])
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            if let date = getDate(for: index) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedDate = date
                                }
                            }
                        }) {
                            Text("\(getDayNumber(for: index))")
                                .font(.system(size: 20))
                                .fontWeight(isSelected(index) ? .bold : .regular)
                                .foregroundColor(isSelected(index) ? .blue : .primary)
                                .frame(width: screenWidth/7 * 0.8, height: 35)
                                .background(
                                    Circle()
                                        .fill(isSelected(index) ? Color.blue.opacity(0.2) : Color.clear)
                                )
                        }
                    }
                    .frame(width: screenWidth/7)
                }
            }
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let predictedEndOffset = value.predictedEndTranslation.width
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if abs(predictedEndOffset) > screenWidth/4 {
                                if predictedEndOffset > 0 {
                                    // 向右滑动，显示上一周
                                    if let newDate = calendar.date(byAdding: .day, value: -7, to: selectedDate) {
                                        selectedDate = newDate
                                    }
                                } else {
                                    // 向左滑动，显示下一周
                                    if let newDate = calendar.date(byAdding: .day, value: 7, to: selectedDate) {
                                        selectedDate = newDate
                                    }
                                }
                            }
                            dragOffset = 0
                        }
                    }
            )
            .frame(height: 80)
        }
    }
    
    private func getDayNumber(for index: Int) -> Int {
        let today = calendar.startOfDay(for: selectedDate)
        let weekday = calendar.component(.weekday, from: today)
        let difference = index - (weekday - 1)
        
        if let date = calendar.date(byAdding: .day, value: difference, to: today) {
            return calendar.component(.day, from: date)
        }
        return 0
    }
    
    private func getDate(for index: Int) -> Date? {
        let today = calendar.startOfDay(for: selectedDate)
        let weekday = calendar.component(.weekday, from: today)
        let difference = index - (weekday - 1)
        return calendar.date(byAdding: .day, value: difference, to: today)
    }
    
    private func isSelected(_ index: Int) -> Bool {
        if let date = getDate(for: index) {
            return calendar.isDate(date, inSameDayAs: selectedDate)
        }
        return false
    }
} 