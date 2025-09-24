//
//  MockViewSwitcher.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//

@MainActor
final class MockViewSwitcher: ViewSwitcher {
    private(set) var switchHistory: [ActiveView] = []

    override func switchToLogin() {
        super.switchToLogin()
        switchHistory.append(.login)
    }

    override func switchToCalendar(isAdult: Bool = false) {
        super.switchToCalendar(isAdult: isAdult)
        switchHistory.append(.calendar(isAdult: isAdult))
    }

    override func switchToSelectRole() {
        super.switchToSelectRole()
        switchHistory.append(.selectRole)
    }

    override func switchToLoading() {
        super.switchToLoading()
        switchHistory.append(.loading)
    }
}

