//
//  UtilsUI.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 23.01.2025.
//

import SwiftUI

struct messageBox: View {
    var text: String
    @Binding var isVisible: Bool
    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
            Button(action: {
                self.isVisible.toggle()
            }) {
                Text("OK")
            }
            .buttonBorderShape(.capsule)
            .background(Color.accentColor)
            .foregroundColor(.white)
            
        }
        
    }
}
#Preview {
}
