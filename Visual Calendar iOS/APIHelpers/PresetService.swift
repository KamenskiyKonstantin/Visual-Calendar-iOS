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

    func fetchPresets() async throws -> [String: Preset] {
        let uid = try await client.auth.user().id
        let path = "\(uid.uuidString)/presets.json"

        var userPresets: [String: Preset] = [:]
        do {
            let data = try await client.storage.from("user_data").download(path: path)
            userPresets = try JSONDecoder().decode([String: Preset].self, from: data)
        } catch {
            print("Error decoding user presets: \(error)")
        }

        let officialItems = try await client.storage.from("presets").list()
        var officialPresets: [String: Preset] = [:]
        for item in officialItems where item.name.hasSuffix(".json") {
            do {
                let data = try await client.storage.from("presets").download(path: item.name)
                let decoded = try JSONDecoder().decode([String: Preset].self, from: data)
                decoded.forEach { officialPresets[$0.key] = $0.value }
            } catch {
                print("Failed to decode official preset: \(item.name), error: \(error)")
            }
        }

        print("Loaded \(officialPresets.count) official and \(userPresets.count) user presets.")
        return officialPresets.merging(userPresets) { _, user in user }
    }

    func uploadUserPreset(title: String, preset: Preset, force: Bool = true) async throws -> Bool {
        let uid = try await client.auth.user().id
        let path = "\(uid.uuidString)/presets.json"

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
        let uid = try await client.auth.user().id
        let path = "\(uid.uuidString)/presets.json"

        do {
            let data = try await client.storage.from("user_data").download(path: path)
            return try JSONDecoder().decode([String: Preset].self, from: data)
        } catch {
            print("Failed to fetch user presets: \(error)")
            return [:]
        }
    }
}
