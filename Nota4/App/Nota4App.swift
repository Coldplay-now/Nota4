import SwiftUI
import ComposableArchitecture

@main
struct Nota4App: App {
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建笔记") {
                    store.send(.editor(.createNote))
                }
                .keyboardShortcut("n")
            }
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Image(systemName: "note.text")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Nota4")
                    .font(.largeTitle)
                Text("v1.0.0-dev")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("TCA 架构已初始化")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            .padding()
            .frame(minWidth: 800, minHeight: 600)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}

