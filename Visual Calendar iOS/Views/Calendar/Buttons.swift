//
//  Buttons.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI

struct EditButtonView: View {
    var imageList: [String:String]
    var APIHandler: ServerAPIinteractor
    var updateEvents: ([String:Any]) -> Void
    
    var body: some View {
        NavigationLink(destination:
                        EventEditor(imageURLS: imageList,
                                    APIHandler:APIHandler,
                                    callback:updateEvents)){
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.teal).opacity(0.5)
                .overlay(alignment: .center){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
                
                .padding(10)
                .frame(width: 125, height: 125)
        }
    }
    
}

struct LogoutButtonView: View {
    @Binding var logoutFormShown: Bool
    
    var body: some View {
        Button(action: {
            logoutFormShown = true
        }) {
            Image(systemName: "power")
        }
        .background(Color.red)
        .opacity(0.5)
        .padding()
        .cornerRadius(20)
        .frame(width: 200, height: 200)
    }
}
