//
//  Visual_Calendar_iOSApp.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

@main
struct Visual_Calendar_iOSApp: App {
    
    private let api: APIHandler
    private let viewSwitcher: ViewSwitcher
    private let warningHandler: WarningHandler
    
    private let loginModel: LoginViewModel


    init() {
        // define references
        let viewSwitcher = ViewSwitcher()
        let api = APIHandler()
        let warningHandler = WarningHandler()
        
        @Sendable
        @MainActor
        func logoutSequence() async {
            _ = await api.logout()
            viewSwitcher.switchToLogin()
        }
        
        // create AsyncExecutor
        let executor = AsyncExecutor(warningHandler: warningHandler, logoutSequence: logoutSequence)
        
        api.setExecutor(executor)
        
        // Create ViewModels
        let loginModel = LoginViewModel(api: api, viewSwitcher: viewSwitcher)
        func resetSwitchToRole(){print("SWITCHTOROLERESET")}
        
        viewSwitcher.setResetCallback(loginModel.reset, for: .login)
        viewSwitcher.setResetCallback(resetSwitchToRole, for: .selectRole)
        
        // inject into self
        self.api = api
        self.viewSwitcher = viewSwitcher
        self.warningHandler = warningHandler
        
        self.loginModel = loginModel
        
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView(loginViewModel: self.loginModel, viewSwitcher: self.viewSwitcher, warningManager: self.warningHandler)
        }
    }
}
