
import SwiftUI

struct TimerRowView: View {
    
    /// The timer object to display
    @ObservedObject var timer: GTTimer
    
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var timerManager: GTTimerManager
        
    var body: some View {
        HStack (alignment: .center, spacing: 28) {
            //MARK: Delete button
            if editMode?.wrappedValue.isEditing == true {
                Button(action: {
                    timerManager.deleteTimer(timer)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .foregroundStyle(.white, .black, .red)
                        .frame(width: 25, height: 25)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            HStack {
                //MARK: Name and time
                VStack (alignment: .leading, spacing: 5) {
                    // Label
                    Text(timer.name)
                        .font(.system(size: 18))
                        .foregroundStyle(timer.color)
                        
                    HStack (spacing: 14) {
                        // Time
                        Text(timer.getTimeString())
                            .font(.system(size: 24))
                        
                        if timerManager.isActive(timer: timer) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                
                Spacer()
                
                //MARK: Circular progress
                CircularProgressView(color: timer.color, progress: timer.getProgress(), lineWidth: 10)
                    .tint(timer.color)
                    .frame(width: 36, height: 36)
            }
            .contentShape(Rectangle())          // Ensures the whole area is tappable
            .onTapGesture {
                timerManager.makeActive(timer)  // This will be triggered when tapping anywhere on the HStack
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .animation(.easeInOut(duration: 0.3), value: editMode?.wrappedValue.isEditing)
    }
}

//MARK: - Previews

#Preview("Row") {
    let timerOne = GTTimer(name: "Chufo", color: .green, maxTime: 6155)
    let manager = GTTimerManager()
    
    TimerRowView(timer: timerOne)
        .padding(40)
        .onAppear {
            timerOne.timeRemaining = 2500
            manager.addTimer(timer: timerOne)
        }
        .environment(\.editMode, .constant(.active))
        .environmentObject(manager)
}

#Preview("List") {
    let timerOne = GTTimer(name: "Chufo", color: .green, maxTime: 6155)
    let timerTwo = GTTimer(name: "Trufa", color: .pink, maxTime: 6155)
    let timerThree = GTTimer(name: "Mango", color: .red, maxTime: 6155)
    let timerFour = GTTimer(name: "Atún", color: .orange, maxTime: 6155)
    
    List {
        TimerRowView(timer: timerOne)
        TimerRowView(timer: timerTwo)
        TimerRowView(timer: timerThree)
        TimerRowView(timer: timerFour)
    }
    .onAppear {
        timerOne.timeRemaining = 1200
        timerTwo.timeRemaining = 1650
        timerThree.timeRemaining = 2200
        timerFour.timeRemaining = 670
    }
}
