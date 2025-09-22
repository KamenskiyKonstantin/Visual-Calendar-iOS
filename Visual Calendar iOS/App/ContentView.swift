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
    @EnvironmentObject var api: APIHandler
    @EnvironmentObject var warningManager: WarningHandler
    @EnvironmentObject var viewSwitcher: ViewSwitcher

    
    var currentView: some View {
        switch viewSwitcher.activeView {
            case .login:
                AnyView(LoginView() )
            case .selectRole:
                AnyView(SelectRoleView(viewSwitcher: viewSwitcher))
            case let .calendar(isAdult):
                AnyView(CalendarView(
                    viewModel: CalendarViewModel(api:api, warningHandler: warningManager, viewSwitcher:viewSwitcher), warningHandler:_warningManager, viewSwitcher: viewSwitcher))
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


@MainActor
class WarningHandler: ObservableObject {
    @Published var message: String = ""
    @Published var isShown: Bool = false


    func showWarning(_ message: String) {
        self.message = message
        self.isShown = true
    }

    func hideWarning() {
        message = ""
        isShown = false
    }

    func forceLogout(with message: String? = nil, api: APIHandler, viewSwitcher: ViewSwitcher) {
        if let msg = message {
            showWarning(msg)
        }
        Task{
            do {
                try await api.logout()
                viewSwitcher.switchToLogin()
                
            }
            catch {}
        }
    }
}
    
