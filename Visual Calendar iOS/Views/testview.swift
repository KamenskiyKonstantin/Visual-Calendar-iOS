//
//  testview.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI

struct CalendarPageView: View {
    let hours: [String]
    @Binding var hourSpacing: Double
    @Binding var hourHeight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: hourSpacing) {
            ForEach(hours.indices) { index in
                let hour = hours[index]
                HStack {
                    Text(hour)
                        .font(Font.caption)
                        .minimumScaleFactor(0.7)
                        .frame(width: 35, height: hourHeight, alignment: .trailing)
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(.small ... .large)
                    VStack {
                        Divider()
                            .foregroundColor(.secondary.opacity(0.9))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CalendarPageView(hours: ["12 am", "1 am", "2 am", "3 am", "4 am"], hourSpacing: .constant(24), hourHeight: .constant(30))
}
