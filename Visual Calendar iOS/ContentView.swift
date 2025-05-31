//
//  ContentView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewSwitcher: ViewSwitcher
    let api: APIHandler = APIHandler()
    init(){
        self.viewSwitcher = ViewSwitcher(api:api)
    }
    
    var currentView: some View {
        switch viewSwitcher.activeView {
            case .login:
                AnyView(LoginView(APIinteractor: api, viewSwitcher: viewSwitcher))
            case .selectRole:
                AnyView(SelectRoleView(viewSwitcher: viewSwitcher))
            case let .calendar(isAdult):
                AnyView(CalendarView(api: api,
                             viewSwitcher: viewSwitcher,
                             imageList: api.images,
                             isParentMode: isAdult,))
        }
    }
    
    var body: some View {
        currentView
        
    }
}

enum ActiveView {
    case login
    case selectRole
    case calendar(isAdult: Bool)
}

@MainActor
class ViewSwitcher: ObservableObject {
    let api: APIHandler
    
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
        
        Task {
            do {
                try await api.fetchEvents()
                try await api.fetchImageURLs()
                await MainActor.run {
                    activeView = .calendar(isAdult: isAdult)
                }
                
            } catch {
                print(error)
                activeView = .login
            }
        }
    }
}
    
#Preview {
    ContentView()
}
