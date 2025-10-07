//
//  CodableStructures.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//

//
// Naming Convention:
// - All Supabase/PostgREST models decode from `snake_case`.
// - All JSON file models use `camelCase` (for storage in buckets).
// DO NOT mix database and file formats in one model.
//

import Foundation

struct Preset: Codable, Hashable {
    var presetName: String = ""
    var selectedSymbol: String
    var backgroundColor: String
    var mainImageURL: String
    var sideImageURLs: [String]
}

struct EventJSON: Codable {
    let timeStart: [Int]
    let timeEnd: [Int]
    let systemImage: String
    let backgroundColor: String
    let textColor: String
    let mainImageURL: String
    let sideImageURLS: [String]
    let id: UUID
    let repetitionType: String
    
    enum CodingKeys: String, CodingKey {
        case timeStart = "time_start"
        case timeEnd = "time_end"
        case systemImage = "system_image"
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case mainImageURL = "main_image_url"
        case sideImageURLS = "side_image_urls"
        case id
        case repetitionType = "repetition_type"
    }
}

struct ImageMapping: Codable, Hashable {
    let eventID: UUID
    let mainImageSignedURL: URL
    let sideImageSignedURLs: [URL]
}


struct EventReactionRow: Codable, Hashable, Equatable {
    // THIS REPRESENTS HOW A SERVER SEES AN ENTRY FOR AN EVENT REACTION
    let eventID: UUID
    let timestamp: [Int]
    let reaction: String

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case timestamp = "time_start"
        case reaction
    }
    
    func timestampMatches(_ date: Date) -> Bool {
        return self.timestamp == date.toIntList()
    }
    
    var emoji: String {
        switch self.reaction
        {
            case "smiley": return "😊"
            case "thumbsUp": return "👍"
            case "thumbsDown": return "👎"
            case "upset": return "😡"
            default : return ""
        }
    }
    
}

protocol NamedURL: Sendable, Equatable {
    var display_name: String { get }
    var file_url: String { get }
}

struct LibraryInfo: Codable, Hashable {
    let library_uuid: UUID
    let system_name: String
    let localized_name: String
}

struct PublicImage: Codable, Hashable, Equatable, NamedURL {
    let library_uuid: UUID
    let display_name: String
    var file_url: String
}

struct CustomFile: Codable, Hashable, Equatable, NamedURL {
    let user_uuid: UUID
    let display_name: String
    var file_url: String
}
