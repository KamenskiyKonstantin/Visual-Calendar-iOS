//
//  WarningHandler.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//
import Foundation
import Combine

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
                _ = await api.logout()
                viewSwitcher.switchToLogin()
                
            }
        }
    }
}
    
