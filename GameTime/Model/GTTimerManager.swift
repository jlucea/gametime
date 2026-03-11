
import Foundation
import SwiftUI

enum TimerNavigationDirection {
    case next
    case previous
}

/// Manages a collection of `GTTimers`, allowing for adding, deleting, and switching
/// between active timers. The class maintains the concept of an "active" timer, which
/// is simply the timer currently selected. Only one timer can be active at a time,
/// but it may or may not be running. The `GTTimerManager` handles transitions between
/// timers and ensures only one timer is active at any given time.
final class GTTimerManager : ObservableObject {
    
    /// An array of all `GTTimers` managed by this instance.
    /// New timers can be added via `addTimer(timer:)`, and existing timers
    /// can be deleted using `deleteTimer(_:)`.
    @Published var timers: [GTTimer] = []
    
    /// The currently active `GTTimer`, representing the selected timer.
    /// The active timer is updated when timers are added, deleted, or switched via methods like `activateNextTimer()` and `makeActive(_:)`.
    @Published private(set) var activeTimer: GTTimer?
    
    /// The last navigation direction used to switch the active timer.
    @Published private(set) var lastNavigationDirection: TimerNavigationDirection = .next
        
    /// The index of the active timer in the `timers` array. Used internally to keep track of which timer is currently selected.
    private var activeTimerIndex: Int = 0
    
    /// Initializes an empty `GTTimerManager` with no timers.
    init() {
        
    }
    
    /// Initializes a `GTTimerManager` with an array of timers and sets an initial active timer.
    ///
    /// - Parameters:
    ///   - timers: An array of `GTTimer` instances to initialize the manager with.
    ///   - activeTimerIndex: The index of the timer to be set as active. Defaults to 0 if out of bounds.
    init(timers: [GTTimer], activeTimerIndex: Int) {
        self.timers = timers
        self.activeTimerIndex = timers.indices.contains(activeTimerIndex) ? activeTimerIndex : 0
        self.activeTimer = timers.indices.contains(activeTimerIndex) ? timers[activeTimerIndex] : nil
    }
    
    /// Adds a new timer to the manager. If this is the first timer being added,
    /// it is set as the active timer.
    ///
    /// - Parameter timer: The `GTTimer` instance to be added to the collection.
    func addTimer(timer: GTTimer) {
        timers.append(timer)
        if (timers.count == 1) {
            activeTimer = timer
            activeTimerIndex = 0
        }
    }
    
    /// Activates the next timer in the array. If the active timer is the last one,
    /// it cycles back to the first timer in the array. The active timer is updated
    /// based on the array's order but may or may not be running.
    func activateNextTimer() {
        guard !timers.isEmpty else { return }
        
        lastNavigationDirection = .next
        activeTimer?.pause()
        if (activeTimerIndex < timers.count-1 ) {
            activeTimerIndex+=1
        } else {
            // Cicle through timers, activating the first one in the array
            activeTimerIndex=0
        }
        activeTimer = timers[activeTimerIndex]

        if (activeTimer?.timeRemaining ?? 0 > 0 ) {
            activeTimer?.resume()
        }
    }
    
    /// Activates the previous timer in the array. If the active timer is the first one,
    /// it cycles back to the last timer in the array.
    func activatePreviousTimer() {
        guard !timers.isEmpty else { return }
        
        lastNavigationDirection = .previous
        activeTimer?.pause()
        if activeTimerIndex > 0 {
            activeTimerIndex -= 1
        } else {
            activeTimerIndex = timers.count - 1
        }
        activeTimer = timers[activeTimerIndex]
        
        if (activeTimer?.timeRemaining ?? 0 > 0) {
            activeTimer?.resume()
        }
    }
    
