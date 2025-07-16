//
//  CodableStructures.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 06.06.2025.
//

import Foundation

struct CalendarJSON: Codable {
    let events: [EventJSON]
    let uid: String
}

struct LibraryEntry: Codable {
    let library: String
}

struct Preset: Codable, Hashable {
    var selectedSymbol: String
    var backgroundColor: String
    var mainImageURL: String
    var sideImageURLs: [String]
}

struct LibraryJSON: Codable {
    let library: String
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
