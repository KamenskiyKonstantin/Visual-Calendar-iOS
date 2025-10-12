//
//  ReactionService.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 26.09.2025.
//

import Foundation
import Supabase


@MainActor
final class ReactionService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    // Fetch all reactions for a list of events
    func fetchAllReactions(for events: [Event]) async throws -> [UUID: [EventReactionRow]] {
        print("[-SERVICES/REACTION] FETCHING REACTIONS FOR MULTIPLE EVENTS...")

        guard !events.isEmpty else { return [:] }

        let eventIDs = events.map { $0.id.uuidString.lowercased() }

        let response = try await client
            .from("event_reactions")
            .select()
            .in("event_id", values: eventIDs)
            .execute()

        let allReactions = try JSONDecoder().decode([EventReactionRow].self, from: response.data)

        print("[-SERVICES/REACTION] FETCHED REACTIONS COUNT: \(allReactions.count)")

        return Dictionary(grouping: allReactions, by: { $0.eventID })
    }

    // Set or update a reaction for a specific event and datetime
    func setReaction(for eventID: UUID, timeStart: [Int], reaction: EventReaction) async throws {
        
        let startArray = "{" + timeStart.map(String.init).joined(separator: ",") + "}"
        print("[-SERVICES/REACTION] SETTING REACTION for \(eventID) @ \(timeStart): \(reaction)")

        let reactionData: [String: String] = [
            "event_id": eventID.uuidString.lowercased(),
            "time_start": startArray,
            "reaction": reaction.rawValue,
        ]

        try await client
            .from("event_reactions")
            .upsert(reactionData, onConflict: "event_id,time_start")
            .execute()

        print("[-SERVICES/REACTION] REACTION SET")
    }
}
