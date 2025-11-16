import ComposableArchitecture

// MARK: - ThemeManager Dependency

extension DependencyValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

private enum ThemeManagerKey: DependencyKey {
    static let liveValue: ThemeManager = .shared
    static let testValue: ThemeManager = .shared  // TODO: Create mock for testing
}

