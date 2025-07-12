//
//  BaseExtensions.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.05.2025.
//

import Foundation

extension Date {
    static func from(day: Int, month: Int, year: Int, hour: Int = 0, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? .now
    }

    func toIntList() -> [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: self)
        return [
            components.day ?? 0,
            components.month ?? 0,
            components.year ?? 0,
            components.hour ?? 0,
            components.minute ?? 0
        ]
    }

    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
        return start
    }
    
    // DD.MM.YYYY representation
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self) + " " + getMonthName()
    }
    
    func getMonthName() -> String {
        let month = Calendar.current.component(.month, from: self)
        switch month {
        case 1:
            return "ЯНВАРЯ"
        case 2:
            return "ФЕВРАЛЯ"
        case 3:
            return "МАРТА"
        case 4:
            return "АПРЕЛЯ"
        case 5:
            return "МАЯ"
        case 6:
            return "ИЮНЯ"
        case 7:
            return "ИЮЛЯ"
        case 8:
            return "АВГУСТА"
        case 9:
            return "СЕНТЯБРЯ"
        case 10:
            return "ОКТЯБРЯ"
        case 11:
            return "НОЯБРЯ"
        case 12:
            return "ДЕКАБРЯ"
        default:
            return "НЕИЗВЕСТНО"
        }
    }
}

extension Event {
    func toEventJSON() -> EventJSON {
        let calendar = Calendar.current

        let startComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: self.dateTimeStart)
        let endComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: self.dateTimeEnd)

        let timeStart = [
            startComponents.day ?? 1,
            startComponents.month ?? 1,
            startComponents.year ?? 2000,
            startComponents.hour ?? 0,
            startComponents.minute ?? 0
        ]
        
        let timeEnd = [
            endComponents.day ?? 1,
            endComponents.month ?? 1,
            endComponents.year ?? 2000,
            endComponents.hour ?? 0,
            endComponents.minute ?? 0
        ]

        return EventJSON(
            timeStart: timeStart,
            timeEnd: timeEnd,
            systemImage: self.systemImage,
            backgroundColor: self.backgroundColor,
            textColor: self.textColor,
            mainImageURL: self.mainImageURL,
            sideImageURLS: self.sideImagesURL,
            id: self.id,
            repetitionType: self.repetitionType.displayName,
        )
    }
}

extension Event: Hashable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
            return lhs.dateTimeStart == rhs.dateTimeStart && lhs.systemImage == rhs.systemImage
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(dateTimeStart)
            hasher.combine(systemImage)
        }
}


