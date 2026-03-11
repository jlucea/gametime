
import Foundation
import SwiftUI

class PhaseChangeHandler {
    
    public static let shared = PhaseChangeHandler()
    
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
        if newPhase == .active {
            if (timerController.timers.isEmpty == false) {
                if let activeTimer = timerController.activeTimer {
                    if (activeTimer.isPaused == false && activeTimer.timeRemaining > 0) {
                        if let backgroundDate : Date = UserDefaults.standard.object(forKey: "backgroundTime") as? Date {
                            
                            let secondsInBackground : TimeInterval = Date.now.timeIntervalSince(backgroundDate)
                            
                            if (Int(secondsInBackground) >= activeTimer.timeRemaining) {
                                activeTimer.timeRemaining = 0
                                activeTimer.pause()
                            } else {
                                // Subtract from active timer the time passed since the app entered background
                                activeTimer.timeRemaining -= Int(secondsInBackground)
                            }
                        }
                    }
                }
            }
            // Clear userDefaults
            UserDefaults.standard.removeObject(forKey: "backgroundTime")
            
        } else if newPhase == .background {
            if let activeTimer = timerController.activeTimer {
                if (activeTimer.isPaused == false) {
                    // Store the Date when the app went into background
                    UserDefaults.standard.set(Date.now, forKey: "backgroundTime")
                }
            }
        }
    }
    
}

