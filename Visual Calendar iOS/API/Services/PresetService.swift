//
//  PresetService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//
import Foundation
import Supabase
import Combine

@MainActor
class PresetService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    private var userFolder: String {
        get async throws {
            try await client.auth.user().id.uuidString.lowercased()
        }
    }

    func fetchPresets() async throws -> [String: Preset] {
        let folder = try await userFolder
        let path = "\(folder)/presets.json"

        // Fetch user presets
        let userData = try await client.storage.from("user_data").download(path: path)
        print(String(data: userData, encoding: .utf8) ?? "No user data")
        let userPresets = try JSONDecoder().decode([String: Preset].self, from: userData)

        // Fetch official presets (from a single file)
        let officialData = try await client.storage.from("presets").download(path: "presets.json")
        print(String(data: officialData, encoding: .utf8) ?? "No official data")
        let officialPresets = try JSONDecoder().decode([String: Preset].self, from: officialData)

        // Merge user presets (override if keys overlap)
        return officialPresets.merging(userPresets) { _, user in user }
    }

    func uploadUserPreset(title: String, preset: Preset, force: Bool = true) async throws -> Bool {
        let folder = try await userFolder
        let path = "\(folder)/presets.json"

        // Load existing presets
        var presets = try await fetchUserOnlyPresets()

        if presets[title] != nil && !force {
            return false
        }

        presets[title] = preset
        let data = try JSONEncoder().encode(presets)

        try await client.storage.from("user_data").upload(
            path: path,
            file: data,
            options: FileOptions(contentType: "application/json", upsert: true)
        )
        return true
    }

    func fetchUserOnlyPresets() async throws -> [String: Preset] {
        let folder = try await userFolder
        let path = "\(folder)/presets.json"

        let data = try await client.storage.from("user_data").download(path: path)
        return try JSONDecoder().decode([String: Preset].self, from: data)
    }
}
