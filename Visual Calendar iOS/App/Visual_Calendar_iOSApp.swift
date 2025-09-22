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
    
    
    func logoutSequence() async throws {
        try await api.logout()
        viewSwitcher.switchToLogin()
    }

    init() {
        // define references
        let viewSwitcher = ViewSwitcher()
        let api = APIHandler()
        let warningHandler = WarningHandler()
        
        // inject into self
        self.api = api
        self.viewSwitcher = viewSwitcher
        self.warningHandler = warningHandler
        
        // create AsyncExecutor
        func logoutSequence() async throws {
            try await api.logout()
            viewSwitcher.switchToLogin()
        }
        
        
        
        
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(api)
                .environmentObject(warningHandler)
                .environmentObject(viewSwitcher)
        }
    }
}
