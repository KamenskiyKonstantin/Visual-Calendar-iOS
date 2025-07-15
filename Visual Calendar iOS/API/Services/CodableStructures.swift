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
    
    func toString() -> String {
        return "Library with name \(library)"
    }
}

struct Preset: Codable, Hashable {
    var selectedSymbol: String
    var backgroundColor: String
    var mainImageURL: String
    var sideImageURLs: [String]
}

struct NamedPreset: Decodable {
    let name: String
    let preset: Preset
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

    func toEvent() -> Event {
        return Event(
            systemImage: systemImage,
            dateTimeStart: Date.from(day: timeStart[0], month: timeStart[1], year: timeStart[2], hour: timeStart[3], minute: timeStart[4]),
            dateTimeEnd: Date.from(day: timeEnd[0], month: timeEnd[1], year: timeEnd[2], hour: timeEnd[3], minute: timeEnd[4]),
            mainImageURL: mainImageURL,
            sideImagesURL: sideImageURLS,
            id: id,
            bgcolor: backgroundColor,
            textcolor: textColor,
            repetitionType: repetitionType,
            reactionString: reactionString
            
        )
    }
}
