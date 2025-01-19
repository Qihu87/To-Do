import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @State private var pickerDate: Date
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        self._pickerDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 日期选择器
            DatePicker("选择日期", selection: $pickerDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(UIColor.systemBackground))
            
            // 底部按钮
            Button(action: {
                selectedDate = pickerDate
                isPresented = false
            }) {
                Text("跳转到日期")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
        .presentationDetents([.height(500)])
        .presentationBackground(Color(UIColor.systemBackground))
        .presentationCornerRadius(12)
    }
} 