//
//  Event.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import Foundation
import SwiftUI

// Emoji based reaction system
enum EventReaction: CaseIterable{
    case none
    case smiley
    case thumbsUp
    case thumbsDown
    case upset
    
    var emoji: String {
        switch self {
        case .none: return ""
        case .smiley: return "😊"
        case .thumbsUp: return "👍"
        case .thumbsDown: return "👎"
        case .upset: return "😡"
        }
    }
    
    var rawValue: String {
        switch self {
        case .none: return "none"
        case .smiley: return "smiley"
        case .thumbsUp: return "thumbsUp"
        case .thumbsDown: return "thumbsDown"
        case .upset: return "upset"
        }
    }
}

enum EventRepetitionType{
    case daily
    case weekly
    case monthly
    case yearly
    case everyOtherDay
    case everyOtherWeek
    case everyOtherMonth
    case once
    case nonWeekends
    case weekends
    
    var displayName: String {
        switch self {
        case .daily: return "daily"
        case .weekly: return "weekly"
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        case .everyOtherDay: return "everyOtherDay"
        case .everyOtherWeek: return "everyOtherWeek"
        case .everyOtherMonth: return "everyOtherMonth"
        case .once: return "once"
        case .nonWeekends: return "weekdays"
        case .weekends: return "weekends"
        }
    }
    static var allValues: [EventRepetitionType] {
        return [.daily, .weekly, .monthly, .yearly,
                .everyOtherDay, .everyOtherWeek, .everyOtherMonth,
                .once, .nonWeekends, .weekends]
    }

}



func repetitionStringToEnum(_ repetitionString: String) -> EventRepetitionType {
    switch repetitionString {
    case "daily":
        return .daily
    case "weekly":
        return .weekly
    case "monthly":
        return .monthly
    case "yearly":
        return .yearly
    case "everyOtherDay":
        return .everyOtherDay
    case "everyOtherWeek":
        return .everyOtherWeek
    case "everyOtherMonth":
        return .everyOtherMonth
    case "once":
        return .once
    case "weekdays":
        return .nonWeekends
    case "weekends":
        return .weekends
    default:
        return .once
    }
}

func reactionStringToEnum(_ emojiString: String) -> EventReaction {
    switch emojiString {
        case "😊":
            return .smiley
        case "👍":
            return .thumbsUp
        case "👎":
            return .thumbsDown
        case "😡":
            return .upset
        default:
            return .none
    }
}

struct Event: Identifiable, Hashable{
    let id: UUID
    var backgroundColor: String
    let textColor: String
    let systemImage: String
    let dateTimeStart: Date
    let dateTimeEnd: Date
    let duration: Int
    let dayOfWeek: Int
    let mainImageURL: String
    let sideImagesURL: [String]
    
    var repetitionType: EventRepetitionType
    var reaction: EventReaction
    

    init(systemImage: String, dateTimeStart: Date, dateTimeEnd: Date,
         mainImageURL: String, sideImagesURL: [String], id: UUID = UUID(), bgcolor: String = "Mint", textcolor: String = "Blue",
         repetitionType: String, reactionString: String) {
        self.id = id
        
        self.systemImage = systemImage
        self.backgroundColor = bgcolor
        self.textColor = textcolor
        
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
        
        self.mainImageURL = mainImageURL
        self.sideImagesURL = sideImagesURL
        
        self.dayOfWeek = Calendar.current.component(.weekday, from: self.dateTimeStart)
        self.duration = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart) / 60)
        
        self.repetitionType = repetitionStringToEnum(repetitionType)
        self.reaction = reactionStringToEnum(reactionString)
    }
    
    func getString() -> String {
        return """
            Event @ \(id)
            \(dateTimeStart) to \(dateTimeEnd)
            System image: \(systemImage)
            Colors: \(backgroundColor) - \(colorFromName(backgroundColor)); \(textColor) - \(colorFromName(textColor))
            Images: \(mainImageURL), \(sideImagesURL)
            """
    }

    
}

extension Event {
    func occurs(on date: Date, calendar: Calendar = .current) -> Bool {
        let startDay = calendar.startOfDay(for: dateTimeStart)
        let testDay = calendar.startOfDay(for: date)

        // Ignore dates before event start
        guard testDay >= startDay else { return false }

        switch repetitionType {
        case .once:
            return calendar.isDate(testDay, inSameDayAs: startDay)

        case .daily:
            return true

        case .weekly:
            return calendar.component(.weekday, from: testDay) ==
                   calendar.component(.weekday, from: startDay)

        case .monthly:
            return calendar.component(.day, from: testDay) ==
                   calendar.component(.day, from: startDay)

        case .yearly:
            return calendar.component(.month, from: testDay) == calendar.component(.month, from: startDay) &&
                   calendar.component(.day, from: testDay) == calendar.component(.day, from: startDay)

        case .everyOtherDay:
            let daysBetween = calendar.dateComponents([.day], from: startDay, to: testDay).day ?? -1
            return daysBetween % 2 == 0

        case .everyOtherWeek:
            let weeksBetween = calendar.dateComponents([.weekOfYear], from: startDay, to: testDay).weekOfYear ?? -1
            return weeksBetween % 2 == 0 &&
                   calendar.component(.weekday, from: testDay) == calendar.component(.weekday, from: startDay)

        case .everyOtherMonth:
            let monthsBetween = calendar.dateComponents([.month], from: startDay, to: testDay).month ?? -1
            return monthsBetween % 2 == 0 &&
                   calendar.component(.day, from: testDay) == calendar.component(.day, from: startDay)

        case .weekends:
            return calendar.isDateInWeekend(testDay)

        case .nonWeekends:
            return !calendar.isDateInWeekend(testDay)
        }
    


    }
}

extension Event: Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Event {
    static func mock(
        id: UUID = UUID(),
        systemImage: String = "😊",
        start: Date = Date(),
        durationMinutes: Int = 60,
        mainImageURL: String = "https://example.com/image.png",
        sideImagesURL: [String] = ["https://example.com/image1.png", "https://example.com/image2.png"],
        backgroundColor: String = "Mint",
        textColor: String = "Blue",
        repetitionType: String = "weekly",
        reactionString: String = "😊"
    ) -> Event {
        let end = Calendar.current.date(byAdding: .minute, value: durationMinutes, to: start)!
        return Event(
            systemImage: systemImage,
            dateTimeStart: start,
            dateTimeEnd: end,
            mainImageURL: mainImageURL,
            sideImagesURL: sideImagesURL,
            id: id,
            bgcolor: backgroundColor,
            textcolor: textColor,
            repetitionType: repetitionType,
            reactionString: reactionString
        )
    }
}
