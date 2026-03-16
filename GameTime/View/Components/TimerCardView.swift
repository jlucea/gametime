//
//  TimerCard.swift
//  GameTime
//
//  Created by Jaime Lucea on 15/10/22.
//

import SwiftUI

struct TimerCardView: View {
    
    @Environment(\.editMode) private var editMode
    
    @EnvironmentObject var controller: GTTimerManager
    @ObservedObject var timer: GTTimer
    
    /// Reuses the existing editor sheet flow from the parent view.
    let onEdit: (GTTimer) -> Void
    
    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 220
    private let circleFrameWidth: CGFloat = 160
    private let circleFrameHeight: CGFloat = 160
    
    var body: some View {
        ZStack{
            CircularProgressView(color: timer.color
                                 , progress: timer.getProgress(), lineWidth: 6)
            .frame(width: circleFrameWidth, height: circleFrameHeight)
            
            VStack {
                // Player name
                Text(timer.name)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                // Time remaining
                Text(timer.getTimeString())
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
            }
        } // ZStack
        .frame(width: cardWidth, height: cardHeight, alignment: .center)
        .background {
            if (timer.isPaused) {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("GTDarkGrayColor"))
            } else {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("GTLightGrayColor"))
            }
        }
        .overlay(alignment: .topLeading) {
            // A delete button will be displayed when edit mode is turned on
            if editMode?.wrappedValue.isEditing == true {
                Button(action: {
                    controller.deleteTimer(timer)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .foregroundStyle(.white, .black, .red)
                        .frame(width: 25, height: 25)
                        .padding([.top, .leading])
                }
                .frame(width: cardWidth, height: cardHeight, alignment: .topLeading)
            }
        }
        .overlay(alignment: .topTrailing) {
            // A top trailing button gives access to a menu with the edit, reset and delete actions.
            Menu {
                Button {
                    onEdit(timer)
                } label: {
                    Label("timer_editor.action.edit", systemImage: "pencil")
                }
                
                Button {
                    controller.resetTimer(timer)
                } label: {
                    Label("timer_list.action.reset", systemImage: "arrow.counterclockwise.circle.fill")
                }
                
                Button(role: .destructive) {
                    controller.deleteTimer(timer)
                } label: {
                    Label("timer_list.action.delete", systemImage: "trash.fill")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding([.top, .trailing], 14)
            }
        }
        .contextMenu {
            // Pointer and right-click users get the same actions through the context menu.
            Button {
                onEdit(timer)
            } label: {
                Label("timer_editor.action.edit", systemImage: "pencil")
            }
            
            Button {
                controller.resetTimer(timer)
            } label: {
                Label("timer_list.action.reset", systemImage: "arrow.counterclockwise.circle.fill")
            }
            
            Button(role: .destructive) {
                controller.deleteTimer(timer)
            } label: {
                Label("timer_list.action.delete", systemImage: "trash.fill")
            }
        }
        .onTapGesture {
            // When the card view is tapped, the corresponding timer will activate
            if (controller.isActive(timer: timer) == false) {
                withAnimation(.easeInOut(duration: 0.22)) {
                    controller.makeActive(timer)
                }
            }
        }
    } // Body

}


struct TimerCard_Previews: PreviewProvider {
    
    static var previews: some View {
        let previewClock : GTTimer = GTTimer(name: "Player #3", color: .green, maxTime: 6155)
        TimerCardView(timer: previewClock) { _ in }
            .previewDevice(.none)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Timer card")
    }
}
