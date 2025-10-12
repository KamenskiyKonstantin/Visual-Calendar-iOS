//
//  ActiveView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//
import Foundation
import Combine

enum ActiveView: Equatable, Hashable {
    case login
    case selectRole
    case calendar(isAdult: Bool)
}

@MainActor
class ViewSwitcher: ObservableObject {
    
    @Published var activeView: ActiveView = .login
    
    private var resets: [ActiveView: () -> Void] = [:]
    private var userCallback: (Bool) -> Void = { _ in fatalError("FATAL: No user role callback registered for view: \(ActiveView.self). You must call setUserRoleCallback(:) before switching.") }

    func setResetCallback(_ callback: @escaping () -> Void, for view: ActiveView) {
        resets[view] = callback
    }
    
    func setUserRoleCallback(_ callback: @escaping (Bool) -> Void) {
        userCallback = callback
    }

    private func requireReset(for view: ActiveView) {
        guard let reset = resets[view] else {
            fatalError("FATAL: No reset callback registered for view \(view). You must call setResetCallback(_:for:) before switching.")
        }
        reset()
    }
    
    private func requireUserRoleCallback(isAdult: Bool) {
        userCallback(isAdult)
    }
    
    func switchToSelectRole() {
        requireReset(for: .selectRole)
        activeView = .selectRole
    }

    func switchToLogin() {
        requireReset(for: .login)
        activeView = .login
    }

    func switchToCalendar(isAdult: Bool = false) {
        requireReset(for: .calendar(isAdult: isAdult))
        requireUserRoleCallback(isAdult: isAdult)
        let targetView = ActiveView.calendar(isAdult: isAdult)
        activeView = targetView
    }
}
