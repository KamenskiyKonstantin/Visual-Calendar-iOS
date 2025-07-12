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


func bestMatchingKeyword(from text: String, keywords: [String]) -> String {
    let words = text.lowercased().split(separator: " ").map { String($0) }

    for word in words {
        for keyword in keywords {
            if levenshtein(word, keyword.lowercased()) <= 2 {
                return keyword
            }
        }
    }

    return "Custom"
}

// Levenshtein distance function
func levenshtein(_ lhs: String, _ rhs: String) -> Int {
    let lhsChars = Array(lhs)
    let rhsChars = Array(rhs)
    
    let m = lhsChars.count
    let n = rhsChars.count
    
    var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
    
    for i in 0...m { dp[i][0] = i }
    for j in 0...n { dp[0][j] = j }
    
    for i in 1...m {
        for j in 1...n {
            if lhsChars[i - 1] == rhsChars[j - 1] {
                dp[i][j] = dp[i - 1][j - 1]
            } else {
                dp[i][j] = min(
                    dp[i - 1][j] + 1,    // deletion
                    dp[i][j - 1] + 1,    // insertion
                    dp[i - 1][j - 1] + 1 // substitution
                )
            }
        }
    }
    
    return dp[m][n]
}
