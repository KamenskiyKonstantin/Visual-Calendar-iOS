//
//  UtilsUI.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 23.01.2025.
//

import SwiftUI

func emojiToImage(_ emoji: String, fontSize: CGFloat) -> UIImage? {
    let size = CGSize(width: fontSize, height: fontSize)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize)
        ]
        let textSize = emoji.size(withAttributes: attributes)
        let rect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        emoji.draw(in: rect, withAttributes: attributes)
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
