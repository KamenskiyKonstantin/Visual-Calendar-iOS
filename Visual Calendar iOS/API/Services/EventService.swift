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
        var events = try await fetchEvents()
        events.append(event)
        try await saveEvents(events)

        // Debug
        // print("[-SERVICES/EVENT] CREATED EVENT: \(event)")
    }

    // MARK: - Read
    func fetchEvents() async throws -> [Event] {
        let uid = try await client.auth.user().id
        let folder = uid.uuidString.lowercased()
        let path = "\(folder)/calendar.json"

        // Debug
        // print("[-SERVICES/EVENT] FETCHING EVENTS for user folder: \(folder), path: \(path)")

        let data = try await client.storage
            .from("user_data")
            .download(path: path)

        // Debug
        // print("[-SERVICES/EVENT] RAW JSON: \(String(data: data, encoding: .utf8) ?? "nil")")

        let calendar = try JSONDecoder().decode(CalendarJSON.self, from: data)
        let events = calendar.events.map { $0.toEvent() }

        // Debug
        // print("[-SERVICES/EVENT] DECODED EVENTS: \(events)")

        return events
    }

    // MARK: - Update
    func updateEvent(_ newEvent: Event) async throws {
        var events = try await fetchEvents()
        guard let index = events.firstIndex(where: { $0.id == newEvent.id }) else {
            throw AppError.notFound
        }
        events[index] = newEvent
        try await saveEvents(events)

        // Debug
        // print("[-SERVICES/EVENT] UPDATED EVENT: \(event)")
    }

    // MARK: - Delete
    func deleteEvent(_ id: UUID) async throws {
        var events = try await fetchEvents()
        events.removeAll { $0.id == id }
        try await saveEvents(events)

        // Debug
        // print("[-SERVICES/EVENT] DELETED EVENT WITH ID: \(id)")
    }

    // MARK: - Internal helper
    private func saveEvents(_ events: [Event]) async throws {
        let uid = try await client.auth.user().id
        let folder = uid.uuidString.lowercased()
        let path = "\(folder)/calendar.json"

        let calendarPayload = CalendarJSON(
            events: events.map { $0.toEventJSON() },
            uid: folder
        )

        let data = try JSONEncoder().encode(calendarPayload)

        // Debug
        // print("[-SERVICES/EVENT] SAVING EVENTS to path: \(path)")
        // print("[-SERVICES/EVENT] PAYLOAD: \(String(data: data, encoding: .utf8) ?? "nil")")

        try await client.storage
            .from("user_data")
            .upload(
                path: path,
                file: data,
                options: .init(
                    cacheControl: "0",
                    contentType: "application/json",
                    upsert: true
                )
            )

        // Debug
        // print("[-SERVICES/EVENT] SAVE SUCCESSFUL")
    }
}
