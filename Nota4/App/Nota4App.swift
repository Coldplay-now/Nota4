import SwiftUI

@main
struct Nota4App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "note.text")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Nota4")
                .font(.largeTitle)
            Text("v1.0.0-dev")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
}

