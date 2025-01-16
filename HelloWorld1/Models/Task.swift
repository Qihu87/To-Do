import Foundation
import SwiftData

/// 任务数据模型
@Model
final class Task {
    /// 重复类型枚举
    enum RepeatType: String, Codable, CaseIterable {
        case once = "仅一次"
        case daily = "每日"
        case weekly = "每周"
        case monthly = "每月"
        case custom = "自定义"
    }
    
    /// 任务唯一标识符
    var id: UUID
    /// 任务标题
    var title: String
    /// 任务日期
    var date: Date
    /// 任务时间
    var time: Date
    /// 任务图标
    var icon: String
    /// 图标颜色（十六进制）
    var iconColor: String
    /// 持续时间（分钟）
    var duration: Int
    /// 子任务列表
    @Relationship(deleteRule: .cascade) var subTasks: [SubTask]
    /// 是否需要提醒
    var hasReminder: Bool
    /// 提醒时间
    var reminderTime: Date?
    /// 是否已完成
    var isCompleted: Bool
    /// 重复类型
    var repeatType: RepeatType
    /// 创建日期（用于计算重复）
    var createdDate: Date

    /// 初始化任务
    /// - Parameters:
    ///   - title: 任务标题
    ///   - date: 任务日期
    ///   - time: 任务时间
    ///   - icon: 任务图标
    ///   - iconColor: 图标颜色（十六进制）
    ///   - duration: 持续时间（分钟）
    ///   - hasReminder: 是否需要提醒
    ///   - reminderTime: 提醒时间
    ///   - repeatType: 重复类型
    init(title: String, 
         date: Date, 
         time: Date, 
         icon: String = "calendar",
         iconColor: String = "007AFF",
         duration: Int = 15,
         hasReminder: Bool = false, 
         reminderTime: Date? = nil,
         repeatType: RepeatType = .once) {
        self.id = UUID()
        self.title = title
        self.date = Calendar.current.startOfDay(for: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        self.time = Calendar.current.date(from: dateComponents) ?? time
        self.icon = icon
        self.iconColor = iconColor
        self.duration = duration
        self.subTasks = []
        self.hasReminder = hasReminder
        self.reminderTime = reminderTime
        self.isCompleted = false
        self.repeatType = repeatType
        self.createdDate = date
    }
    
    /// 判断任务是否应该在指定日期显示
    /// - Parameter date: 指定日期
    /// - Returns: 是否显示
    func shouldShow(on date: Date) -> Bool {
        let calendar = Calendar.current
        
        // 获取任务日期和目标日期的年份
        let taskYear = calendar.component(.year, from: self.date)
        let targetYear = calendar.component(.year, from: date)
        
        // 如果目标日期不在任务年份内，返回false
        if targetYear != taskYear {
            return false
        }
        
        // 如果目标日期早于任务开始日期，返回false
        if date < calendar.startOfDay(for: self.date) {
            return false
        }
        
        switch repeatType {
        case .once:
            // 仅在任务设定日期当天显示
            return calendar.isDate(self.date, inSameDayAs: date)
            
        case .daily:
            // 从任务日期开始的每一天都显示
            return true
            
        case .weekly:
            // 从任务日期开始的每周相同星期几都显示
            let taskWeekday = calendar.component(.weekday, from: self.date)
            let targetWeekday = calendar.component(.weekday, from: date)
            return taskWeekday == targetWeekday
            
        case .monthly:
            // 从任务日期开始的每月相同日期都显示
            let taskDay = calendar.component(.day, from: self.date)
            let targetDay = calendar.component(.day, from: date)
            return taskDay == targetDay
            
        case .custom:
            return calendar.isDate(self.date, inSameDayAs: date)
        }
    }
} 