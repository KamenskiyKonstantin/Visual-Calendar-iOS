//
//  ContentView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewSwitcher: ViewSwitcher
    let APIHandler: ServerAPIinteractor = ServerAPIinteractor()
    let calendarView: CalendarView
    
    
    init(){
        self.calendarView = CalendarView(eventList: [])
        self.viewSwitcher = ViewSwitcher(apiHandler:APIHandler)
    }
    
    var body: some View {
        if viewSwitcher.activeView == "login"{
            LoginView(APIinteractor: APIHandler, viewSwitcher: viewSwitcher)
        }
        if viewSwitcher.activeView == "selectRole"{
            SelectRoleView(viewSwitcher: self.viewSwitcher)
        }
        if viewSwitcher.activeView == "calendar"{
            viewSwitcher.calendarView
        }
    }
}
class ViewSwitcher: ObservableObject{
    
    let apiHandler: ServerAPIinteractor
    var calendarView: CalendarView = CalendarView(eventList: [])
    
    init(apiHandler: ServerAPIinteractor) {
        self.apiHandler = apiHandler
    }
    @Published public var activeView: String = "login"
    func switchToSelectRole(){
        
        self.activeView = "selectRole"
        
    }
    
    func switchToLogin(){
        self.activeView = "login"
    }
    
    func switchToCalendar(){
        if apiHandler.authSuccessFlag {
            Task{
                calendarView = CalendarView(eventList: await apiHandler.fetchEvents())
                self.activeView = "calendar"
            }
            
        }
    }
    
    
}
#Preview {
    ContentView()
}
