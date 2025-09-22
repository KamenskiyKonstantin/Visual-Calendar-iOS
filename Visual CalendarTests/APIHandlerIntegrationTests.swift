//
//  File.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//

import Foundation
import XCTest
@testable import Visual_Calendar_iOS
#if TESTING
@MainActor
final class APIHandlerIntegrationTests: XCTestCase {
    var api: APIHandler!
    var warningHandler: MockWarningHandler!
    var viewSwitcher: MockViewSwitcher!
    var executor: AsyncExecutor!

    override func setUp() async throws {
        print("SETTING UP TESTING CASE FOR APIHANDLER")
        warningHandler = MockWarningHandler()
        viewSwitcher = MockViewSwitcher()

        executor = AsyncExecutor(
            warningHandler: warningHandler,
            logoutSequence: { await self.viewSwitcher.switchToLogin()}
        )

        api = APIHandler()
        api.setExecutor(executor)
    }

    func testSignUpAndLoginFlow() async throws {
        print("NOW TESTING: SIGNING UP")
        let email = "test+\(UUID().uuidString.prefix(6))@a.a"
        let password = "aaaaaa"

        let signedUp = await api.signUp(email: email, password: password)
        XCTAssertTrue(signedUp, "Sign up should succeed")

        let logout = await api.logout()
        XCTAssertTrue(logout, "Logout should succeed")

        let login = await api.login(email: email, password: password)
        XCTAssertTrue(login, "Login should succeed")
    }

    func testUnauthorizedFetchFailsAndLogsOut() async throws {
        
        // Don't log in — call fetchEvents directly
        let events = await api.fetchEvents()
        
        XCTAssertTrue(events.isEmpty, "Should return empty on unauthorized")

        XCTAssertEqual(viewSwitcher.switchHistory.last, .login)
        XCTAssertTrue(warningHandler.wasWarningShown)
    }
}

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


@MainActor
final class MockWarningHandler: WarningHandler {
    private(set) var shownMessages: [String] = []

    override func showWarning(_ message: String) {
        super.showWarning(message)
        shownMessages.append(message)
    }

    var lastWarning: String? {
        shownMessages.last
    }

    var wasWarningShown: Bool {
        !shownMessages.isEmpty
    }

    func clear() {
        shownMessages.removeAll()
    }
}
#endif // TESTING
