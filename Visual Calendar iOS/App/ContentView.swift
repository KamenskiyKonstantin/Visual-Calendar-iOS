//
//  ContentView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading your data…")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ContentView: View {
    let loginViewModel: LoginViewModel
    
    @ObservedObject var viewSwitcher: ViewSwitcher
    @ObservedObject var warningManager: WarningHandler
    
    var currentView: some View {
        switch viewSwitcher.activeView {
            case .login:
            AnyView(LoginView(viewModel: loginViewModel))
            case .selectRole:
                AnyView(SelectRoleView())
            case let .calendar(isAdult):
                AnyView(CalendarView())
            case .loading:
                AnyView(LoadingView())
            
        }
    }
    
    var body: some View {
        currentView
            .alert("Error", isPresented: $warningManager.isShown) {
                        Button("OK", role: .cancel) {
                            warningManager.hideWarning()
                        }
                    } message: {
                        Text(warningManager.message)
                    }
            
        
    }
        
}


