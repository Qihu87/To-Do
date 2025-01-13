# Daily Planner App

这是一个日程管理APP，用于管理每日任务和计划。

## 功能特性
- 添加和管理每日任务
- 支持子任务创建
- 任务提醒功能
- 按时间线展示每日任务
- 月份和周历展示

## 技术架构
- SwiftUI框架
- Combine用于数据流管理
- UserNotifications用于提醒功能
- SwiftData用于数据持久化

## 文件结构
- Models/
  - Task.swift (任务数据模型)
  - SubTask.swift (子任务数据模型)
- Views/
  - ContentView.swift (主页面)
  - AddTaskView.swift (添加任务页面)
  - CalendarHeaderView.swift (日历头部视图)
  - DayTasksView.swift (日任务视图)
- Managers/
  - TaskManager.swift (任务管理器)
  - NotificationManager.swift (通知管理器) 