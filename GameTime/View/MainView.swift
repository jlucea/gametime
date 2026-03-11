
import SwiftUI

struct MainView: View {
    
    //
    // Instance of the controller class, that will be responsible for managing timers and their states.
    // This object is made available to other views and subviews as an @EnvironmentObject
    //
    @EnvironmentObject var timerManager: GTTimerManager
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showAddNewTimerScreen: Bool = false
    @State private var timerToEdit: GTTimer?
    
    var body: some View {
        NavigationView {
            VStack {
                if (timerManager.timers.isEmpty) {
                    EmptyView()
                } else {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        // MARK: iPad View
                        // Active timer and controls
                        ActiveTimerView(timer: timerManager.activeTimer!, size: .large)
                            .padding(.horizontal)
                        
                        // Timer cards
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(timerManager.timers, id: \.id) { timer in
                                    TimerCardView(timer: timer)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                        .padding(.leading)
                    } else {
                        GeometryReader { geometry in
                            let isLandscape = geometry.size.width > geometry.size.height
                            if isLandscape {
                                //MARK: iPhone landscape
                                HStack {
                                    ActiveTimerView(timer: timerManager.activeTimer!, size: .medium)
                                        .padding(.horizontal, 24)
                                    
                                    TimerListView { timer in
                                        timerToEdit = timer
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                //MARK: iPhone portrait
                                VStack(spacing: 10) {
                                    ActiveTimerView(timer: timerManager.activeTimer!, size: .medium)
                                    
                                    TimerListView { timer in
                                        timerToEdit = timer
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                        }
                    }
                }
            }
            .toolbar {
                GameTimeToolbar.content(showAddNewTimerScreen: $showAddNewTimerScreen, controller: timerManager)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $timerToEdit) { timer in
            TimerEditorView(
                mode: .edit(timer: timer),
                isPresented: Binding(
                    get: { timerToEdit != nil },
                    set: { isPresented in
                        if !isPresented {
                            timerToEdit = nil
                        }
                    }
                )
            )
            .environmentObject(timerManager)
        }
        .onChange(of: scenePhase) { newPhase in
            PhaseChangeHandler.shared.onPhaseChange(newPhase, timerController: timerManager)
        }
    } // End of Body
    
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
        
    static var previews: some View {
        
        let timer1 = GTTimer(name: "Tyrion", color: .purple, maxTime: 3044, remainingTime: 2101)
        let timer2 = GTTimer(name: "Daenerys", color: .red, maxTime: 6375, remainingTime: 3024)
        let timer3 = GTTimer(name: "Cersei", color: .white, maxTime: 7971, remainingTime: 5505)
        let timer4 = GTTimer(name: "Viserys", color: .orange, maxTime: 3829, remainingTime: 999)
        let timer5 = GTTimer(name: "Theon", color: .green, maxTime: 3829, remainingTime: 755)
        let array : [GTTimer] = [timer1, timer2, timer3, timer4, timer5]
        
        let previewManager = GTTimerManager(timers: array, activeTimerIndex: 0)
                                
        return MainView()
            .environmentObject(previewManager)
            .previewInterfaceOrientation(.portrait)
            .preferredColorScheme(.dark)
            .previewDisplayName("GameTime - Main View (Session Ongoing)")
            .tint(.white)
    }
}
