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
        try await client.storage
            .from(bucket)
            .createSignedURL(path: path, expiresIn: seconds)
    }
}

// MARK: - User Images (CRUD)

extension ImageService {

    // MARK: Create
    func createImage(imageData: Data, displayName: String) async throws {
        try await upsertImage(imageData: imageData, displayName: displayName, force: false)
    }

    // MARK: Read
    func fetchUserImages() async throws -> [CustomFile] {
        let userID = try await uid
        let folder = userID.uuidString.lowercased()

        let response = try await client
            .from("custom_files")
            .select("user_uuid, display_name, file_url")
            .eq("user_uuid", value: folder)
            .execute()

        var files = try JSONDecoder().decode([CustomFile].self, from: response.data)

        // Attach signed URLs
        for i in files.indices {
            let path = files[i].file_url // stored as path
            let signed = try await signedURL(for: path, from: "user_data")
            files[i].file_url = signed.absoluteString
        }

        // print("[-SERVICES/IMAGE] FETCHED IMAGES: \(files.map { $0.display_name })")

        return files
    }
    
    func resolveSignedURLs(for events: [Event]) async throws -> [ImageMapping] {
        print("[-SERVICES/IMAGE-] FETCHING URLS FOR A SERIES OF EVENTS")
        
        var result: [ImageMapping] = []
        
        for event in events {
            let mainImageURL = event.mainImageURL
            
            var mainImageSignedURL: URL
            
            print("[-SERVICES/IMAGE-] NOW LOADING URL FOR: \(mainImageURL)")
            
            if mainImageURL.contains("_library") {
                mainImageSignedURL = try await client.storage.from("publiclibraries").createSignedURL(path: mainImageURL, expiresIn: 3600)
            }
            else{
                mainImageSignedURL = try await client.storage.from("user_data").createSignedURL(path: mainImageURL, expiresIn: 3600)
            }
            
            var sideImagesURLs: [URL] = []
            
            for current in event.sideImagesURL{
                print("[-SERVICES/IMAGE-] NOW LOADING URL FOR: \(current)")
                if current.contains("_library") {
                    sideImagesURLs.append(try await client.storage.from("publiclibraries").createSignedURL(path: current, expiresIn: 3600))
                }
                else{
                    sideImagesURLs.append(try await client.storage.from("user_data").createSignedURL(path: current, expiresIn: 3600))
                }
            }
            
            result.append(ImageMapping(eventID: event.id, mainImageSignedURL: mainImageSignedURL, sideImageSignedURLs: sideImagesURLs))
            
        }
        
        return result
    }

    // MARK: Update
    func updateImage(imageData: Data, displayName: String) async throws {
        try await upsertImage(imageData: imageData, displayName: displayName, force: true)
        // print("[-SERVICES/IMAGE] UPDATED IMAGE: \(displayName)")
    }

    // MARK: Delete
    func deleteImage(displayName: String) async throws {
        let userID = try await uid
        let folder = userID.uuidString.lowercased()

        // Query DB row
        let response = try await client
            .from("custom_files")
            .select("file_url")
            .eq("user_uuid", value: folder)
            .eq("display_name", value: displayName)
            .single()
            .execute()

        guard let row = try JSONSerialization.jsonObject(with: response.data) as? [String: Any],
              let path = row["file_url"] as? String else {
            throw AppError.notFound
        }

        // Delete file from storage
        _ = try await client.storage.from("user_data").remove(paths: [path])

        // Delete DB row
        _ = try await client
            .from("custom_files")
            .delete()
            .eq("user_uuid", value: folder)
            .eq("display_name", value: displayName)
            .execute()

        // print("[-SERVICES/IMAGE] DELETED IMAGE: \(displayName)")
    }

    // MARK: Internal Upsert (used by create/update)
    private func upsertImage(imageData: Data, displayName: String, force: Bool) async throws {
        let userID = try await uid
        let folder = userID.uuidString.lowercased()
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = "\(timestamp).png"
        let path = "\(folder)/images/\(filename)"

        let isAvailable = try await isFilenameAvailable(displayName)

        switch (isAvailable, force) {
        case (false, false):
            throw AppError.duplicateFile

        case (false, true):
            // overwrite DB row
            try await client.storage.from("user_data").upload(
                path: path,
                file: imageData,
                options: .init(cacheControl: "0", contentType: "image/png", upsert: true)
            )

            _ = try await client
                .from("custom_files")
                .update(["file_url": path])
                .eq("user_uuid", value: folder)
                .eq("display_name", value: displayName)
                .execute()

        case (true, _):
            // insert new row
            try await client.storage.from("user_data").upload(
                path: path,
                file: imageData,
                options: .init(cacheControl: "0", contentType: "image/png", upsert: true)
            )

            _ = try await client
                .from("custom_files")
                .insert([
                    ["user_uuid": folder, "display_name": displayName, "file_url": path]
                ])
                .execute()
        }
    }
    

    // MARK: Availability check
    private func isFilenameAvailable(_ name: String) async throws -> Bool {
        let userID = try await uid
        let folder = userID.uuidString.lowercased()

        let response = try await client
            .from("custom_files")
            .select("id")
            .eq("user_uuid", value: folder)
            .eq("display_name", value: name)
            .limit(1)
            .execute()

        let rows = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]]
        return rows?.isEmpty ?? true
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
