//
//  AuthService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//
import Foundation
import Supabase
import Combine

@MainActor
class AuthService {
    private let auth: AuthClient
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
        self.auth = client.auth
    }

    var isAuthenticated: Bool {
        auth.currentUser != nil
    }
    
    func verifySession() async throws {
        do {
            try await auth.refreshSession()
        } catch {
            throw AppError.authSessionExpired
        }
    }
    func signUp(email: String, password: String) async throws {
        let session = try await auth.signUp(email: email, password: password)
        let userID = session.user.id 
        try await createUserFolders(uid: userID)
    }

    func login(email: String, password: String) async throws {
        _ = try await auth.signIn(email: email, password: password)
    }

    func logout() async throws {
        try await auth.signOut()
    }

    func currentUserID() async throws -> UUID {
        try await auth.user().id
    }

    func createUserFolders(uid: UUID) async throws {
        let encoder = JSONEncoder()

        // Upload empty calendar.json
        let starterCalendar = CalendarJSON(events: [], uid: uid.uuidString)
        let calendarData = try encoder.encode(starterCalendar)
        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/calendar.json",
            file: calendarData,
            options: .init(cacheControl: "0", contentType: "application/json", upsert: true)
        )

        // Upload .keep to create folder
        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/images/.keep",
            file: Data(),
            options: .init(cacheControl: "0", contentType: "text/plain", upsert: true)
        )

        let emptyPresetsData = try encoder.encode([String: Preset]())
        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/presets.json",
            file: emptyPresetsData,
            options: .init(cacheControl: "0", contentType: "application/json", upsert: true)
        )
    }
}
