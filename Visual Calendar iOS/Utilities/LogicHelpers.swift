//
//  CalendarHelpers.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import Foundation

func bestMatchingKeyword(from text: String, keywords: [String], maxDistance: Int = 3) -> String {
    print("Looking for best matching keyword from \(text)")

    var bestMatch: String?
    var bestDistance = Int.max
    if text.isEmpty {
        return "Custom"
    }
    for keyword in keywords {
        let distance = levenshtein(text, keyword.lowercased())
        if distance < bestDistance && distance <= maxDistance {
            bestMatch = keyword
            bestDistance = distance
        }
    }

    return bestMatch ?? "Custom"
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


func resolveLibraries(from systemNames: [String], using available: [LibraryInfo]) -> [LibraryInfo] {
    return available.filter { systemNames.contains($0.system_name) }
}

struct RuntimeWarning: Error {
    let message: String
    init(_ message: String) { self.message = message }
    var localizedDescription: String { message }
}
