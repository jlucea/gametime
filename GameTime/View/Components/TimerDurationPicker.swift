
import SwiftUI

public struct TimerDurationPicker: View {
    
    @Binding var duration: TimerDuration
    
    private let hourRange = Array(0...23)
    private let minuteAndSecondRange = Array(0...59)
    
    private let hoursUnit = String(localized: "timer_duration_picker.unit.hours_short")
    private let minutesUnit = String(localized: "timer_duration_picker.unit.minutes_short")
    private let secondsUnit = String(localized: "timer_duration_picker.unit.seconds_short")
    
    public var body: some View {
        HStack(spacing: 10) {
            Picker(selection: $duration.hours, label: Text("timer_duration_picker.label.hours")) {
                ForEach(hourRange, id: \.self) { hour in
                    Text("\(hour) \(hoursUnit)").tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: 80)
            
            Picker(selection: $duration.minutes, label: Text("timer_duration_picker.label.minutes")) {
                ForEach(minuteAndSecondRange, id: \.self) { minute in
                    Text("\(minute) \(minutesUnit)").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: 80)
            
            Picker(selection: $duration.seconds, label: Text("timer_duration_picker.label.seconds")) {
                ForEach(minuteAndSecondRange, id: \.self) { second in
                    Text("\(second) \(secondsUnit)").tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: 80)
        }
    }
}

#Preview {
    TimerDurationPicker(duration: Binding.constant(.init(hours: 0, minutes: 25, seconds: 30)))
}
