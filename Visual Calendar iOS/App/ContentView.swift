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
    @EnvironmentObject var warningManager: GlobalWarningHandler
    @EnvironmentObject var viewSwitcher: ViewSwitcher

    
    var currentView: some View {
        switch viewSwitcher.activeView {
            case .login:
                AnyView(LoginView() )
            case .selectRole:
                AnyView(SelectRoleView(viewSwitcher: viewSwitcher))
            case let .calendar(isAdult):
                AnyView(CalendarView(
                             viewSwitcher: viewSwitcher,
                             isParentMode: isAdult,))
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
    
    func switchToCalendar(isAdult: Bool = false) {
        guard api.isAuthenticated else {
            activeView = .login
            return
        }
        
        activeView = .loading
        
        Task {
            do {
                // Fetch library index early (critical for resolving names)
                try await api.fetchExistingLibraries()

                // Try to add the library, but suppress duplicate errors
                do {
                    try await api.addLibrary("standard_library")
                } catch {
                    print("Library already exists or failed silently: \(error.localizedDescription)")
                    // You may want to inspect specific errors if needed
                }

                // Parallelize non-conflicting fetches
                async let imageTask: Void = try api.fetchImageURLs()
                async let eventsTask: Void = try api.fetchEvents()
                async let presetsTask: Void = try api.fetchPresets()

                _ = try await (imageTask, eventsTask, presetsTask)

                // Only after all above tasks succeed, switch to main app
                await MainActor.run {
                    activeView = .calendar(isAdult: isAdult)
                }

            } catch {
                print("Error switching to main app: \(error.localizedDescription)")
                try? await api.logout()
                await MainActor.run {
                    activeView = .login
                }
            }
        }    }
    
    func switchToLoading() {
        activeView = .loading
    }
}



class GlobalWarningHandler: ObservableObject {
    @Published var message: String = ""
    @Published var isShown: Bool = false
    
    
    func showWarning(_ message: String) {
        self.message = message
        self.isShown = true
    }
    
    func hideWarning() {
        self.message = ""
        self.isShown = false
    }
}


    
