
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
    
    private let swipeActivationThreshold: CGFloat = 50
    private let timerNavigationAnimationDuration: TimeInterval = 0.22
    
    @State private var isAnimatingNavigation = false
    
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
            timerContent
                .id(timer.id)
                .transition(transitionForDirection)
        } // ZStack
        .animation(.easeInOut(duration: timerNavigationAnimationDuration), value: timer.id)
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    handleSwipe(value)
                }
        )
    } // View
    
    private var timerContent: some View {
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
                        navigate(toNext: true)
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
    }
    
    private var transitionForDirection: AnyTransition {
        switch controller.lastNavigationDirection {
        case .next:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .previous:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }
    
    private func navigate(toNext: Bool) {
        guard controller.timers.count > 1, !isAnimatingNavigation else { return }
        isAnimatingNavigation = true
        
        withAnimation(.easeInOut(duration: timerNavigationAnimationDuration)) {
            if toNext {
                controller.activateNextTimer()
            } else {
                controller.activatePreviousTimer()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timerNavigationAnimationDuration + 0.02) {
            isAnimatingNavigation = false
        }
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let horizontalTranslation = value.translation.width
        let verticalTranslation = value.translation.height
        
        // Only react to intentional horizontal swipes.
        guard abs(horizontalTranslation) > abs(verticalTranslation),
              abs(horizontalTranslation) >= swipeActivationThreshold else {
            return
        }
        
        if horizontalTranslation > 0 {
            // Swiping right activates the previous timer.
            navigate(toNext: false)
        } else {
            // Swiping left activates the next timer.
            navigate(toNext: true)
        }
    }
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
