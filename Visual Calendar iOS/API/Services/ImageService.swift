//
//  ImageService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//
import Foundation
import Supabase
import SwiftyJSON
import Combine

@MainActor
class ImageService: ObservableObject {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }
}

extension ImageService {
    struct CustomFile: Decodable {
        let id: UUID
        let name: String
        let file_url: String
    }

    struct PublicImage: Decodable {
        let id: UUID
        let name: String
        let file_url: String
        let library: String
    }
}

extension ImageService {
    func fetchUserImages() async throws -> [String: String] {
        let uid = try await client.auth.user().id

        let response = try await client
            .from("custom_files")
            .select()
            .eq("user_id", value: uid)
            .execute()

        let files = try JSONDecoder().decode([CustomFile].self, from: response.data)
        return Dictionary(uniqueKeysWithValues: files.map { ($0.name, $0.file_url) })
    }

    func upsertImage(imageData: Data, name: String) async throws {
        let uid = try await client.auth.user().id
        let timestamp = Int(Date().timeIntervalSince1970)
        let safeFilename = "\(timestamp).png"
        let path = "\(uid.uuidString)/images/\(safeFilename)"

        try await client.storage.from("user_data").upload(
            path: path,
            file: imageData,
            options: FileOptions(cacheControl: "0", contentType: "image/png", upsert: true)
        )

        let fileURL = try client.storage.from("user_data").getPublicURL(path: path).absoluteString

        _ = try await client
            .from("custom_files")
            .upsert(
                [["user_id": uid.uuidString, "name": name, "file_url": fileURL]],
                onConflict: "user_id,name"
            )
            .execute()
    }
}

extension ImageService {
    func fetchLibraryImages(library: String) async throws -> [String: String] {
        let response = try await client
            .from("public_images")
            .select()
            .eq("library", value: library)
            .execute()

        let images = try JSONDecoder().decode([PublicImage].self, from: response.data)
        return Dictionary(uniqueKeysWithValues: images.map { ($0.name, $0.file_url) })
    }

    func fetchAllImageMappings(libraries: [String]) async throws -> [String: [String: String]] {
        var result: [String: [String: String]] = [:]

        for library in libraries {
            result[library] = try await fetchLibraryImages(library: library)
        }

        result["user"] = try await fetchUserImages()
        return result
    }
}
