//
//  CalendarHelpers.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import Foundation

func getWeekDates(startingFrom date: Date) -> [Date] {
    let calendar = Calendar.current
    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
    return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.dateFormat = "EEEEE"
    return formatter
}()




