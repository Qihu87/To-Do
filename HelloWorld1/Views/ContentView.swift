import SwiftUI
import SwiftData

/// 主内容视图
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // 获取所有任务并按日期排序
    @Query(sort: \Task.date) private var tasks: [Task]
    @State private var showingAddTask = false
    @State private var selectedDate = Date()
    @State private var dragOffset: CGFloat = 0
    @State private var showingDatePicker = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 日历头部视图
                CalendarHeaderView(selectedDate: $selectedDate, tasks: tasks)
                    // 顶部内边距：16px
                    .padding(.top)
                
                // 当日任务视图
                DayTasksView(tasks: tasks, selectedDate: selectedDate)
                    // 顶部内边距：16px
                    .padding(.top)
            }
            .contentShape(Rectangle())  // 确保整个区域可以响应手势
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if value.translation.width > threshold {
                                // 向右滑动，显示前一天
                                if let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
                                    selectedDate = newDate
                                }
                            } else if value.translation.width < -threshold {
                                // 向左滑动，显示后一天
                                if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
                                    selectedDate = newDate
                                }
                            }
                        }
                        dragOffset = 0
                    }
            )
            .offset(x: dragOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // 显示当前月份，点击显示日期选择器
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        Text(currentMonth)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                    }
                }
                
                // 如果不是今天，显示"今天"按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !calendar.isDateInToday(selectedDate) {
                        Button(action: {
                            withAnimation {
                                selectedDate = Date()
                            }
                        }) {
                            Text("今")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                // 添加任务按钮
                AddButton(showingAddTask: $showingAddTask)
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(selectedDate: selectedDate)
                    .interactiveDismissDisabled()
                    .presentationBackground(Color(hex: "F6F5FA"))
                    .presentationCornerRadius(24)
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $selectedDate, isPresented: $showingDatePicker)
            }
        }
    }
    
    /// 获取当前月份的本地化字符串
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy'年'M'月'"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedDate)
    }
    
    /// 获取选中日期的所有任务
    private var selectedDateTasks: [Task] {
        tasks.filter { task in
            task.shouldShow(on: selectedDate)
        }
        .sorted { $0.time < $1.time }  // 按时间排序
    }
}

/// 添加按钮视图
struct AddButton: View {
    @Binding var showingAddTask: Bool
    
    var body: some View {
        Button(action: {
            showingAddTask = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .shadow(radius: 3)
                .padding()
        }
        .padding()
    }
} 