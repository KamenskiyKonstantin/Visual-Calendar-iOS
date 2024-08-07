//
//  ContentView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewSwitcher: ViewSwitcher
    @State var APIHandler: ServerAPIinteractor
    init(){
        self.viewSwitcher = ViewSwitcher()
        self.APIHandler = ServerAPIinteractor()
    }
    var body: some View {
        if viewSwitcher.activeView == "login"{
            LoginView(APIinteractor: APIHandler,
            viewSwitcher: viewSwitcher)
        }
        if viewSwitcher.activeView == "selectRole"{
            SelectRoleView(viewSwitcher: self.viewSwitcher)
        }
    }
}
class ViewSwitcher: ObservableObject{
    @Published public var activeView: String = "login"
    func switchToSelectRole(){
        
        self.activeView = "selectRole"
        
    }
    
    func switchToLogin(){
        //print("switching to LoginView")
        self.activeView = "login"
    }
    
    
}
#Preview {
    ContentView()
}
