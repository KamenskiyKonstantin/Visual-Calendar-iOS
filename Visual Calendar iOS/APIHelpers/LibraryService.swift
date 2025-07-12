//
//  LibraryService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//

import Foundation
import Supabase
import Combine

@MainActor
class LibraryService: ObservableObject {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchLibraries() async throws -> [String] {
        let libraryEntries = try await client.storage.from("publiclibraries").list().map { $0.name }
        return libraryEntries
    }
    
    func checkLoadedLibraries() async throws -> [String] {
        let uid = try await client.auth.user().id

        let response = try await client
            .from("ConnectedLibraries")
            .select("library")
            .eq("uuid", value: uid)
            .execute()

        let data = response.data
        let libraries = try JSONDecoder().decode([LibraryEntry].self, from: data)

        return libraries.map(\.library)
    }

    func addLibrary(_ name: String) async throws {
        let uid = try await client.auth.user().id

        let response = try await client.from("ConnectedLibraries")
            .select()
            .eq("library", value: name)
            .eq("uuid", value: uid)
            .execute()

        let existing = try JSONDecoder().decode([LibraryJSON].self, from: response.data)
        guard existing.isEmpty else { return }

        _ = try await client.from("ConnectedLibraries")
            .insert(["library": name, "uuid": uid.uuidString])
            .execute()
    }
}


