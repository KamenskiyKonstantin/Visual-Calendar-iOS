//
//  ImageService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//
import Foundation
import Supabase
import Combine

@MainActor
class ImageService: ObservableObject {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - User Images
    
    func isFilenameAvailable(_ name: String) async throws -> Bool {
        let uid = try await client.auth.user().id

        let response = try await client
            .from("custom_files")
            .select("id")  // Only need to know if any entry exists
            .eq("user_uuid", value: uid)
            .eq("display_name", value: name)
            .limit(1)
            .execute()

        let rows = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]]
        return (rows?.isEmpty ?? true)
    }

    func fetchUserImages() async throws -> [CustomFile] {
        let uid = try await client.auth.user().id

        let response = try await client
            .from("custom_files")
            .select("user_uuid, display_name, file_url")
            .eq("user_uuid", value: uid)
            .execute()

        return try JSONDecoder().decode([CustomFile].self, from: response.data)
    }

    func upsertImage(imageData: Data, name: String) async throws {
        let uid = try await client.auth.user().id
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(timestamp).png"
        let path = "\(uid.uuidString)/images/\(filename)"
        
        // check for availabitliy
        if try await !isFilenameAvailable(name) {
            throw APIError.duplicateFile
        }
        // upload
        try await client.storage.from("user_data").upload(
            path: path,
            file: imageData,
            options: .init(cacheControl: "0", contentType: "image/png", upsert: true)
        )
        // read URL

        let fileURL = try client.storage.from("user_data").getPublicURL(path: path).absoluteString
        
        // insert to index
        _ = try await client
            .from("custom_files")
            .insert([
                ["user_uuid": uid.uuidString, "display_name": name, "file_url": fileURL]
            ])
            .execute()
    }

    // MARK: - Library Images

    func fetchLibraryImages(_ library: LibraryInfo) async throws -> [PublicImage] {
        let response = try await client
            .from("public_images")
            .select("library_uuid, display_name, file_url")
            .eq("library_uuid", value: library.library_uuid.uuidString)
            .execute()

        return try JSONDecoder().decode([PublicImage].self, from: response.data)
    }

    func fetchAllImageMappings(libraries: [LibraryInfo]) async throws -> [String: [NamedURL]] {
        var result: [String: [NamedURL]] = [:]

        for library in libraries {
            
            result[library.localized_name] = try await fetchLibraryImages(library)
        }

        result["user"] = try await fetchUserImages()
        return result
    }
}
