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
    private let selectRoleModel: SelectRoleViewModel
    private let calendarModel: CalendarViewModel


    init() {
        // define references
        let viewSwitcher = ViewSwitcher()
        let api = APIHandler()
        let warningHandler = WarningHandler()
        

        
        // create AsyncExecutor

        
        // Create ViewModels
        let loginModel = LoginViewModel(api: api, viewSwitcher: viewSwitcher)
        let selectRoleModel = SelectRoleViewModel(api: api, viewSwitcher: viewSwitcher, warningHandler: warningHandler)
        let calendarModel = CalendarViewModel(api: api, warningHandler: warningHandler, viewSwitcher: viewSwitcher)
        
        @Sendable
        @MainActor
        func logoutSequence() async {
            _ = await api.logout()
            viewSwitcher.switchToLogin()
            UserDefaultsManager.shared.clearAll()
            loginModel.reset()
            selectRoleModel.reset()
            calendarModel.reset()
        }
        
        let executor = AsyncExecutor(warningHandler: warningHandler, logoutSequence: logoutSequence)
        
        api.setExecutor(executor)
        
        viewSwitcher.setResetCallback(loginModel.reset, for: .login)
        viewSwitcher.setResetCallback(selectRoleModel.reset, for: .selectRole)
        viewSwitcher.setResetCallback(calendarModel.reset, for: .calendar(isAdult: true))
        viewSwitcher.setResetCallback(calendarModel.reset, for: .calendar(isAdult: false))
        
        viewSwitcher.setUserRoleCallback(calendarModel.setParentMode)
        
        // inject into self
        self.api = api
        self.viewSwitcher = viewSwitcher
        self.warningHandler = warningHandler
        
        self.loginModel = loginModel
        self.selectRoleModel = selectRoleModel
        self.calendarModel = calendarModel
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView(loginViewModel: self.loginModel, selectRoleModel: self.selectRoleModel, calendarViewModel: calendarModel, viewSwitcher: self.viewSwitcher, warningManager: self.warningHandler, )
        }
    }
}
