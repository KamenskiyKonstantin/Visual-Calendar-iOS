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

struct CalendarJSON: Codable {
    let events: [EventJSON]
    let uid: String
}

struct Preset: Codable, Hashable {
    var selectedSymbol: String
    var backgroundColor: String
    var mainImageURL: String
    var sideImageURLs: [String]
}

struct EventJSON: Codable {
    let timeStart, timeEnd: [Int]
    let systemImage: String
    let backgroundColor: String
    let textColor: String
    let mainImageURL: String
    let sideImageURLS: [String]
    let id: UUID
    let repetitionType: String
    let reactionString: String

    
}

protocol NamedURL: Sendable {
    var display_name: String { get }
    var file_url: String { get }
}

struct LibraryInfo: Codable, Hashable {
    let library_uuid: UUID
    let system_name: String
    let localized_name: String
}

struct PublicImage: Codable, Hashable, NamedURL {
    let library_uuid: UUID
    let display_name: String
    let file_url: String
}

struct CustomFile: Codable, Hashable, NamedURL {
    let user_uuid: UUID
    let display_name: String
    let file_url: String
}
