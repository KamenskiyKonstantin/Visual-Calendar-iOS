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
        let folder = uid.uuidString.lowercased()
        
        // print("[-SERVICES/EVENT] NOW FETCHING EVENTS FOR USER WITH UID: \(folder)")
        
        let path = "\(folder)/calendar.json"
        
        let data = try await client.storage.from("user_data").download(path: path)
        let calendar = try JSONDecoder().decode(CalendarJSON.self, from: data)
        return calendar.events.map { $0.toEvent() }
    }

    func upsertEvents(_ events: [Event]) async throws {
        let uid = try await client.auth.user().id
        let folder = uid.uuidString.lowercased()
        
        // print("[-SERVICES/EVENT] NOW UPSERTING EVENTS FOR USER WITH UID: \(folder)")
        
        let path = "\(folder)/calendar.json"
        let calendarPayload = CalendarJSON(events: events.map { $0.toEventJSON() }, uid: folder)
        
        // print("[-SERVICES/EVENT] UPSERTING: \(calendarPayload)")
        
        let data = try JSONEncoder().encode(calendarPayload)
        
        try await client.storage.from("user_data").upload(
            path: path,
            file: data,
            options: .init(cacheControl: "0", contentType: "application/json", upsert: true)
        )
    }
}
