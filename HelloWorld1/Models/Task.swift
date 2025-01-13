import Foundation
import SwiftData

/// 任务数据模型
@Model
final class Task {
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
    init(title: String, 
         date: Date, 
         time: Date, 
         icon: String = "calendar",
         iconColor: String = "007AFF",
         duration: Int = 15,
         hasReminder: Bool = false, 
         reminderTime: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.time = time
        self.icon = icon
        self.iconColor = iconColor
        self.duration = duration
        self.subTasks = []
        self.hasReminder = hasReminder
        self.reminderTime = reminderTime
        self.isCompleted = false
    }
} 