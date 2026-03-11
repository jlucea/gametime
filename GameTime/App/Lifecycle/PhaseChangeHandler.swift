
import Foundation
import SwiftUI

final class PhaseChangeHandler {
    
    public static let shared = PhaseChangeHandler()
    private let backgroundTimeKey = "backgroundTime"
    
    private init() {}
    
    func onPhaseChange(_ newPhase: ScenePhase, timerController: GTTimerManager) {
        //
        // This code will be executed whenever the app changes phase.
        // In case the app enters background mode while a timer is active,
        // the timer should still discount the time passed when the app becomes active again.
        // In order to achieve this, we will:
        //   1. store the current time when the app enters background mode
        //   2. recover that time when the app becomes active again
        //   3. discount from the timer the time that has passed while being in the background
        //
        switch newPhase {
        case .active:
            guard
                !timerController.timers.isEmpty,
                let activeTimer = timerController.activeTimer,
                !activeTimer.isPaused,
                activeTimer.timeRemaining > 0,
                let backgroundDate = UserDefaults.standard.object(forKey: backgroundTimeKey) as? Date
            else {
                UserDefaults.standard.removeObject(forKey: backgroundTimeKey)
                return
            }
            
            let secondsInBackground = max(Int(Date.now.timeIntervalSince(backgroundDate)), 0)
            if secondsInBackground >= activeTimer.timeRemaining {
                activeTimer.timeRemaining = 0
                activeTimer.pause()
            } else {
                // Subtract from active timer the time passed since the app entered background.
                activeTimer.timeRemaining -= secondsInBackground
            }
            
            UserDefaults.standard.removeObject(forKey: backgroundTimeKey)
            
        case .background:
            guard let activeTimer = timerController.activeTimer, !activeTimer.isPaused else { return }
            // Store the Date when the app went into background.
            UserDefaults.standard.set(Date.now, forKey: backgroundTimeKey)
            
        case .inactive:
            break
            
        @unknown default:
            break
        }
    }
    
}
