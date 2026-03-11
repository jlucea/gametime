
import SwiftUI

enum TimerViewSize {
    case large      // For iPad
    case medium     // For iPhone
}

///
/// A SwiftUI view that displays and controls the currently active timer.
///
/// The view renders a circular progress indicator, the player's name,
/// the remaining time, and playback controls (play/pause and next timer).
///
/// It observes a specific `GTTimer` instance so the UI updates whenever
/// the timer's state changes (remaining time, pause state, progress, etc.).
/// The view also accesses the shared `GTTimerManager` via the environment
/// to trigger actions such as activating the next timer.
///
struct ActiveTimerView: View {
    
    @EnvironmentObject var controller : GTTimerManager
    
    //
    // The active timer could be accessed through `controller.activeTimer`.
    // However, the view observes a specific `GTTimer` instance directly.
    //
    // Observing the timer ensures that the view refreshes whenever the
    // timer publishes updates (e.g. remaining time or pause state).
    //
    @ObservedObject var timer: GTTimer
    
    /// Determines the layout scale of the view.
    ///
    /// The same UI is reused across devices, but elements such as
    /// the circular progress indicator, fonts, and button sizes
    /// adjust depending on whether the view is rendered for iPad
    /// (`.large`) or iPhone (`.medium`).
    let size: TimerViewSize
    
    var body: some View {
        
        ZStack {
            let circleSize = (size == .large ? CGFloat(400) : 280)
            CircularProgressView(color: timer.color, progress: timer.getProgress(), lineWidth: 18)
                .frame(width: circleSize, height: circleSize)
            
            // Vertical stack containing player name, active timer and timer controls
            VStack {
                Spacer()
                let labelFontSize: CGFloat = (size == .large ? 32 : 24)
                Text(timer.name)
                    .font(.system(size: labelFontSize))
                    .foregroundColor(timer.color)
                    .padding(.bottom)
                
                let timeFontSize: CGFloat = (size == .large ? 52 : 38)
                Text(timer.getTimeString())
                    .font(.custom("Corsiva Hebrew", size: timeFontSize, relativeTo: .title))
                    .padding(.bottom, (size == .large ? 50 : 30))
                
                // MARK: Buttons
                let buttonSize = (size == .large ? CGFloat(66) : CGFloat(50))
                HStack {
                    // Start/pause active timer button
                    Button (action: {
                        if (timer.isPaused) {
                            print("PLAY timer \(timer.name): \(timer.timeRemaining) seconds left")
                            timer.start()
                        } else {
                            print("PAUSE timer \(timer.name): \(timer.timeRemaining) seconds left")
                            timer.pause()
                        }
                    }, label: {
                        if (timer.isPaused) {
                            Image(systemName: "play.circle")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                                .tint(.white)
                        } else {
                            Image(systemName: "pause.circle")
                                .resizable()
                                .frame(width: buttonSize, height: buttonSize)
                                .tint(.white)
                        }
                    })
                    .padding(.trailing, (size == .large ? 50 : 28))
                    
                    // Next timer button
                    Button (action: {
                        //
                        // "All observable objects automatically get access to an objectWillChange property,
                        //  which has a send() method we can all whenever we want observing views to refresh."
                        //
                        // We call objectWillChange.send() here for the view to be ready to update itself
                        //  when we activate the next timer in the controller.
                        //
                        if (controller.timers.count > 1) {
                            controller.objectWillChange.send()
                            controller.activateNextTimer()
                        }
                    }, label: {
                        Image(systemName: "arrow.right.circle")
                            .resizable()
                            .frame(width: buttonSize, height: buttonSize)
                            .tint(.white)
                    })
                }
                Spacer()
            } // VStack
        
        } // ZStack
    } // View
} // Struct

struct TimerControlView_Previews: PreviewProvider {

    static var previews: some View {
        ActiveTimerView(timer: GTTimer(name: "Fco. Javier", color: .blue, maxTime: 2199), size: .medium)
            .previewLayout(.sizeThatFits)
            .previewDevice(PreviewDevice(rawValue: "iPhone 16"))
            .preferredColorScheme(.dark)
            .padding(.horizontal, 50)
            .padding(.bottom, 120)
    }

}
