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
    static func fromArray(_ components: [Int]) -> Date? {
        guard components.count == 5 else { return nil }
        return Self.from(
            day: components[0],
            month: components[1],
            year: components[2],
            hour: components[3],
            minute: components[4]
        )
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
    
    func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self) + " " + getMonthName()
    }
    
    func getMonthName() -> String {
        let month = Calendar.current.component(.month, from: self)
        switch month {
        case 1:  return "Month.1".localized
        case 2:  return "Month.2".localized
        case 3:  return "Month.3".localized
        case 4:  return "Month.4".localized
        case 5:  return "Month.5".localized
        case 6:  return "Month.6".localized
        case 7:  return "Month.7".localized
        case 8:  return "Month.8".localized
        case 9:  return "Month.9".localized
        case 10: return "Month.10".localized
        case 11: return "Month.11".localized
        case 12: return "Month.12".localized
        default: return "Month.Unknown".localized
        }
    }
}



extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
