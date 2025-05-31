//
//  Buttons.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI

struct EditButtonView: View {
    var imageList: [String:[String:String]]
    @ObservedObject var APIHandler: APIHandler
    var updateEvents: (Event) async throws-> Void
    
    var body: some View {
        NavigationLink(destination:
                        EventEditor(imageURLS: imageList,
                                    APIHandler:APIHandler,
                                    updateCallback:updateEvents)){
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(.systemGreen)).opacity(0.5)
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
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(.systemRed)).opacity(0.5)
                .overlay(alignment: .center){
                    Image(systemName: "power")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
                
                .padding(10)
                .frame(width: 125, height: 125)
        }
    }
}
