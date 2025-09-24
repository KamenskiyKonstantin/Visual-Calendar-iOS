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
        viewSwitcher.switchToLogin()

        executor = AsyncExecutor(
            warningHandler: warningHandler,
            logoutSequence: { await self.viewSwitcher.switchToLogin()}
        )

        api = APIHandler()
        api.setExecutor(executor)
        
        email = "test+\(UUID().uuidString.prefix(6))@a.a"
        password = "aaaaaa"
        
        _ = await api.signUp(email: email, password: password)
        _ = await api.logout()
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
    private func makeTestPNG(color: UIColor = .green) -> Data {
        let size = CGSize(width: 2, height: 2)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return img.pngData()!
    }

    func testDLoginFlow() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Standard Auth Flow")
        
        let logout = await api.logout()
        let logoutWarning = warningHandler.lastWarning
        XCTAssertTrue(logout, "Logout should succeed, failed with: \(logoutWarning ?? "Unsurfaced Error")")

        let login = await api.login(email: email, password: password)
        let loginWarning = warningHandler.lastWarning
        XCTAssertTrue(login, "Login should succeed, failed with: \(loginWarning ?? "Unsurfaced Error")")
        
        XCTContext.runActivity(named: "Logout before login") { _ in
            XCTAssertTrue(logout, "Logout failed: \(logoutWarning ?? "Unsurfaced Error")")
        }

        XCTContext.runActivity(named: "Login with test credentials") { _ in
            XCTAssertTrue(login, "Login failed: \(loginWarning ?? "Unsurfaced Error")")
        }
        
        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Standard Auth Flow")
    }
    
    func testCInvalidCredentials() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Invalid Credentials Auth Flow")

        // 1. Wrong password
        let wrongPasswordLogin = await api.login(email: email, password: "boguswrongpassword")
        let wrongPasswordWarning = warningHandler.lastWarning ?? "nil"

        XCTAssertFalse(wrongPasswordLogin, "Login with correct email + wrong password should fail")
        XCTAssertTrue(warningHandler.wasWarningShown, "Warning should have been shown for wrong password")
        XCTAssertTrue(wrongPasswordWarning.localizedCaseInsensitiveContains("invalid login credentials"),
                      "Expected warning to contain 'Invalid login credentials', got: \(wrongPasswordWarning)")

        // 2. Wrong email
        let wrongEmailLogin = await api.login(email: "wrong+\(UUID().uuidString.prefix(6))@a.a", password: password)
        let wrongEmailWarning = warningHandler.lastWarning ?? "nil"

        XCTAssertFalse(wrongEmailLogin, "Login with wrong email + correct password should fail")
        XCTAssertTrue(warningHandler.wasWarningShown, "Warning should have been shown for wrong email")
        XCTAssertTrue(wrongEmailWarning.localizedCaseInsensitiveContains("invalid login credentials"),
                      "Expected warning to contain 'Invalid login credentials', got: \(wrongEmailWarning)")

        // 3. Both wrong
        let wrongBothLogin = await api.login(email: "wrong+\(UUID().uuidString.prefix(6))@a.a", password: "definitelywrong")
        let wrongBothWarning = warningHandler.lastWarning ?? "nil"

        XCTAssertFalse(wrongBothLogin, "Login with wrong email + wrong password should fail")
        XCTAssertTrue(warningHandler.wasWarningShown, "Warning should have been shown for wrong credentials")
        XCTAssertTrue(wrongBothWarning.localizedCaseInsensitiveContains("invalid login credentials"),
                      "Expected warning to contain 'Invalid login credentials', got: \(wrongBothWarning)")
        
        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Invalid Credentials Auth Flow")
    }
    
    func testBInvalidSignup() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Invalid Signup Flow")

        // 1. Duplicate signup
        let duplicateSignup = await api.signUp(email: email, password: password)
        let duplicateWarning = warningHandler.lastWarning ?? "nil"

        XCTAssertFalse(duplicateSignup, "Signing up with existing email should fail")
        XCTAssertTrue(warningHandler.wasWarningShown, "Warning should be shown for duplicate signup")
        XCTAssertTrue(duplicateWarning.localizedCaseInsensitiveContains("user already registered"),
                      "Expected warning to contain 'Email already registered', got: \(duplicateWarning)")

        // 2. Weak password
        let weakPasswordEmail = "weak+\(UUID().uuidString.prefix(6))@a.a"
        let weakPasswordSignup = await api.signUp(email: weakPasswordEmail, password: "123")
        let weakPasswordWarning = warningHandler.lastWarning ?? "nil"

        XCTAssertFalse(weakPasswordSignup, "Signup with weak password should fail")
        XCTAssertTrue(warningHandler.wasWarningShown, "Warning should be shown for weak password")
        XCTAssertTrue(weakPasswordWarning.localizedCaseInsensitiveContains("at least 6 characters"),
                      "Expected warning to mention 'at least 6 characters', got: \(weakPasswordWarning)")
        
        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Invalid Signup Flow")
    }
    
    
    
    func testEventService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Event Service")

        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before event tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Initial fetch
        var events = await api.fetchEvents()
        XCTAssertTrue(events.isEmpty, "Initial fetch should return empty event list")

        // Upsert one event
        let mockEvent = makeMockEvent()
        events.append(mockEvent)

        let upsertOne = await api.upsertEvents(events)
        XCTAssertTrue(upsertOne, "Upsert of single event should succeed, got: \(warningHandler.lastWarning ?? "No warning")")

        events = await api.fetchEvents()
        XCTAssertEqual(events, [mockEvent], "Expected to fetch single inserted event, got: \(events)")

        // Append second event
        let mockEvent2 = makeMockEvent(color: "Blue")
        events.append(mockEvent2)

        let upsertTwo = await api.upsertEvents(events)
        XCTAssertTrue(upsertTwo, "Upserting two events should succeed")

        events = await api.fetchEvents()
        XCTAssertEqual(events, [mockEvent, mockEvent2], "Expected both events after second upsert")

        // Delete one
        let deleteSuccess = await api.deleteEvent(mockEvent.id, from: events)
        XCTAssertTrue(deleteSuccess, "Deleting first event should succeed")

        events = await api.fetchEvents()
        XCTAssertEqual(events, [mockEvent2], "Only second event should remain after deletion")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Event Service")
    }
    
    func testImageAndLibraryService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Image + Library Service")

        // Login
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before library/image tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Start with a clean state
        let libraries: [LibraryInfo] = []
        var allMappings = await api.fetchImageURLs(using: libraries)
        XCTAssertTrue(allMappings.isEmpty, "Initial fetch with no libraries should be empty, was \(allMappings) instead")
        
        //Look up all libraries
        let availableLibraries = await api.fetchExistingLibraries()
        XCTAssertFalse(availableLibraries.isEmpty, "Available libraries were empty, shouldn't have")
        
        let expectedLibraries: [LibraryInfo] = [
            LibraryInfo(
                library_uuid: UUID(uuidString: "4e0da613-c0f8-4d19-8d0d-192b92643b5c")!,
                system_name: "standard_library",
                localized_name: "Стандартная библиотека"
            ),
            LibraryInfo(
                library_uuid: UUID(uuidString: "a2f1d9d2-1e2a-4c31-97f8-84e3dfe27301")!,
                system_name: "test_library",
                localized_name: "Тестовая библиотека"
            )
        ]
        
        XCTAssertEqual(expectedLibraries.count, availableLibraries.count, "Library counts differ")

        for (exp, act) in zip(expectedLibraries, availableLibraries) {
            XCTAssertEqual(exp.library_uuid, act.library_uuid, "UUID mismatch: expected \(exp.library_uuid), got \(act.library_uuid) instead")
            XCTAssertEqual(exp.system_name, act.system_name, "System name mismatch: expected \(exp.system_name), got \(act.system_name) instead")
            XCTAssertEqual(exp.localized_name, act.localized_name, "Localized name mismatch: expected \(exp.localized_name), got \(act.localized_name) instead")
        }
        
        let libraryAddSuccess = await api.addLibrary("standard_library", available: availableLibraries)
        XCTAssertTrue(libraryAddSuccess, "library add should succeed, failed instead with \(warningHandler.lastWarning ?? "Unsurfaced error")")
        

        // Fetch all images (with mappings)
        allMappings = await api.fetchImageURLs(using: availableLibraries)
        XCTAssertEqual(allMappings.keys.count, 1, "Should have exactly one library in mapping, got \(allMappings.keys.count) instead")
        XCTAssertNotNil(allMappings["Стандартная библиотека"], "Mapping should contain standard_library, didn't")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Image + Library Service")
    }
    
    func testUserImageService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: User Image Service")

        // Login first
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before image tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Initial fetch with [] libs should retturn [:]
        var allMappings = await api.fetchImageURLs(using: [])
        XCTAssertTrue(allMappings.isEmpty, "Expected one mapping group (user), got \(allMappings.keys.count) instead: \(allMappings.keys)")

        let testData = makeTestPNG()
        let displayName = "UnitTestImage"

        // Upsert image
        let uploadSuccess = await api.upsertImage(imageData: testData, filename: displayName)
        XCTAssertTrue(uploadSuccess, "User image upsert should succeed, failed instead with \(warningHandler.lastWarning ?? "Unsurfaced error")")

        // Fetch again
        allMappings = await api.fetchImageURLs(using: [])
        let userImages = allMappings["user"] ?? []
        XCTAssertEqual(userImages.count, 1, "Expected exactly 1 user image after upsert, got \(userImages.count) instead: \(userImages)")

        guard let first = userImages.first else {
            XCTFail("User images list unexpectedly empty after upload")
            return
        }

        // Validate metadata
        XCTAssertEqual(first.display_name, displayName, "Display name mismatch: expected \(displayName), got \(first.display_name)")
        XCTAssertTrue(first.file_url.contains("token="), "File URL should be signed (contain token), got: \(first.file_url)")


        // Upload again with same display name — should fail
        let overwriteSuccess = await api.upsertImage(imageData: testData, filename: displayName)
        XCTAssertFalse(overwriteSuccess, "Second upsert with same display name should fail (overwrite forbidden), but it succeeded")
        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: User Image Service")
    }
    
    func testUserImageForceOverwrite() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: User Image Force Overwrite")

        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before force overwrite tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        let filename = "ForceOverwriteImage"

        // First upload
        let firstUpload = await api.upsertImage(imageData: makeTestPNG(color: .green), filename: filename, force: false)
        XCTAssertTrue(firstUpload, "First upload for \(filename) should succeed")

        // Force overwrite
        let secondUpload = await api.upsertImage(imageData: makeTestPNG(color: .red), filename: filename, force: true)
        XCTAssertTrue(secondUpload, "Force overwrite for \(filename) should succeed")

        // Fetch mappings and check only 1 image remains
        let mappings = await api.fetchImageURLs(using: [])
        let userImages = mappings["user"] ?? []
        XCTAssertEqual(userImages.count, 1, "Expected 1 image after force overwrite, got \(userImages.count)")
        XCTAssertEqual(userImages.first?.display_name, filename,
                       "Expected display name to remain \(filename), got \(userImages.first?.display_name ?? "nil")")
    }
    
    func testUserImageDelete() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: User Image Delete")

        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before delete tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        let filename = "DeleteMe"

        // Upload
        let uploadSuccess = await api.upsertImage(imageData: makeTestPNG(color: .yellow), filename: filename, force: false)
        XCTAssertTrue(uploadSuccess, "Upload before delete should succeed")

        // Delete
        let deleteSuccess = await api.deleteImage(filename: filename)
        XCTAssertTrue(deleteSuccess, "Deleting \(filename) should succeed")

        // Verify mappings are empty again
        let mappings = await api.fetchImageURLs(using: [])
        XCTAssertTrue(mappings.isEmpty ,
                      "Expected no images after delete, got: \(mappings)")
    }
    
    func testLogoutMidFetch() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Logout Mid-Fetch")

        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed")

        let mockEvent = makeMockEvent()
        let upserted = await api.upsertEvents([mockEvent])
        XCTAssertTrue(upserted, "Event upsert should succeed")

        // Logout before fetch
        let logoutSuccess = await api.logout()
        XCTAssertTrue(logoutSuccess, "Logout should succeed")

        let events = await api.fetchEvents()
        let warning = warningHandler.lastWarning ?? "nil"

        XCTAssertTrue(events.isEmpty, "Fetching events after logout should yield []")
        XCTAssertTrue(warning.localizedCaseInsensitiveContains("session"), "Expected session warning, got: \(warning)")
        XCTAssertEqual(viewSwitcher.switchHistory.last, .login)

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Logout Mid-Fetch")
    }

    func testAUnauthorizedFetchFailsAndLogsOut() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Unauthorized Access")

        // Ensure no prior session
        let events = await api.fetchEvents()
        let warning = warningHandler.lastWarning ?? "nil"

        XCTAssertTrue(events.isEmpty, "Unauthorized fetch should return empty array, got: \(events)")
        XCTAssertEqual(viewSwitcher.switchHistory.last, .login, "User should be switched to login screen on unauthorized fetch")
        XCTAssertTrue(warningHandler.wasWarningShown, "Expected a warning to be shown for unauthorized access")
        XCTAssertTrue(warning.localizedCaseInsensitiveContains("session"),
                      "Expected 'session' in warning, got: \(warning)")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Unauthorized Access")
    }
    
    override func tearDown() async throws {
        if api.isAuthenticated {
            _ = await api.logout()
        }
        print("[-TESTER/APIHANDLER-] TearDown complete — logged out user")
    }
}


#endif // TESTING
