//
//  LibraryService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//

import Foundation
import Supabase

@MainActor
class LibraryService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // Fetch all available libraries
    func fetchAllLibraries() async throws -> [LibraryInfo] {
        let response = try await client
            .from("library_index")
            .select("library_uuid, system_name, localized_name")
            .execute()

        return try JSONDecoder().decode([LibraryInfo].self, from: response.data)
    }

    // Fetch system_names of libraries connected to the current user
    func fetchConnectedSystemNames() async throws -> [String] {
        let uid = try await client.auth.user().id
        
        let response = try await client
            .from("connected_libraries")
            .select("system_name")
            .eq("user_uuid", value: uid)
            .execute()

        let rows = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] ?? []
        return rows.compactMap { $0["system_name"] as? String }
    }

    // Add a library to user's connected ones using system_name and [LibraryInfo]
    func addLibrary(systemName: String, from libraries: [LibraryInfo]) async throws {
        guard let info = libraries.first(where: { $0.system_name == systemName }) else {
            throw AppError.libraryNotFound(systemName)
        }

        let uid = try await client.auth.user().id
        // inserts the library to user by looked up UUID and pushes system_name silently.
        _ = try await client
            .from("connected_libraries")
            .insert([
                "user_uuid": uid.uuidString,
                "library_uuid": info.library_uuid.uuidString,
                "system_name": info.system_name
            ])
            .execute()
    }
}
