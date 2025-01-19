import SwiftUI

struct TimePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Binding var selectedMode: Bool
    @Binding var isPresented: Bool
    
    init(startTime: Binding<Date>, endTime: Binding<Date>, selectedMode: Binding<Bool>, isPresented: Binding<Bool>) {
        self._startTime = startTime
        self._endTime = endTime
        self._selectedMode = selectedMode
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 时间点/时间段切换
                Picker("选择模式", selection: $selectedMode) {
                    Text("时间点").tag(false)
                    Text("时间段").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)
                
                if selectedMode {
                    // 时间段选择
                    VStack(spacing: 20) {
                        Text("开始时间")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // 开始时间选择器
                        HStack {
                            Picker("小时", selection: Binding(
                                get: { Calendar.current.component(.hour, from: startTime) },
                                set: { newHour in
                                    var components = Calendar.current.dateComponents([.year, .month, .day, .minute], from: startTime)
                                    components.hour = newHour
                                    if let newDate = Calendar.current.date(from: components) {
                                        startTime = newDate
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
                                .foregroundColor(.black)
                            
                            Picker("分钟", selection: Binding(
                                get: { Calendar.current.component(.minute, from: startTime) },
                                set: { newMinute in
                                    var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: startTime)
                                    components.minute = newMinute
                                    if let newDate = Calendar.current.date(from: components) {
                                        startTime = newDate
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
                                .foregroundColor(.black)
                        }
                        
                        Text("结束时间")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // 结束时间选择器
                        HStack {
                            Picker("小时", selection: Binding(
                                get: { Calendar.current.component(.hour, from: endTime) },
                                set: { newHour in
                                    var components = Calendar.current.dateComponents([.year, .month, .day, .minute], from: endTime)
                                    components.hour = newHour
                                    if let newDate = Calendar.current.date(from: components) {
                                        endTime = newDate
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
                                .foregroundColor(.black)
                            
                            Picker("分钟", selection: Binding(
                                get: { Calendar.current.component(.minute, from: endTime) },
                                set: { newMinute in
                                    var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: endTime)
                                    components.minute = newMinute
                                    if let newDate = Calendar.current.date(from: components) {
                                        endTime = newDate
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
                                .foregroundColor(.black)
                        }
                    }
                } else {
                    // 时间点选择
                    HStack {
                        Picker("小时", selection: Binding(
                            get: { Calendar.current.component(.hour, from: startTime) },
                            set: { newHour in
                                var components = Calendar.current.dateComponents([.year, .month, .day, .minute], from: startTime)
                                components.hour = newHour
                                if let newDate = Calendar.current.date(from: components) {
                                    startTime = newDate
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
                            .foregroundColor(.black)
                        
                        Picker("分钟", selection: Binding(
                            get: { Calendar.current.component(.minute, from: startTime) },
                            set: { newMinute in
                                var components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: startTime)
                                components.minute = newMinute
                                if let newDate = Calendar.current.date(from: components) {
                                    startTime = newDate
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
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                // 确定按钮
                Button(action: {
                    isPresented = false
                }) {
                    Text("确定")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("选择时间")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
    }
} 