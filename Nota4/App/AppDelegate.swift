import AppKit
import ComposableArchitecture

class AppDelegate: NSObject, NSApplicationDelegate {
    var store: StoreOf<AppFeature>?
    
    func applicationWillTerminate(_ notification: Notification) {
        // Debug: App terminating
        // Debug: App terminating
        // Debug: App terminating
        
        // 应用退出前同步保存
        guard let store = store else { 
            // Debug: App terminating
            return 
        }
        
        // Debug: App terminating
        
        // 使用同步方式保存
        let task = Task {
            await store.send(.editor(.manualSave)).finish()
        }
        
        // 等待保存完成（最多 1 秒）
        let deadline = Date().addingTimeInterval(1.0)
        while !task.isCancelled && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
        
        // Debug: App terminating
        // Debug: App terminating
    }
}

