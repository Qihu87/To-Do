import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    
    @State private var taskTitle = ""
    @State private var taskDate: Date
    @State private var taskTime = Date()
    @State private var showAlert = false
    @State private var selectedIcon = "calendar"
    @State private var selectedColor = Color.blue
    @State private var showingIconPicker = false
    @State private var duration: Double = 1 // 默认15分钟，1个单位
    @State private var showDatePicker = false
    @FocusState private var isTitleFocused: Bool
    
    private let icons = ["calendar", "book.fill", "pencil", "doc.fill", "folder.fill", "star.fill", "heart.fill", "bell.fill", "flag.fill", "tag.fill"]
    private let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow, .gray]
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _taskDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Button(action: { showingIconPicker = true }) {
                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(selectedColor)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        TextField("任务名称", text: $taskTitle)
                            .focused($isTitleFocused)
                    }
                }
                
                Section {
                    // 日期选择
                    Button(action: {
                        showDatePicker = true
                    }) {
                        HStack {
                            Text("日期")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(dateFormatter.string(from: taskDate))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // 时间选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("时间")
                            .foregroundColor(.gray)
                        DatePicker("", selection: $taskTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    
                    // 持续时间
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("持续时间")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(duration * 15))分钟")
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: $duration, in: 1...12, step: 1)
                            .accentColor(.blue)
                    }
                }
            }
            .navigationTitle("添加任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        addTask()
                    }
                }
            }
            .alert("请输入任务名称", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: $taskDate)
                    .presentationDetents([.height(420)])
            }
            .onAppear {
                // 自动调起键盘
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTitleFocused = true
                }
            }
        }
    }
    
    private func addTask() {
        guard !taskTitle.isEmpty else {
            showAlert = true
            return
        }
        
        // 合并选择的日期和时间
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: taskDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: taskTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        if let combinedDate = calendar.date(from: combinedComponents) {
            let hexColor = selectedColor.toHex() ?? "007AFF"
            let task = Task(title: taskTitle, 
                          date: combinedDate, 
                          time: taskTime,
                          icon: selectedIcon,
                          iconColor: hexColor,
                          duration: Int(duration * 15))
            modelContext.insert(task)
            dismiss()
        }
    }
}

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
            }
            .navigationTitle("选择日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    @Binding var selectedColor: Color
    
    private let icons = ["calendar", "book.fill", "pencil", "doc.fill", "folder.fill", "star.fill", "heart.fill", "bell.fill", "flag.fill", "tag.fill"]
    private let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink, .yellow, .gray]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // 图标选择
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(icon == selectedIcon ? .white : selectedColor)
                                    .frame(width: 44, height: 44)
                                    .background(icon == selectedIcon ? selectedColor : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedColor, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding()
                        
                        // 颜色选择
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: color == selectedColor ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("选择图标")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
} 