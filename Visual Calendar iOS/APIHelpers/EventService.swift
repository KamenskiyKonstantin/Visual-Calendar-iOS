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
class EventService: ObservableObject {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchEvents() async throws -> [Event] {
        let uid = try await client.auth.user().id
        let data = try await client.storage.from("user_data").download(path: "\(uid.uuidString)/calendar.json")
        do{
            let calendar = try JSONDecoder().decode(CalendarJSON.self, from: data)
            return calendar.events.map({$0.toEvent()})
        }
        catch{
            print(error.localizedDescription)
        }
        return []
    }

    func upsertEvents(_ events: [Event]) async throws {
        let uid = try await client.auth.user().id.uuidString
        let payload = CalendarJSON(events: events.map { $0.toEventJSON() }, uid: uid)
        let jsonData = try JSONEncoder().encode(payload)

        try await client.storage.from("user_data").upload(
            path: "\(uid)/calendar.json",
            file: jsonData,
            options: FileOptions(cacheControl: "0", contentType: "application/json", upsert: true)
        )

    }
}
