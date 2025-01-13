import SwiftUI

/// 日任务视图 - 显示每日任务时间线
struct DayTasksView: View {
    let tasks: [Task]
    // 显示时间范围：早8点到晚10点
    private let hourRange = 8...22
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 只显示有任务的时间段
                ForEach(hourRange, id: \.self) { hour in
                    if !tasksForHour(hour).isEmpty {
                        HourRowView(hour: hour, tasks: tasksForHour(hour))
                    }
                }
            }
            // 水平内边距：16px
            .padding(.horizontal)
        }
    }
    
    /// 获取指定小时的所有任务
    private func tasksForHour(_ hour: Int) -> [Task] {
        tasks.filter { task in
            let taskHour = Calendar.current.component(.hour, from: task.time)
            return taskHour == hour
        }
    }
}

/// 小时行视图 - 显示某个小时的所有任务
struct HourRowView: View {
    let hour: Int
    let tasks: [Task]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 左侧时间标签
            Text(timeString)
                // 字体大小：14px
                .font(.system(size: 14))
                .foregroundColor(.gray)
                // 时间标签宽度：50px
                .frame(width: 50)
            
            // 时间线和任务列表
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var timeString: String {
        String(format: "%02d:00", hour)
    }
}

/// 任务行视图 - 显示单个任务
struct TaskRowView: View {
    let task: Task
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 12) {
            // 任务图标
            Image(systemName: task.icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.fromHex(task.iconColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                // 任务标题
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .strikethrough(task.isCompleted)
                
                // 任务时间和持续时间
                HStack(spacing: 8) {
                    Text(timeString)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if task.duration > 0 {
                        Text("·")
                            .foregroundColor(.gray)
                        Text("\(task.duration)分钟")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // 完成按钮
            Button(action: {
                withAnimation {
                    task.isCompleted.toggle()
                    try? modelContext.save()
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: task.time)
    }
}

/// 时间线视图 - 显示任务状态和连接线
struct TimelineView: View {
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 状态圆圈
            Circle()
                // 已完成显示蓝色(#007AFF)，未完成显示粉色(#FF2D55)
                .fill(isCompleted ? Color(hex: 0x007AFF) : Color(hex: 0xFF2D55))
                // 圆圈尺寸：24px x 24px
                .frame(width: 24, height: 24)
                .overlay(
                    // 圆圈中的图标
                    Image(systemName: isCompleted ? "checkmark" : "alarm")
                        // 图标大小：12px
                        .font(.system(size: 12))
                        // 白色：#FFFFFF
                        .foregroundColor(Color(hex: 0xFFFFFF))
                )
            
            // 连接线
            Rectangle()
                // 蓝色透明：#007AFF，透明度20%
                .fill(Color(hex: 0x007AFF, alpha: 0.2))
                // 线宽：2px
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
    }
}

/// 任务卡片视图 - 显示任务详情
struct TaskCardView: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 任务标题
            Text(task.title)
                // 字体大小：16px
                .font(.system(size: 16))
                // 已完成显示灰色(#8E8E93)，未完成显示黑色(#000000)
                .foregroundColor(task.isCompleted ? Color(hex: 0x8E8E93) : Color(hex: 0x000000))
                // 已完成显示删除线
                .strikethrough(task.isCompleted)
            
            // 子任务信息
            if !task.subTasks.isEmpty {
                Text("剩余时间：33分钟")
                    // 字体大小：12px
                    .font(.system(size: 12))
                    // 灰色：#8E8E93
                    .foregroundColor(Color(hex: 0x8E8E93))
            }
        }
        // 垂直内边距：8px
        .padding(.vertical, 8)
    }
}

/// 完成按钮视图 - 用于标记任务完成状态
struct CompleteButton: View {
    let task: Task
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button(action: {
            // 切换任务完成状态
            task.isCompleted.toggle()
            try? modelContext.save()
        }) {
            Circle()
                // 边框：1.5px，已完成蓝色(#007AFF)，未完成灰色(#8E8E93)
                .strokeBorder(task.isCompleted ? Color(hex: 0x007AFF) : Color(hex: 0x8E8E93), lineWidth: 1.5)
                .background(
                    Circle()
                        // 已完成蓝色(#007AFF)，未完成透明
                        .fill(task.isCompleted ? Color(hex: 0x007AFF) : Color.clear)
                )
                // 按钮尺寸：22px x 22px
                .frame(width: 22, height: 22)
                .overlay(
                    // 勾选图标
                    Image(systemName: "checkmark")
                        // 图标大小：30px
                        .font(.system(size: 30, weight: .bold))
                        // 白色：#FFFFFF
                        .foregroundColor(Color(hex: 0xFFFFFF))
                        // 未完成时隐藏勾选图标
                        .opacity(task.isCompleted ? 1 : 0)
                )
        }
    }
} 
