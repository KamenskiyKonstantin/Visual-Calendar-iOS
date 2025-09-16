//
//  Buttons.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI

struct EditButtonView: View {
    @EnvironmentObject var APIHandler: APIHandler
    var updateEvents: (Event) async throws-> Void
    
    var body: some View {
        NavigationLink(destination:
                        EventEditor(updateCallback:updateEvents)){
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color(.systemGreen))
                .overlay(alignment: .center){
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                }
                .padding(10)
                .frame(width: 70, height: 70)
        }
    }
    
}

struct SwitchModeButtonView: View {
    @Binding var calendarMode: CalendarMode
    @Binding var currentDate: Date
    
    func toggleMode() {
        if calendarMode == .Day {
            currentDate = currentDate.startOfWeek()
        }
        else if calendarMode == .Week{
            currentDate = Calendar.current.startOfDay(for: .now)
        }
        calendarMode = calendarMode == .Day ? .Week : .Day
    }
    
    var body: some View {
        let symbol = calendarMode == .Day ? "list.bullet" : "calendar"
        Button(action: toggleMode) {
            Image(systemName: symbol)
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
                .foregroundColor(Color(.systemRed))
                .overlay(alignment: .center){
                    Image(systemName: "power")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                }
                .padding(10)
                .frame(width: 70, height: 70)
        }
    }
}

struct DeleteButtonView: View {
    @Binding var deleteMode: Bool
    
    var body: some View {
        Button(action: {
            deleteMode.toggle()
        }
        ) {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(deleteMode ? Color(.systemRed) : Color(.systemGray6))
                .overlay(alignment: .center)
                {
                    Image(systemName: "trash.slash")
                        .resizable()
                        .foregroundStyle(!deleteMode ? Color(.systemRed) : Color.white)
                        .scaledToFit()
                        .padding(5)
                }
                .frame(width: 70, height: 70)
                .padding(10)
           
        }
       
        
    
    }
}

struct ButtonPanel: View {
    @Binding var logoutFormShown: Bool
    @Binding var calendarMode: CalendarMode
    @Binding var currentDate: Date
    @Binding var deleteMode: Bool
    
    @EnvironmentObject var api: APIHandler
    @State var isParentMode: Bool
    @State var updateEvents: (Event) async throws -> Void
    
    
    var body: some View {
        HStack {
            LogoutButtonView(logoutFormShown: $logoutFormShown)
            SwitchModeButtonView(calendarMode: $calendarMode, currentDate: $currentDate)
            Spacer()
            if isParentMode {
                EditButtonView(
                    updateEvents: self.updateEvents
                )
                DeleteButtonView(deleteMode: $deleteMode)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
        
        .clipShape(RoundedRectangle(cornerRadius:10))
        .background(.ultraThinMaterial)
    }
}
