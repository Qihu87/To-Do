//
//  HelloWorld1App.swift
//  HelloWorld1
//
//  Created by QIHU'W on 2024/12/24.
//

import SwiftUI
import SwiftData

@main
struct HelloWorld1App: App {
    let container: ModelContainer
    
    init() {
        do {
            // 创建模型配置
            let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
            
            // 尝试初始化容器
            container = try ModelContainer(
                for: Task.self, SubTask.self,
                configurations: modelConfiguration
            )
            
            print("成功初始化数据容器")
        } catch let error as NSError {
            print("初始化数据容器失败: \(error.localizedDescription)")
            print("错误代码: \(error.code)")
            print("错误域: \(error.domain)")
            print("详细信息: \(error.userInfo)")
            
            // 如果初始化失败，使用内存存储作为备选方案
            do {
                let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                container = try ModelContainer(
                    for: Task.self, SubTask.self,
                    configurations: fallbackConfig
                )
                print("已切换到内存存储模式")
            } catch {
                fatalError("数据容器完全无法初始化，应用无法继续运行: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
