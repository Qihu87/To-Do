import SwiftUI
import SwiftData

// 自定义底部弹窗样式
struct CustomSheetStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .presentationBackground {
                Color(hex: "F6F5FA")
                    .ignoresSafeArea()
            }
            .interactiveDismissDisabled()  // 防止意外下滑关闭
    }
}

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    
    @State private var taskTitle = ""
    @State private var taskDate: Date
    @State private var taskTime = Date()
    @State private var endTime = Date()
    @State private var showAlert = false
    @State private var selectedIcon = "bed.double.fill"
    @State private var selectedColor = Color(hex: "F4A7B9")
    @State private var showingIconPicker = false
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var repeatOption = Task.RepeatType.once
    @State private var showRepeatOptions = false
    @State private var reminderTime = "开始前5分钟提醒我"
    @State private var showReminderOptions = false
    @FocusState private var isTitleFocused: Bool
    
    private let repeatOptions = Task.RepeatType.allCases
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        
        // 使用当前时间作为默认时间
        let now = Date()
        let calendar = Calendar.current
        
        // 将选择的日期和当前时间组合
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: now)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        let combinedDate = calendar.date(from: components) ?? now
        
        _taskDate = State(initialValue: selectedDate)
        _taskTime = State(initialValue: combinedDate)
        _endTime = State(initialValue: Calendar.current.date(byAdding: .minute, value: 15, to: combinedDate) ?? combinedDate)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F6F5FA")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 任务名称输入
                        HStack(spacing: 12) {
                            Button(action: { showingIconPicker = true }) {
                                Image(systemName: selectedIcon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(selectedColor)
                                    .clipShape(Circle())
                            }
                            
                            TextField("任务名称", text: $taskTitle)
                                .focused($isTitleFocused)
                                .font(.system(size: 17))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        // 时间设置部分
                        VStack(spacing: 0) {
                            // 日期选择标题
                            Text("什么时候?")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "999999"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                // 日期选择按钮
                                Button(action: { showDatePicker.toggle() }) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.black)
                                            .frame(width: 24, height: 24)
                                        Text(dateFormatter.string(from: taskDate))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(hex: "999999"))
                                            .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                
                                if showDatePicker {
                                    VStack(spacing: 16) {
                                        HStack {
                                            Text("日期")
                                                .font(.system(size: 15))
                                                .foregroundColor(Color(hex: "999999"))
                                            Spacer()
                                            Text("时间段")
                                                .font(.system(size: 15))
                                                .foregroundColor(Color(hex: "999999"))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.top, 12)
                                        
                                        DatePicker(
                                            "",
                                            selection: $taskDate,
                                            displayedComponents: .date
                                        )
                                        .datePickerStyle(.graphical)
                                        .padding(.horizontal, 16)
                                        
                                        Button("确定") {
                                            showDatePicker = false
                                        }
                                        .frame(width: 343, height: 44)
                                        .background(selectedColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(22)
                                        .padding(.bottom, 16)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // 具体时间部分
                        VStack(spacing: 0) {
                            Text("具体时间?")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "999999"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                Button(action: { showTimePicker.toggle() }) {
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.black)
                                            .frame(width: 24, height: 24)
                                        Text(timeFormatter.string(from: taskTime))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color(hex: "999999"))
                                            .rotationEffect(.degrees(showTimePicker ? 90 : 0))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                
                                if showTimePicker {
                                    VStack(spacing: 16) {
                                        HStack(spacing: 0) {
                                            Picker("小时", selection: Binding(
                                                get: { Calendar.current.component(.hour, from: taskTime) },
                                                set: { newHour in
                                                    var components = Calendar.current.dateComponents([.year, .month, .day, .minute], from: taskTime)
                                                    components.hour = newHour
                                                    if let newDate = Calendar.current.date(from: components) {
                                                        taskTime = newDate
                                                    }
                                                }
                                            )) {
                                                ForEach(0..<24) { hour in
                                                    Text("\(hour)")
                                                        .tag(hour)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 100)
                                            
                                            Text("时")
                                                .font(.system(size: 17))
                                                .foregroundColor(.black)
                                                .padding(.trailing, 30)
                                            
                                            Picker("分钟", selection: Binding(
                                                get: { Calendar.current.component(.minute, from: taskTime) },
                                                set: { newMinute in
                                                    var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: taskTime)
                                                    components.minute = newMinute
                                                    if let newDate = Calendar.current.date(from: components) {
                                                        taskTime = newDate
                                                    }
                                                }
                                            )) {
                                                ForEach(0..<60) { minute in
                                                    Text("\(minute)")
                                                        .tag(minute)
                                                }
                                            }
                                            .pickerStyle(.wheel)
                                            .frame(width: 100)
                                            
                                            Text("分")
                                                .font(.system(size: 17))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 16)
                                        
                                        Button("确定") {
                                            showTimePicker = false
                                        }
                                        .frame(width: 343, height: 44)
                                        .background(selectedColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(22)
                                        .padding(.bottom, 16)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // 重复选项部分
                        VStack(spacing: 0) {
                            Text("多久一次?")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "999999"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(Task.RepeatType.allCases, id: \.self) { option in
                                        Button(action: {
                                            repeatOption = option
                                        }) {
                                            Text(option.rawValue)
                                                .font(.system(size: 15))
                                                .foregroundColor(repeatOption == option ? .white : .primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    repeatOption == option ?
                                                    selectedColor :
                                                    Color(hex: "F5F5F5")
                                                )
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // 提醒选项部分
                        VStack(spacing: 0) {
                            Text("需要提醒吗?")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "999999"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                            
                            Button(action: { showReminderOptions.toggle() }) {
                                HStack {
                                    Image(systemName: "bell")
                                        .foregroundColor(.black)
                                        .frame(width: 24, height: 24)
                                    Text(reminderTime)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(hex: "999999"))
                                        .rotationEffect(.degrees(showReminderOptions ? 90 : 0))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                        }
                        
                        // 底部占位空间
                        Spacer()
                            .frame(height: 80) // 为底部按钮预留空间
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                }
                .overlay(alignment: .bottom) {
                    // 底部创建按钮
                    VStack(spacing: 0) {
                        Divider()
                        Button(action: {
                            saveTask()
                        }) {
                            Text("创建任务")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 343, height: 54)
                                .background(taskTitle.isEmpty ? Color(hex: "CCCCCC") : selectedColor)
                                .cornerRadius(27)
                        }
                        .disabled(taskTitle.isEmpty)
                        .padding(.vertical, 16)
                    }
                    .background(Color(hex: "F6F5FA"))
                }
            }
            .navigationTitle("创建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("请输入任务名称", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedColor: $selectedColor)
                    .modifier(CustomSheetStyle())
            }
        }
        .background(Color(hex: "F6F5FA"))
        .presentationBackground(Color(hex: "F6F5FA"))
    }
    
    private func saveTask() {
        guard !taskTitle.isEmpty else {
            showAlert = true
            return
        }
        
        let task = Task(
            title: taskTitle,
            date: taskDate,
            time: taskTime,
            icon: selectedIcon,
            iconColor: selectedColor.toHex() ?? "F4A7B9",
            duration: Calendar.current.dateComponents([.minute], from: taskTime, to: endTime).minute ?? 15,
            hasReminder: false,
            reminderTime: nil,
            repeatType: repeatOption
        )
        
        modelContext.insert(task)
        dismiss()
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

// 添加Color扩展，支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 