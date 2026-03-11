
import SwiftUI

extension TimerEditorView {
    
    /// ViewModel for `TimerEditorView`, responsible for managing editor state for create/edit flows.
    class ViewModel: ObservableObject {
        
        /// The name of the timer being edited.
        @Published var name: String = ""
        
        /// The color of the timer being edited.
        @Published var color: Color = .blue
        
        /// The selected timer duration in hours, minutes, and seconds.
        @Published var duration: TimerDuration
        
        /// A binding to control editor presentation. Setting it to `false` dismisses the view.
        @Binding var isPresented: Bool
        
        private let mode: TimerEditorView.Mode
        
        private static let lastTimerDurationKey = "lastTimerDuration"
        
        var isCreateMode: Bool {
            if case .create = mode {
                return true
            }
            return false
        }
        
        var autofocusNameField: Bool {
            isCreateMode
        }
        
        /// Initializes the editor with a mode and a binding to control dismissal.
        /// - Parameters:
        ///   - mode: The editor mode, used to load create defaults or an existing timer values.
        ///   - isPresented: A binding to a Boolean controlling the presentation of the view.
        init(mode: TimerEditorView.Mode, isPresented: Binding<Bool>) {
            self.mode = mode
            self._isPresented = isPresented
            
            switch mode {
            case .create:
                if let lastTimerDuration = UserDefaults.standard.object(forKey: ViewModel.lastTimerDurationKey) as? [String: Int] {
                    self.duration = TimerDuration(hours: lastTimerDuration["hours"] ?? 0, minutes: lastTimerDuration["minutes"] ?? 0, seconds: lastTimerDuration["seconds"] ?? 0)
                } else {
                    self.duration = .init(hours: 0, minutes: 30, seconds: 0)
                }
            case .edit(let timer):
                self.name = timer.name
                self.color = timer.color
                self.duration = Self.timerDuration(seconds: timer.totalDuration)
            }
        }
        
        /// Saves changes and dismisses the editor.
        func saveAndClose(using manager: GTTimerManager) {
            
            let totalSecondsSelected = duration.hours * 3600 + duration.minutes * 60 + duration.seconds
            
            switch mode {
            case .create:
                let newTimer = GTTimer(name: name, color: color, maxTime: totalSecondsSelected)
                manager.addTimer(timer: newTimer)
            case .edit(let timer):
                manager.updateTimer(timer, name: name, color: color, totalDuration: totalSecondsSelected)
            }
            
            // Store chosen duration
            let durationDict = ["hours": duration.hours, "minutes": duration.minutes, "seconds": duration.seconds]
            UserDefaults.standard.set(durationDict, forKey: ViewModel.lastTimerDurationKey)
            
            self.isPresented = false
        }
        
        private static func timerDuration(seconds: Int) -> TimerDuration {
            let clampedSeconds = max(seconds, 0)
            let hours = clampedSeconds / 3600
            let minutes = (clampedSeconds % 3600) / 60
            let remainingSeconds = clampedSeconds % 60
            return TimerDuration(hours: hours, minutes: minutes, seconds: remainingSeconds)
        }
                
    }
    
}
