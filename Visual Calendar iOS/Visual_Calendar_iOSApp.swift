//
//  Visual_Calendar_iOSApp.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 01.08.2024.
//

import SwiftUI

@main
struct Visual_Calendar_iOSApp: App {
    private let api = APIHandler()
    private let warningManager = GlobalWarningHandler()
    private let viewSwitcher: ViewSwitcher

    init() {
        self.viewSwitcher = ViewSwitcher(api: api)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(api)
                .environmentObject(warningManager)
                .environmentObject(viewSwitcher)
        }
    }
}
