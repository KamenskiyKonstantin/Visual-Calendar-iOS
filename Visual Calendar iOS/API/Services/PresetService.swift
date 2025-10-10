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
final class PresetService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Helpers
    private var userUUID: String {
        get async throws {
            try await client.auth.user().id.uuidString.lowercased()
        }
    }

    // MARK: - Create
    func createPreset(_ preset: Preset) async throws {
        let userId = try await userUUID

        // Check for duplicate name
        let existing = try await decodePresets(from:
            client
            .from("custom_presets")
            .select("preset_name, selected_symbol, background_color, main_image_url, side_image_urls")
            .eq("user_uuid", value: userId)
            .eq("preset_name", value: preset.presetName)
            .execute()
            .data
        )
        

        guard existing.isEmpty else {
            throw AppError.duplicateFile
        }
        

        // Insert new preset
        try await client
            .from("custom_presets")
            .insert([
                "user_uuid": userId,
                "preset_name": preset.presetName,
                "selected_symbol": preset.selectedSymbol,
                "background_color": preset.backgroundColor,
                "main_image_url": preset.mainImageURL,
                "side_image_urls": preset.sideImageURLs.asPostgresArrayString()
            ])
            .execute()

        print("[-SERVICES/PRESET] CREATED PRESET: \(preset.presetName)")
    }

    // MARK: - Read (all presets: official + user)
    func fetchPresets() async throws -> [Preset] {
        let userId = try await userUUID

        // Fetch user presets
        print("[-SERVICES/PRESETS-] NOW FETCHING CUSTOM PRESETS")
        let userData = try await client
            .from("custom_presets")
            .select("preset_name, selected_symbol, background_color, main_image_url, side_image_urls")
            .eq("user_uuid", value: userId)
            .execute()
        let userPresets = try decodePresets(from: userData.data)

        // Fetch official presets
        print("[-SERVICES/PRESETS-] NOW FETCHING OFFICIAL PRESETS")
        let officialData = try await client
            .from("public_presets")
            .select("preset_name, selected_symbol, background_color, main_image_url, side_image_urls")
            .execute()
        let officialPresets = try decodePresets(from: officialData.data)

        // Merge (user presets override official ones with same name)
        let merged = Dictionary(uniqueKeysWithValues: officialPresets.map { ($0.presetName, $0) })
            .merging(Dictionary(uniqueKeysWithValues: userPresets.map { ($0.presetName, $0) })) { _, user in user }

        let result = Array(merged.values)

        print("[-SERVICES/PRESET] FETCHED PRESETS: \(result.map { $0.presetName })")
        return result
    }

    // MARK: - Read (user only)
    func fetchUserOnlyPresets() async throws -> [Preset] {
        let userId = try await userUUID

        let response = try await client
            .from("custom_presets")
            .select()
            .eq("user_uuid", value: userId)
            .execute()

        return try decodePresets(from: response.data)
    }

    // MARK: - Update
    func updatePreset(_ preset: Preset) async throws {
        let userId = try await userUUID

        let result = try await client
            .from("custom_presets")
            .update([
                "selected_symbol": preset.selectedSymbol,
                "background_color": preset.backgroundColor,
                "main_image_url": preset.mainImageURL,
                "side_image_urls": preset.sideImageURLs.asPostgresArrayString()
            ])
            .eq("user_uuid", value: userId)
            .eq("preset_name", value: preset.presetName)
            .execute()

        if result.status == 204 {
            print("[-SERVICES/PRESET] UPDATED PRESET: \(preset.presetName)")
        } else {
            print("[-SERVICES/PRESET] UPDATE INSERT FALLBACK for PRESET: \(preset.presetName)")
            try await createPreset(preset)
        }
    }

    // MARK: - Delete
    func deletePreset(named name: String) async throws {
        print("[-SERVICES/PRESETS-] NOW DELETING: \(name)")

        let userId = try await userUUID

        let allPresets = try await fetchUserOnlyPresets()
        print("[-SERVICES/PRESETS-] User presets to delete from: \(allPresets.map { $0.presetName })")

        let result = try await client
            .from("custom_presets")
            .delete()
            .eq("user_uuid", value: userId)
            .eq("preset_name", value: name)
            .execute()

        if result.status == 204 {
            print("[-SERVICES/PRESET] DELETED PRESET: \(name)")
        } else {
            throw AppError.notFound
        }
    }

    // MARK: - Decode helper
    private func decodePresets(from data: Data?) throws -> [Preset] {
        guard let data, !data.isEmpty else {
            print("[-SERVICES/PRESETS-] No data returned from Supabase, returning empty preset array.")
            return []
        }
        
        do {
            return try JSONDecoder().decode([Preset].self, from: data)
        } catch {
            print("[-SERVICES/PRESETS-] Decoding error: \(error.localizedDescription)")
            return []
        }
    }
}
