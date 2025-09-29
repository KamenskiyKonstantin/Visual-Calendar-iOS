//
//  EventService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//
import Foundation
import Supabase
import Combine

@MainActor
class EventService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - Create
    func createEvent(_ event: Event) async throws {
        print("[-SERVICES/EVENT] CREATING EVENT: \(event)")

        let uid = try await client.auth.user().id.uuidString.lowercased()

        let startArray = "{" + event.dateTimeStart.toIntList().map(String.init).joined(separator: ",") + "}"
        let endArray = "{" + event.dateTimeEnd.toIntList().map(String.init).joined(separator: ",") + "}"
        let sideImageArray = "{" + event.sideImagesURL.map { "\"\($0)\"" }.joined(separator: ",") + "}"

        let insertResult = try await client
            .from("events")
            .insert([
                "id": event.id.uuidString.lowercased(),
                "user_uuid": uid,
                "time_start": startArray,
                "time_end": endArray,
                "system_image": event.systemImage,
                "background_color": event.backgroundColor,
                "text_color": event.textColor,
                "main_image_url": event.mainImageURL,
                "side_image_urls": sideImageArray,
                "repetition_type": event.repetitionType.displayName
            ])
            .execute()

        print("[-SERVICES/EVENT] CREATED EVENT: \(event)")
    }

    // MARK: - Read
    func fetchEvents() async throws -> [Event] {
        print("[-SERVICES/EVENT] FETCHING EVENTS...")

        let uid = try await client.auth.user().id.uuidString.lowercased()

        let response = try await client
            .from("events")
            .select()
            .eq("user_uuid", value: uid)
            .execute()

        let data = response.data
        let events = try JSONDecoder().decode([EventJSON].self, from: data).compactMap { $0.toEvent() }

        print("[-SERVICES/EVENT] DECODED EVENTS: \(events)")
        return events
    }

    // MARK: - Update
    func updateEvent(_ newEvent: Event) async throws {
        print("[-SERVICES/EVENT] UPDATING EVENT: \(newEvent)")

        let startArray = "{" + newEvent.dateTimeStart.toIntList().map(String.init).joined(separator: ",") + "}"
        let endArray = "{" + newEvent.dateTimeEnd.toIntList().map(String.init).joined(separator: ",") + "}"
        let sideImageArray = "{" + newEvent.sideImagesURL.map { "\"\($0)\"" }.joined(separator: ",") + "}"

        try await client
            .from("events")
            .update([
                "time_start": startArray,
                "time_end": endArray,
                "system_image": newEvent.systemImage,
                "background_color": newEvent.backgroundColor,
                "text_color": newEvent.textColor,
                "main_image_url": newEvent.mainImageURL,
                "side_image_urls": sideImageArray,
                "repetition_type": newEvent.repetitionType.displayName
            ])
            .eq("id", value: newEvent.id.uuidString.lowercased())
            .execute()

        print("[-SERVICES/EVENT] UPDATED EVENT: \(newEvent)")
    }

    // MARK: - Delete
    func deleteEvent(_ id: UUID) async throws {
        print("[-SERVICES/EVENT] DELETING EVENT WITH ID: \(id)")

        try await client
            .from("events")
            .delete()
            .eq("id", value: id.uuidString.lowercased())
            .execute()

        print("[-SERVICES/EVENT] DELETED EVENT WITH ID: \(id)")
    }
}
