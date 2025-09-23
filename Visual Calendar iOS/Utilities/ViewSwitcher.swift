//
//  ActiveView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//
import Foundation
import Combine

enum ActiveView: Equatable {
    case login
    case selectRole
    case calendar(isAdult: Bool)
    case loading
}

@MainActor
class ViewSwitcher: ObservableObject {
    

    
    @Published var activeView: ActiveView = .login
    
    func switchToSelectRole() {
        activeView = .selectRole
    }
    
    func switchToLogin() {
        activeView = .login
    }
    
    func switchToCalendar(isAdult: Bool = false)
    {
        activeView = .calendar(isAdult: isAdult)
    }
    func switchToLoading() {
        activeView = .loading
    }
}
