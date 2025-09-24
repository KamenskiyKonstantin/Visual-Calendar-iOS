//
//  File.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//

import Foundation
import XCTest
@testable import Visual_Calendar_iOS

extension Preset {
    static let officialPresets: [Preset] = [
        Preset(presetName: "доктор", selectedSymbol: "🏥", backgroundColor: "Blue", mainImageURL: "/standard_library/doctor.png", sideImageURLs: []),
        Preset(presetName: "спортклуб", selectedSymbol: "🏋️‍♂️", backgroundColor: "Green", mainImageURL: "/standard_library/fitness.png", sideImageURLs: []),
        Preset(presetName: "бассейн", selectedSymbol: "🏊‍♂️", backgroundColor: "Teal", mainImageURL: "/standard_library/pool.png", sideImageURLs: []),
        Preset(presetName: "экскурсия", selectedSymbol: "🏛️", backgroundColor: "Orange", mainImageURL: "/standard_library/museum.png", sideImageURLs: []),
        Preset(presetName: "супермаркет", selectedSymbol: "🛒", backgroundColor: "Yellow", mainImageURL: "/standard_library/supermarket.png", sideImageURLs: []),
        Preset(presetName: "аттракционы", selectedSymbol: "🎡", backgroundColor: "Purple", mainImageURL: "/standard_library/amusement_park.png", sideImageURLs: []),
        Preset(presetName: "перелет", selectedSymbol: "✈️", backgroundColor: "Indigo", mainImageURL: "/standard_library/flight.png", sideImageURLs: []),
        Preset(presetName: "чтение", selectedSymbol: "📖", backgroundColor: "Brown", mainImageURL: "/standard_library/reading.png", sideImageURLs: []),
        Preset(presetName: "прогулка", selectedSymbol: "🚶‍♂️", backgroundColor: "Mint", mainImageURL: "/standard_library/walk.png", sideImageURLs: []),
        Preset(presetName: "фастфуд", selectedSymbol: "🍔", backgroundColor: "Red", mainImageURL: "/standard_library/fastfood.png", sideImageURLs: []),
        Preset(presetName: "ресторан", selectedSymbol: "🍽️", backgroundColor: "Pink", mainImageURL: "/standard_library/restaurant.png", sideImageURLs: [])
    ]
}

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
    
    
    func makeMockPreset(_ variation: Bool = false) -> Preset {
        return Preset(
            presetName: "Mock Preset",
            selectedSymbol: "🎯",
            backgroundColor: variation ? "Blue" : "Red",
            mainImageURL: "/standard_library/main_image.png",
            sideImageURLs: [
                "/standard_library/side_image_1.png",
                "/standard_library/side_image_2.png"
            ]
        )
    }

    func testLoginFlow() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Standard Auth Flow")

        let login = await api.login(email: email, password: password)
        let loginWarning = warningHandler.lastWarning
        XCTAssertTrue(login, "Login should succeed, failed with: \(loginWarning ?? "Unsurfaced Error")")
        
        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Standard Auth Flow")
    }
    
    func testInvalidCredentials() async throws {
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
    
    func testInvalidSignup() async throws {
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
    
    
    
    func testLibraryService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Library Service")

        // Login
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before library tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Fetch all available libraries
        let existingLibraries = await api.fetchExistingLibraries()
        XCTAssertFalse(existingLibraries.isEmpty, "Existing libraries should not be empty, got []")

        // Pick one known library
        let standardLibrary = existingLibraries.first { $0.system_name == "standard_library" }
        XCTAssertNotNil(standardLibrary, "Expected to find standard_library in existing libraries, got: \(existingLibraries)")

        // Add library
        let addSuccess = await api.addLibrary("standard_library")
        XCTAssertTrue(addSuccess, "Adding standard_library should succeed, failed with \(warningHandler.lastWarning ?? "Unsurfaced error")")

        // Fetch connected libraries
        var connectedLibraries = await api.fetchConnectedLibraries()
        XCTAssertTrue(connectedLibraries.contains(where: { $0.system_name == "standard_library" }),
                      "Connected libraries should include standard_library, got \(connectedLibraries)")

        // Remove library
        let removeSuccess = await api.removeLibrary("standard_library")
        XCTAssertTrue(removeSuccess, "Removing standard_library should succeed")

        connectedLibraries = await api.fetchConnectedLibraries()
        XCTAssertFalse(connectedLibraries.contains(where: { $0.system_name == "standard_library" }),
                       "Connected libraries should not include standard_library after removal, got \(connectedLibraries)")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Library Service")
    }
    
    func testPresetService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Preset Service")

        // Login
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before preset tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Initial fetch
        var presets = await api.fetchPresets()
        let actualSorted = presets.sorted(by: { $0.presetName < $1.presetName })
        let expectedSorted = Preset.officialPresets.sorted(by: { $0.presetName < $1.presetName })

        XCTAssertEqual(actualSorted, expectedSorted, "Official presets mismatch, expected \(expectedSorted), got \(actualSorted) instead.")

        // Create preset
        let presetName = "UnitTestPreset"
        let mockPreset = makeMockPreset()
        let createSuccess = await api.createPreset(preset: mockPreset)
        XCTAssertTrue(createSuccess, "Creating preset \(presetName) should succeed, failed with \(warningHandler.lastWarning ?? "Unsurfaced Error") instead")

        presets = await api.fetchPresets()
        XCTAssertEqual(presets.count, Preset.officialPresets.count+1, "Expected 1 preset after creation, got \(presets.count)")
        XCTAssertTrue(presets.contains(mockPreset), "Preset name mismatch: expected \(presetName), got none)")

        // Update preset
        let updatedPreset = makeMockPreset(true)
        let updateSuccess = await api.updatePreset(preset: updatedPreset)
        XCTAssertTrue(updateSuccess, "Updating preset \(presetName) should succeed")

        presets = await api.fetchPresets()
        let target = presets.first(where: {$0.presetName == updatedPreset.presetName})
        XCTAssertNotNil(target, "Target preset disappeared")
        XCTAssertTrue(target?.backgroundColor.lowercased() == "blue",
                      "Preset update not reflected, expected color 'blue', got \(target?.backgroundColor.lowercased() ?? "nil")")

        // Delete preset
        let deleteSuccess = await api.deletePreset(presetName: updatedPreset.presetName)
        XCTAssertTrue(deleteSuccess, "Deleting preset \(presetName) should succeed")

        presets = await api.fetchPresets()
        XCTAssertTrue(presets.count == Preset.officialPresets.count, "Expected no presets after delete, got \(presets)")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Preset Service")
    }
    
    func testEventService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Event Service")

        // Login
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before event tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Initial fetch
        var events = await api.fetchEvents()
        XCTAssertTrue(events.isEmpty, "Initial fetch should return empty list, got: \(events)")

        // Create one event
        let mockEvent = makeMockEvent()
        let createOne = await api.createEvent(mockEvent)
        XCTAssertTrue(createOne, "Creating single event should succeed")

        events = await api.fetchEvents()
        XCTAssertEqual(events.count, 1, "Expected 1 event after create, got \(events.count)")
        XCTAssertEqual(events.first?.id, mockEvent.id, "Fetched event ID mismatch, expected \(mockEvent.id), got \(events.first?.id ?? UUID())")

        // Update event
        var updatedEvent = mockEvent
        updatedEvent.backgroundColor = "Blue"
        let updateOne = await api.updateEvent(updatedEvent)
        XCTAssertTrue(updateOne, "Updating event should succeed")

        events = await api.fetchEvents()
        XCTAssertEqual(events.count, 1, "Expected still 1 event after update, got \(events.count)")
        XCTAssertEqual(events.first?.backgroundColor, "Blue", "Expected updated color 'Blue', got \(events.first?.backgroundColor ?? "nil")")

        // Create second event
        let mockEvent2 = makeMockEvent(color: "Green")
        let createTwo = await api.createEvent(mockEvent2)
        XCTAssertTrue(createTwo, "Creating second event should succeed")

        events = await api.fetchEvents()
        XCTAssertEqual(events.count, 2, "Expected 2 events after creating second, got \(events.count)")

        // Delete first event
        let deleteSuccess = await api.deleteEvent(mockEvent.id)
        XCTAssertTrue(deleteSuccess, "Deleting first event should succeed")

        events = await api.fetchEvents()
        XCTAssertEqual(events.count, 1, "Expected 1 event after deletion, got \(events.count)")
        XCTAssertEqual(events.first?.id, mockEvent2.id, "Remaining event should be mockEvent2, got \(events.first?.id ?? UUID())")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Event Service")
    }
    
    func testUserImageService() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: User Image Service")

        // Login
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before image tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Initial fetch
        var allMappings = await api.fetchImages([])
        XCTAssertTrue(allMappings.isEmpty, "Expected empty mapping initially, got \(allMappings)")

        let displayName = "UnitTestImage"
        let testData = makeTestPNG()

        // Create image
        let createSuccess = await api.createImage(testData, displayName)
        XCTAssertTrue(createSuccess, "Creating image \(displayName) should succeed")

        allMappings = await api.fetchImages([])
        let userImages = allMappings["user"] ?? []
        XCTAssertEqual(userImages.count, 1, "Expected 1 user image, got \(userImages.count)")
        XCTAssertEqual(userImages.first?.display_name, displayName, "Expected display name \(displayName), got \(userImages.first?.display_name ?? "nil")")

        // Update (overwrite) image
        let updateSuccess = await api.updateImage(makeTestPNG(color: .red), displayName)
        XCTAssertTrue(updateSuccess, "Updating image \(displayName) should succeed")

        allMappings = await api.fetchImages([])
        let updatedImage = allMappings["user"]?.first
        XCTAssertNotNil(updatedImage, "Expected updated image to exist, got nil")
        XCTAssertEqual(updatedImage?.display_name, displayName, "Expected updated display name to remain \(displayName), got \(updatedImage?.display_name ?? "nil")")

        // Delete image
        let deleteSuccess = await api.deleteImage(displayName)
        XCTAssertTrue(deleteSuccess, "Deleting \(displayName) should succeed")

        allMappings = await api.fetchImages([])
        XCTAssertTrue(allMappings.isEmpty, "Expected no images after delete, got \(allMappings)")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: User Image Service")
    }
    
    func testLibraryImageFetch() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Library Image Fetch")

        // Login
        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed before library image tests")
        XCTAssertTrue(api.isAuthenticated, "User should be authenticated after login")

        // Fetch available libraries
        let availableLibraries = await api.fetchExistingLibraries()
        XCTAssertFalse(availableLibraries.isEmpty,
                       "Available libraries should not be empty before image fetch, got []")

        // Pick a known library (use system_name if needed)
        guard let standardLibrary = availableLibraries.first(where: { $0.system_name == "standard_library" }) else {
            XCTFail("Expected to find 'standard_library' in available libraries, got: \(availableLibraries)")
            return
        }

        // Add library to connect it
        let addSuccess = await api.addLibrary("standard_library")
        XCTAssertTrue(addSuccess, "Adding standard_library should succeed, failed with \(warningHandler.lastWarning ?? "Unsurfaced error")")

        // Fetch images from the connected library
        let mappings = await api.fetchImages([standardLibrary])
        XCTAssertTrue(mappings.keys.contains(standardLibrary.localized_name),
                      "Mappings should contain key for \(standardLibrary.localized_name), got \(mappings.keys)")

        let libImages = mappings[standardLibrary.localized_name] ?? []
        XCTAssertFalse(libImages.isEmpty, "Expected non-empty image list for \(standardLibrary.localized_name), got []")

        // Validate metadata of first image
        guard let firstImage = libImages.first else {
            XCTFail("Library images unexpectedly empty for \(standardLibrary.localized_name)")
            return
        }

        XCTAssertFalse(firstImage.display_name.isEmpty, "First image display name should not be empty")
        XCTAssertTrue(firstImage.file_url.contains("token="),
                      "First image URL should be signed (contain token), got: \(firstImage.file_url)")

        print("[-TESTER/APIHANDLER-] TESTING SUCCESSFUL: Library Image Fetch")
    }
    
    
    
    func testLogoutMidFetch() async throws {
        print("[-TESTER/APIHANDLER-] NOW TESTING: Logout Mid-Fetch")

        let loginSuccess = await api.login(email: email, password: password)
        XCTAssertTrue(loginSuccess, "Login should succeed")

        let mockEvent = makeMockEvent()
        let upserted = await api.createEvent(mockEvent)
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
