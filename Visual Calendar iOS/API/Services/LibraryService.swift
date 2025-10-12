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

    // Fetch list of libraries connected to the current user
    func fetchConnectedLibraries() async throws -> [LibraryInfo] {
        
        struct ConnectedLibrary: Decodable {
            let library_uuid: UUID
            let library_index: LibraryIndex
            
            public var library: LibraryInfo {
                get {LibraryInfo(library_uuid: library_uuid, system_name: library_index.system_name, localized_name: library_index.localized_name)}
            }
        }

        struct LibraryIndex: Decodable {
            let system_name: String
            let localized_name: String
        }
        
        let uid = try await client.auth.user().id
        
        let response = try await client
            .from("connected_libraries")
            .select("library_uuid, library_index(system_name, localized_name)")
            .eq("user_uuid", value: uid)
            .execute()

        return try JSONDecoder().decode([ConnectedLibrary].self, from: response.data).compactMap({$0.library})
    }

    // Add a library to user's connected ones using system_name and [LibraryInfo]
    func addLibrary(systemName: String) async throws {
        print("[-SERVICES/LIBRARY-] ADDING LIBRARY: \(systemName)")
        let libraries = try await fetchAllLibraries()
        
        guard let info = libraries.first(where: { $0.system_name == systemName }) else {
            throw AppError.libraryNotFound(systemName)
        }
        print("[-SERVICES/LIBRARY-] LIBRARY LOCATED, UUID: \(info.library_uuid.uuidString.lowercased())")
        let uid = try await client.auth.user().id.uuidString.lowercased()
        // inserts the library to user by looked up UUID and pushes system_name silently.
        _ = try await client
            .from("connected_libraries")
            .insert([
                "user_uuid": uid,
                "library_uuid": info.library_uuid.uuidString.lowercased(),
            ])
            .execute()
    }
    
    func removeLibrary(systemName: String) async throws {
        struct LibraryUUID: Decodable {
            let library_uuid: UUID
        }
        
        let uid = try await client.auth.user().id.uuidString.lowercased()

        let targetResponse = try await client
            .from("library_index")
            .select("library_uuid")
            .eq("system_name", value: systemName)
            .limit(1)
            .single()
            .execute()

        let target: LibraryUUID = try JSONDecoder().decode(LibraryUUID.self, from: targetResponse.data)
        let libraryUUID = target.library_uuid

        
        _ = try await client
            .from("connected_libraries")
                .delete()
                .eq("user_uuid", value: uid)
                .eq("library_uuid", value: libraryUUID)
                .execute()
        
    }
}


