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
}

// MARK: - User Images

extension ImageService {

    func isFilenameAvailable(_ name: String) async throws -> Bool {
        let userID = try await uid

        let response = try await client
            .from("custom_files")
            .select("id")
            .eq("user_uuid", value: userID)
            .eq("display_name", value: name)
            .limit(1)
            .execute()

        let rows = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String: Any]]
        return rows?.isEmpty ?? true
    }

    func fetchUserImages() async throws -> [CustomFile] {
        let userID = try await uid

        let response = try await client
            .from("custom_files")
            .select("user_uuid, display_name, file_url")
            .eq("user_uuid", value: userID)
            .execute()

        return try JSONDecoder().decode([CustomFile].self, from: response.data)
    }

    func upsertImage(imageData: Data, name: String) async throws {
        let userID = try await uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(timestamp).png"
        let path = "\(userID.uuidString)/images/\(filename)"

        // Validate availability
        if try await !isFilenameAvailable(name) {
            throw AppError.duplicateFile
        }

        // Upload file
        try await client.storage.from("user_data").upload(
            path: path,
            file: imageData,
            options: .init(cacheControl: "0", contentType: "image/png", upsert: true)
        )

        // Register in database
        let fileURL = try client.storage.from("user_data").getPublicURL(path: path).absoluteString

        _ = try await client
            .from("custom_files")
            .insert([
                ["user_uuid": userID.uuidString, "display_name": name, "file_url": fileURL]
            ])
            .execute()
    }
}

// MARK: - Library Images

extension ImageService {

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
        

        try await withThrowingTaskGroup(of: (String, [NamedURL]).self) { group in
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

        return result
    }
}
