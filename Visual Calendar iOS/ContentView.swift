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
    }
}
class ViewSwitcher: ObservableObject{
    let apiHandler: ServerAPIinteractor
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
        Task{
            await apiHandler.fetchEvents()
        }
    }
    
    
}
#Preview {
    ContentView()
}
