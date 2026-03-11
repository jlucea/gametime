//
//  EmptyView.swift
//  GameTime
//
//  Created by Jaime Lucea on 27/9/24.
//

import SwiftUI

struct EmptyView: View {
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "clock")
            
            Text(String(localized: "empty_state.title"))
                .font(.system(size: 28))
                .padding()
            
            Text(String(localized: "empty_state.subtitle"))
                .font(.subheadline)
                .padding()
            
            //TODO: Add button ("New timer")
            
            Spacer()
        }
        .padding(.bottom, 20)
    }
    
}

#Preview {
    EmptyView()
}
