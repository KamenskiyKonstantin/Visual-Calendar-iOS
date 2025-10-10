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

    // MARK: - Create
    func createPreset(_ preset: Preset) async throws {
        var presets = try await fetchUserOnlyPresets()
        guard !presets.contains(where: { $0.presetName == preset.presetName }) else {
            throw AppError.duplicateFile
        }
        presets.append(preset)
        try await saveUserPresets(presets)
        // print("[-SERVICES/PRESET] CREATED PRESET: \(preset.presetName)")
    }

    // MARK: - Read (all presets: official + user)
    func fetchPresets() async throws -> [Preset] {
        let folder = try await userFolder
        let path = "\(folder)/presets.json"

        // Fetch user presets
        print("[-SERVICES/PRESETS-] NOW FETCHING CUSTOM PRESETS")
        let userData = try await client.storage.from("user_data").download(path: path)
        let userPresets = try JSONDecoder().decode([Preset].self, from: userData)

        // Fetch official presets
        print("[-SERVICES/PRESETS-] NOW FETCHING OFFICIAL PRESETS")
        let officialData = try await client.storage.from("presets").download(path: "presets.json")
        let officialPresets = try JSONDecoder().decode([Preset].self, from: officialData)

        // Merge (user presets override official ones with same name)
        let merged = Dictionary(uniqueKeysWithValues: officialPresets.map { ($0.presetName, $0) })
            .merging(Dictionary(uniqueKeysWithValues: userPresets.map { ($0.presetName, $0) })) { _, user in user }

        let result = Array(merged.values)

        // print("[-SERVICES/PRESET] FETCHED PRESETS: \(result.map { $0.presetName })")

        return result
    }

    // MARK: - Read (user only)
    func fetchUserOnlyPresets() async throws -> [Preset] {
        let folder = try await userFolder
        let path = "\(folder)/presets.json"

        let data = try await client.storage.from("user_data").download(path: path)
        return try JSONDecoder().decode([Preset].self, from: data)
    }

    // MARK: - Update
    func updatePreset(_ preset: Preset) async throws {
        var presets = try await fetchUserOnlyPresets()
        guard let index = presets.firstIndex(where: { $0.presetName == preset.presetName }) else {
            try await createPreset(preset)
            return
        }
        presets[index] = preset
        try await saveUserPresets(presets)
        // print("[-SERVICES/PRESET] UPDATED PRESET: \(preset.presetName)")
    }

    // MARK: - Delete
    func deletePreset(named name: String) async throws {
        print("[-SERVICES/PRESETS-] NOW DELETING: \(name)")
        let presets = try await fetchUserOnlyPresets()
        print("[-SERVICES/PRESETS-] User presets to delete from: \(presets.compactMap({$0.presetName}))")
        let newPresets = presets.filter { $0.presetName != name }
        guard newPresets.count != presets.count else {
            throw AppError.notFound
        }
        try await saveUserPresets(newPresets)
        // print("[-SERVICES/PRESET] DELETED PRESET: \(name)")
    }

    // MARK: - Internal helper
    private func saveUserPresets(_ presets: [Preset]) async throws {
        let folder = try await userFolder
        let path = "\(folder)/presets.json"
        let data = try JSONEncoder().encode(presets)

        try await client.storage.from("user_data").upload(
            path: path,
            file: data,
            options: FileOptions(contentType: "application/json", upsert: true)
        )
        // print("[-SERVICES/PRESET] SAVED PRESETS to path: \(path)")
    }
}
