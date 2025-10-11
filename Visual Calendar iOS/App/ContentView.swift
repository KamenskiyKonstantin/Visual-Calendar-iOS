//
//  ContentView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

struct ContentView: View {
    let loginViewModel: LoginViewModel
    let selectRoleModel: SelectRoleViewModel
    let calendarViewModel: CalendarViewModel
    
    @ObservedObject var viewSwitcher: ViewSwitcher
    @ObservedObject var warningManager: WarningHandler
    
    var currentView: some View {
        switch viewSwitcher.activeView {
            case .login:
                AnyView(LoginView(viewModel: loginViewModel))
            case .selectRole:
                AnyView(SelectRoleView(viewModel: selectRoleModel))
            case .calendar(_):
                AnyView(CalendarView(viewModel: calendarViewModel))
            
        }
    }
    
    var body: some View {
        currentView
            .alert("WarningHandler.Warning.Modal.Title".localized, isPresented: $warningManager.isShown) {
                        Button("WarningHandler.Warning.OK.Button.Title".localized, role: .cancel) {
                            warningManager.hideWarning()
                        }
                    } message: {
                        Text(warningManager.message)
                    }
            
        
    }
        
}


