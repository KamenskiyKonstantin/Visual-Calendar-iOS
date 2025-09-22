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
    
    let calendarViewModel: CalendarViewModel = CalendarViewModel(
        api:api,
        warningHandler: warningManager
        
        
    )

    
    var currentView: some View {
        switch viewSwitcher.activeView {
            case .login:
                AnyView(LoginView() )
            case .selectRole:
                AnyView(SelectRoleView(viewSwitcher: viewSwitcher))
            case let .calendar(isAdult):
                AnyView(CalendarView(
                             viewSwitcher: viewSwitcher))
            case .loading:
                AnyView(LoadingView())
            
        }
    }
    
    var body: some View {
        currentView
            .onAppear {
                self.viewSwitcher.api = api
            }
            .alert("Error", isPresented: $warningManager.isShown) {
                        Button("OK", role: .cancel) {
                            warningManager.hideWarning()
                        }
                    } message: {
                        Text(warningManager.message)
                    }
            
        
    }
        
}

enum ActiveView {
    case login
    case selectRole
    case calendar(isAdult: Bool)
    case loading
}

@MainActor
class ViewSwitcher: ObservableObject {
    @ObservedObject var api: APIHandler
    
    @Published var activeView: ActiveView = .login
    
    init(api: APIHandler) {
        self.api = api
    }
    
    func switchToSelectRole() {
        activeView = .selectRole
    }
    
    func switchToLogin() {
        activeView = .login
    }
    
    func switchToCalendar(isAdult: Bool = false) async throws {
        guard api.isAuthenticated else {
            activeView = .login
            return
        }

        activeView = .loading

        try await api.fetchExistingLibraries()
        
        print("These libraries exist: \(api.availableLibraries)")

        let result = await Result { try await api.addLibrary("standard_library") }
        if case .failure(AppError.duplicateLibrary) = result {
            print("std library already added, ignoring")
        } else {
            try result.get()  // Propagate any other failure
        }

        try await api.fetchImageURLs()
        try await api.fetchEvents()
        try await api.fetchPresets()

        await MainActor.run {
            activeView = .calendar(isAdult: isAdult)
        }
    }
    func switchToLoading() {
        activeView = .loading
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
    
