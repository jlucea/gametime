//
//  GameTimeToolbar.swift
//  GameTime
//
//  Created by Jaime Lucea on 20/12/24.
//

import SwiftUI

struct GameTimeToolbar {
        
    /// The title displayed in the center of the toolbar.
    private static let toolbarTitleKey: LocalizedStringKey = "app.title"
    
    /**
     Generates the toolbar content for the `GameTime` application.
     
     This method provides:
     - A button to open a view for adding new timers.
     - The app's title displayed in the center of the navigation bar.
     - An edit button for managing existing timers (visible only when timers exist).
     
     - Parameters:
       - showAddNewTimerScreen: A binding to control the visibility of the add timer screen.
       - controller: The `GTTimerManager` instance used to manage timers and provide context for the toolbar.
     - Returns: A `ToolbarContent` instance with the configured toolbar items.
     */
    static func content(showAddNewTimerScreen: Binding<Bool>, controller: GTTimerManager) -> some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showAddNewTimerScreen.wrappedValue = true
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                })
                // Timer creation uses a sheet so the keyboard does not collapse the form on iPad.
                .sheet(isPresented: showAddNewTimerScreen, content: {
                    TimerEditorView(mode: .create, isPresented: showAddNewTimerScreen)
                        .environmentObject(controller)
                } )
            }
            
            // Toolbar title and edit mode button are removed.
            // Uncomment to re-enable them.
            
//            ToolbarItem(placement: .principal) {
//                Text(toolbarTitleKey).font(.headline)
//            }
//            ToolbarItem(placement: .navigationBarLeading) {
//                if !controller.timers.isEmpty {
//                    EditButton()       // Tapping this button will activate editMode
//                }
//            }
        }
    }
    
}

// MARK: - Preview

#Preview {
    NavigationView {
        VStack {
            Text("Content Area")
        }
        .toolbar {
            GameTimeToolbar.content(showAddNewTimerScreen: Binding.constant(false), controller: GTTimerManager())
        }
    }
}
