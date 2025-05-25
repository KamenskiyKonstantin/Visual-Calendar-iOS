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
        Group {
            switch viewSwitcher.activeView {
            case "login":
                LoginView(APIinteractor: APIHandler, viewSwitcher: viewSwitcher)
            case "selectRole":
                SelectRoleView(viewSwitcher: viewSwitcher)
            case "calendar":
                CalendarView(eventList: APIHandler.eventList, APIHandler: APIHandler, imageList: APIHandler.images, viewSwitcher: self.viewSwitcher)
            default:
                Text("Unknown View") // Fallback for unexpected states
            }
        }
    }
    
}
class ViewSwitcher: ObservableObject{
    
    let apiHandler: ServerAPIinteractor
    
    @Published public var activeView: String = "login"
    
    init(apiHandler: ServerAPIinteractor) {
        self.apiHandler = apiHandler
    }
    
    func switchToSelectRole(){
        self.activeView = "selectRole"
    }
    
    func switchToLogin(){
        self.activeView = "login"
    }
    
    @MainActor
    func switchToCalendar(isAdult: Bool = false){
        
        if apiHandler.authSuccessFlag {
            Task {
                await apiHandler.fetchEvents()
                await apiHandler.fetchImageURLS()
            }
            self.activeView = "calendar"
        }
    }
    
    
}
#Preview {
    ContentView()
}
