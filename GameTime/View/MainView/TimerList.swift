import SwiftUI

/// Reusable timer list used across iPhone layouts in `MainView`.
struct TimerList: View {
    
    @EnvironmentObject private var timerManager: GTTimerManager
    
    let onEdit: (GTTimer) -> Void
    
    var body: some View {
        List {
            ForEach(timerManager.timers, id: \.id) { timer in
                TimerRowView(timer: timer)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            timerManager.deleteTimer(timer)
                        } label: {
                            Label("timer_list.action.delete", systemImage: "trash.fill")
                        }
                        .tint(.red)
                        
                        Button {
                            onEdit(timer)
                        } label: {
                            Label("timer_editor.action.edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    let timerOne = GTTimer(name: "Arya", color: .pink, maxTime: 1800, remainingTime: 1500)
    let timerTwo = GTTimer(name: "Sansa", color: .cyan, maxTime: 2400, remainingTime: 2100)
    let manager = GTTimerManager(timers: [timerOne, timerTwo], activeTimerIndex: 0)
    
    return TimerList { _ in }
        .environmentObject(manager)
}
