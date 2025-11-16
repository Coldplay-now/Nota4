import AppKit
import ComposableArchitecture

class AppDelegate: NSObject, NSApplicationDelegate {
    var store: StoreOf<AppFeature>?
    
    func applicationWillTerminate(_ notification: Notification) {
        print("🔴 [EXIT] ========================================")
        print("🔴 [EXIT] Application is terminating...")
        print("🔴 [EXIT] ========================================")
        
        // 应用退出前同步保存
        guard let store = store else { 
            print("🔴 [EXIT] ERROR: Store is nil!")
            return 
        }
        
        print("🔴 [EXIT] Triggering save before exit...")
        
        // 使用同步方式保存
        let task = Task {
            await store.send(.editor(.manualSave)).finish()
        }
        
        // 等待保存完成（最多 1 秒）
        let deadline = Date().addingTimeInterval(1.0)
        let startTime = Date()
        while !task.isCancelled && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
        let elapsed = Date().timeIntervalSince(startTime)
        
        print("🔴 [EXIT] Save wait completed in \(String(format: "%.2f", elapsed))s")
        print("🔴 [EXIT] ========================================")
    }
}

