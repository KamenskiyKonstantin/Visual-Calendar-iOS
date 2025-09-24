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

    /// Current user's UUID
    private var uid: UUID {
        get async throws {
            try await client.auth.user().id
        }
    }

    /// Generate a signed URL for a given path
    private func signedURL(for path: String, from bucket: String, expiresIn seconds: Int = 6 * 3600) async throws -> URL {
        return try await client.storage
            .from(bucket)
            .createSignedURL(path: path, expiresIn: seconds)
    }
}

// MARK: - User Images

extension ImageService {

    func isFilenameAvailable(_ name: String) async throws -> Bool {
        let userID = try await uid
        let userFolder = userID.uuidString.lowercased()

        let response = try await client
            .from("custom_files")
            .select("id")
            .eq("user_uuid", value: userFolder)
            .eq("display_name", value: name)
            .limit(1)
            .execute()

        let rows = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]]
        return rows?.isEmpty ?? true
    }

    func fetchUserImages() async throws -> [CustomFile] {
        let userID = try await uid
        let userFolder = userID.uuidString.lowercased()

        let response = try await client
            .from("custom_files")
            .select("user_uuid, display_name, file_url") // file_url stores the PATH
            .eq("user_uuid", value: userFolder)
            .execute()

        var files = try JSONDecoder().decode([CustomFile].self, from: response.data)

        // Resolve signed URLs for SwiftUI
        for i in files.indices {
            let path = files[i].file_url // treat file_url as path
            let signed = try await signedURL(for: path, from: "user_data")
            files[i].file_url = signed.absoluteString
        }

        return files
    }
    
    func deleteImage(name: String) async throws {
        let userID = try await uid
        let userFolder = userID.uuidString.lowercased()

        // Look up file path
        let response = try await client
            .from("custom_files")
            .select("file_url")
            .eq("user_uuid", value: userFolder)
            .eq("display_name", value: name)
            .single()
            .execute()

        let row = try JSONSerialization.jsonObject(with: response.data) as! [String: Any]
        if let path = row["file_url"] as? String {
            // Delete file from storage
            _ = try await client.storage.from("user_data").remove(paths: [path])
        }

        // Delete DB row
        _ = try await client
            .from("custom_files")
            .delete()
            .eq("user_uuid", value: userFolder)
            .eq("display_name", value: name)
            .execute()
    }

    func upsertImage(imageData: Data, name: String, force: Bool = false) async throws {
        let userID = try await uid
        let userFolder = userID.uuidString.lowercased()
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(timestamp).png"
        let path = "\(userFolder)/images/\(filename)"

        // Cache the availability check
        let isAvailable = try await isFilenameAvailable(name)

        switch (isAvailable, force) {
        case (false, false):
            // Case 1: duplicate exists, no force
            throw AppError.duplicateFile

        case (false, true):
            // Case 2: duplicate exists, force enabled → overwrite DB row
            try await client.storage.from("user_data").upload(
                path: path,
                file: imageData,
                options: .init(cacheControl: "0", contentType: "image/png", upsert: true)
            )

            _ = try await client
                .from("custom_files")
                .update(["file_url": path])
                .eq("user_uuid", value: userFolder)
                .eq("display_name", value: name)
                .execute()

        case (true, _):
            // Case 3: available → normal insert
            try await client.storage.from("user_data").upload(
                path: path,
                file: imageData,
                options: .init(cacheControl: "0", contentType: "image/png", upsert: true)
            )

            _ = try await client
                .from("custom_files")
                .insert([
                    ["user_uuid": userFolder, "display_name": name, "file_url": path]
                ])
                .execute()
        }
    }
}

// MARK: - Library Images

extension ImageService {

    func fetchLibraryImages(_ library: LibraryInfo) async throws -> [PublicImage] {
        let response = try await client
            .from("public_images")
            .select("library_uuid, display_name, file_url") // file_url stores PATH
            .eq("library_uuid", value: library.library_uuid.uuidString.lowercased())
            .execute()

        var images = try JSONDecoder().decode([PublicImage].self, from: response.data)

        // Resolve signed URLs
        for i in images.indices {
            let path = images[i].file_url // treat file_url as path
            let signed = try await signedURL(for: path, from: "publiclibraries")
            images[i].file_url = signed.absoluteString
        }

        return images
    }

    func fetchAllImageMappings(libraries: [LibraryInfo]) async throws -> [String: [any NamedURL]] {
        var result: [String: [any NamedURL]] = [:]

        try await withThrowingTaskGroup(of: (String, [any NamedURL]).self) { group in
            for library in libraries {
                group.addTask {
                    let images = try await self.fetchLibraryImages(library)
                    return (library.localized_name, images)
                }
            }

            group.addTask {
                let userImages = try await self.fetchUserImages()
                return ("user", userImages)
            }

            for try await (label, images) in group {
                result[label] = images
            }
        }

        return result.filter {!$0.value.isEmpty}
    }
}
