import Foundation
import AppKit

class FrontmostAppTracker {
    private var timer: Timer?
    private var lastBundleIdentifier: String?
    private let ownBundleIdentifier: String
    private let onAppChange: (String) -> Void
    
    init(onAppChange: @escaping (String) -> Void) {
        self.onAppChange = onAppChange
        self.ownBundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    }
    
    func startTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkFrontmostApp()
        }
    }
    
    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkFrontmostApp() {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return }
        let bundleID = frontApp.bundleIdentifier ?? ""
        guard bundleID != ownBundleIdentifier else { return }
        if bundleID != lastBundleIdentifier {
            lastBundleIdentifier = bundleID
            let appName = frontApp.localizedName ?? bundleID
            onAppChange(appName)
        }
    }
} 