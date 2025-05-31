//
//  CalendarHelpers.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import Foundation
import SwiftUI

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

func sortEventsByDuration(_ events: [Event]) -> [Event] {
    return events.sorted { (event1, event2) -> Bool in
        return event1.duration > event2.duration
    }
}

func colorFromName(_ name: String) -> Color {
    switch name {
    case "Black": return Color(.black)
    case "Blue": return Color(.systemBlue)
    case "Brown": return Color(.systemBrown)
    case "Cyan": return Color(.systemCyan)
    case "Gray": return Color(.systemGray)
    case "Green": return Color(.systemGreen)
    case "Indigo": return Color(.systemIndigo)
    case "Mint": return Color(.systemMint)
    case "Orange": return Color(.systemOrange)
    case "Pink": return Color(.systemPink)
    case "Purple": return Color(.systemPurple)
    case "Red": return Color(.systemRed)
    case "Teal": return Color(.systemTeal)
    case "White": return Color(.white)
    case "Yellow": return Color(.systemYellow)
    default: return Color.black
    }
}


func printvalue(_ value: Binding<String>) -> Binding<String> {
    print(String(describing: value))
    return value
}
