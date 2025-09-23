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
class APIHandlerIntegrationTests: XCTestCase {
    var api: APIHandler!
    var warningHandler: MockWarningHandler!
    var viewSwitcher: MockViewSwitcher!
    var executor: AsyncExecutor!
    
    var email: String = ""
    var password: String = ""

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
        
        email = "test+\(UUID().uuidString.prefix(6))@a.a"
        password = "aaaaaa"
    }
    
    func makeMockEvent(
        id: UUID = UUID(),
        systemImage: String = "🎉",
        color: String = "Red"
    ) -> Event {
        return Event(
            systemImage: systemImage,
            dateTimeStart: Date(),
            dateTimeEnd: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
            mainImageURL: "https://example.com/image.png",
            sideImagesURL: ["https://example.com/side1.png", "https://example.com/side2.png"],
            id: id,
            bgcolor: color,
            textcolor: "White",
            repetitionType: "daily",
            reactionString: "👍",
            
        )
    }

    func testSignUpAndLoginFlow() async throws {

        let signedUp = await api.signUp(email: email, password: password)
        XCTAssertTrue(signedUp, "Sign up should succeed")

        let logout = await api.logout()
        XCTAssertTrue(logout, "Logout should succeed")

        let login = await api.login(email: email, password: password)
        XCTAssertTrue(login, "Login should succeed")
    }
    
    func testEventService() async throws {
        // login since every test logs itself out
        let loginSuccess = await api.login(email: email, password: password)

        if !loginSuccess {
            print("Login failed, trying to sign up instead...")
            let signUpSuccess = await api.signUp(email: email, password: password)
            XCTAssertTrue(signUpSuccess, "Sign up should succeed if login failed")
        } else {
            print("Logged in successfully, skipping signup")
        }
        
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated")
        
        var events = await api.fetchEvents()
        XCTAssertTrue(events.isEmpty, "Events are empty initially")
        
        let mockEvent = makeMockEvent()
        events.append(mockEvent)
        XCTAssertFalse(events.isEmpty)
        let upsertSuccess = await api.upsertEvents(events)
        XCTAssertTrue(upsertSuccess, "Logged in upsert should succeed, failed instead with \(warningHandler.lastWarning ?? "Unsurfaced error")")
        

        
        events = await api.fetchEvents()
        XCTAssertEqual(events, [mockEvent], "Fetch should fetch updated events, failed with: \(warningHandler.wasWarningShown ? warningHandler.lastWarning ?? "Unsurfaced error" : "No error detected")")
        
        let mockEvent2 = makeMockEvent(color: "Blue")
        
        events.append(mockEvent2)
        
        let upsertSuccess2 = await api.upsertEvents(events)
        XCTAssertTrue(upsertSuccess2)
        
        events = await api.fetchEvents()
        XCTAssertEqual(events, [mockEvent, mockEvent2])
        
        let deleteSuccess = await api.deleteEvent(mockEvent.id, from: events)
        XCTAssertTrue(deleteSuccess)
        
        events = await api.fetchEvents()
        XCTAssertEqual(events, [mockEvent2])
        
    }

    func testUnauthorizedFetchFailsAndLogsOut() async throws {
        // Don't log in — call fetchEvents directly
        let events = await api.fetchEvents()
        
        XCTAssertTrue(events.isEmpty, "Should return empty on unauthorized")

        XCTAssertEqual(viewSwitcher.switchHistory.last, .login)
        XCTAssertTrue(warningHandler.wasWarningShown)
        
    }
    
   
    
    override func tearDown() async throws{
        if api.isAuthenticated{
            _ = await api.logout()
        }
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
