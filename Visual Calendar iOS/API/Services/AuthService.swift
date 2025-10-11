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
        print("[-SERVICES/AUTH] VERIFYING SESSION")
        do {
            try await auth.refreshSession()
            print("[-SERVICES/AUTH] SESSION VALID")
        } catch {
            print("[-SERVICES/AUTH] SESSION INVALIDATED")
            throw AppError.authSessionExpired
            
        }
    }
    func signUp(email: String, password: String, confirmPassword: String) async throws {
        guard password == confirmPassword else {throw AppError.authMismatchSignupPassword}
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
        let folder = uid.uuidString.lowercased()
        let encoder = JSONEncoder()
        
        print("[-SERVICES/AUTH-] SETTING UP USER FOLDER FOR: /\(folder)")
        // Upload .keep to create folder
        try await client.storage.from("user_data").upload(
            path: "\(folder)/images/.keep",
            file: Data(),
            options: .init(cacheControl: "0", contentType: "text/plain", upsert: true)
        )
    }
}