    /// Deletes the specified timer from the collection. If the timer being deleted
    /// is the active timer, the active timer is reset to the first timer in the list.
    /// If the deleted timer was running, the new active timer will resume.
    ///
    /// - Parameter timer: The `GTTimer` instance to be deleted.
    func deleteTimer(_ timer: GTTimer) {
        let wasRunning = !timer.isPaused
        if wasRunning {
            timer.pause()
        }
        // If the timer being deleted is the active timer, update activeTimerIndex
        if (timer.id == self.activeTimer?.id) {
            activeTimerIndex = 0
            self.activeTimer = timers[0]
        }
        // Remove timer from array
        timers = timers.filter() { $0 !== timer }
        
        // If the deleted timer was running, the new active timer will also resume
        if !timers.isEmpty && wasRunning {
            activeTimer!.resume()
        }
        
        // Note that the deleted timer remains paused and out of the timers array, but still instantated
    }
    
    /// Sets the specified timer as the active timer, making it the selected timer.
    /// If there was a previously active timer that was running, it is paused, and the
    /// new active timer resumes only if it has remaining time.
    ///
    /// - Parameter timer: The `GTTimer` instance to be made active.
    func makeActive(_ timer: GTTimer) {
        guard let timerIndex = timers.firstIndex(where: { $0.id == timer.id }) else { return }
        guard timerIndex != activeTimerIndex else { return }
        
        lastNavigationDirection = timerIndex < activeTimerIndex ? .previous : .next

        var wasRunning = false
        if let previousActiveTimer = activeTimer, !previousActiveTimer.isPaused {
            // Pause the timer that was previously active and running
            previousActiveTimer.pause()
            wasRunning = true
        }
        
        // Set the new active timer
        activeTimer = timer
        activeTimerIndex = timerIndex
        
        // Only resume if the previous active timer was running and the new active timer has time remaining
        if wasRunning && activeTimer?.timeRemaining ?? 0 > 0 {
            activeTimer?.resume()
        }
    }
    
    /// Checks if the specified timer is the currently active (selected) timer.
    ///
    /// - Parameter timer: The `GTTimer` instance to check.
    /// - Returns: `true` if the specified timer is the active timer, otherwise `false`.
    func isActive(timer: GTTimer) -> Bool {
        return timer.id == activeTimer?.id
    }
    
    /// Updates an existing timer with new configuration values.
    ///
    /// If the timer is currently running, it is paused before applying changes.
    /// The elapsed time is preserved so the remaining time is recalculated against the new total duration.
    ///
    /// - Parameters:
    ///   - timer: The timer to update.
    ///   - name: The updated timer name.
    ///   - color: The updated timer color.
    ///   - totalDuration: The updated total duration in seconds.
    func updateTimer(_ timer: GTTimer, name: String, color: Color, totalDuration: Int) {
        guard timers.contains(where: { $0.id == timer.id }) else { return }
        
        if !timer.isPaused {
            timer.pause()
        }
        
        let elapsedTime = max(timer.totalDuration - timer.timeRemaining, 0)
        let adjustedTotalDuration = max(totalDuration, 0)
        
        timer.name = name
        timer.color = color
        timer.totalDuration = adjustedTotalDuration
        timer.timeRemaining = max(adjustedTotalDuration - elapsedTime, 0)
    }
    
    /// Resets a timer back to its configured maximum duration.
    ///
    /// If the timer is currently running, it is paused first.
    ///
    /// - Parameter timer: The timer to reset.
    func resetTimer(_ timer: GTTimer) {
        guard timers.contains(where: { $0.id == timer.id }) else { return }
        
        if !timer.isPaused {
            timer.pause()
        }
        
        timer.timeRemaining = timer.totalDuration
    }
    
}

extension GTTimerManager {
    
    static func mocked() -> GTTimerManager {
        let timers = [
            GTTimer(name: "Tyrion", color: .purple, maxTime: 3044, remainingTime: 2101),
            GTTimer(name: "Daenerys", color: .red, maxTime: 6375, remainingTime: 3024),
            GTTimer(name: "Cersei", color: .white, maxTime: 7971, remainingTime: 5505),
            GTTimer(name: "Viserys", color: .yellow, maxTime: 3829, remainingTime: 999),
            GTTimer(name: "Theon", color: .teal, maxTime: 3829, remainingTime: 755)
        ]
        return GTTimerManager(timers: timers, activeTimerIndex: 2)
    }
        
}
