import SwiftUI

struct TimePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("时间点")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "999999"))
                    Spacer()
                    Text("时间段")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "999999"))
                }
                .padding(.horizontal, 16)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("开始时间")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "999999"))
                        DatePicker(
                            "",
                            selection: $startTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("结束时间")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "999999"))
                        DatePicker(
                            "",
                            selection: $endTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("选择时间")
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