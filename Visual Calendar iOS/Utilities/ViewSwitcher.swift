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
    case loading
}

@MainActor
class ViewSwitcher: ObservableObject {
    
    @Published var activeView: ActiveView = .login
    
    private var resets: [ActiveView: () -> Void] = [:]

    func setResetCallback(_ callback: @escaping () -> Void, for view: ActiveView) {
        resets[view] = callback
    }

    private func requireReset(for view: ActiveView) {
        guard let reset = resets[view] else {
            fatalError("FATAL: No reset callback registered for view \(view). You must call setResetCallback(_:for:) before switching.")
        }
        reset()
    }

    func switchToSelectRole() {
        //requireReset(for: .selectRole)
        activeView = .selectRole
    }

    func switchToLogin() {
        //requireReset(for: .login)
        activeView = .login
    }

    func switchToCalendar(isAdult: Bool = false) {
        let targetView = ActiveView.calendar(isAdult: isAdult)
        //requireReset(for: targetView)
        activeView = targetView
    }
}
