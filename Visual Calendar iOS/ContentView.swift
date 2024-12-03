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
    
    
    init(){
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
    var calendarView: CalendarView
    
    init(apiHandler: ServerAPIinteractor) {
        self.apiHandler = apiHandler
        self.calendarView = CalendarView(eventList: [],
                                         APIHandler: ServerAPIinteractor(),
                                         imageList: [:])
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
                calendarView = await CalendarView(eventList: await apiHandler.fetchEvents(), APIHandler: apiHandler, imageList: await apiHandler.fetchImageURLS())
                self.activeView = "calendar"
            }
            
        }
    }
    
    
}
#Preview {
    ContentView()
}
