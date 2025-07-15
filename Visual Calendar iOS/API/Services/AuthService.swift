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
    
    func restoreSession() async throws -> Bool {
        let session = try await client.auth.session
            print("Session restored for user: \(session.user.id)")
            return true
        }

    var isAuthenticated: Bool {
        auth.currentUser != nil
    }

    func signUp(email: String, password: String) async throws {
        _ = try await auth.signUp(email: email, password: password)
        try await createUserFolders(uid: auth.currentUser!.id)
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

        // Upload empty calendar.json
        let starterCalendar = CalendarJSON(events: [], uid: uid.uuidString)
        let calendarData = try JSONEncoder().encode(starterCalendar)
        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/calendar.json",
            file: calendarData,
            options: .init(cacheControl: "0", contentType: "application/json", upsert: true)
        )
        
        // Upload empty files to simulate folder creation (optional)
        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/images/.keep",
            file: Data(),
            options: .init(cacheControl: "0", contentType: "text/plain", upsert: true)
        )
        
        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/presets.json",
            file: Data(),
            options: .init(cacheControl: "0", contentType: "application/json", upsert: true)
        )
    }
    
}
