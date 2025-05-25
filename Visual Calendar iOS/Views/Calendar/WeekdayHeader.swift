//
//  WeekdayHeader.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI

struct WeekNavigationView: View {
    let goToPreviousWeek: () -> Void
    let goToNextWeek: () -> Void
    
    let HStackXOffset: CGFloat = defaultHStackOffset
    
    init(goToPreviousWeek: @escaping () -> Void, goToNextWeek: @escaping () -> Void) {
        self.goToPreviousWeek = goToPreviousWeek
        self.goToNextWeek = goToNextWeek
    }

    var body: some View {
        HStack {
            Button(action: goToPreviousWeek) {
                Image(systemName: "chevron.left")
                    .fontWeight(.bold)
            }
            .padding(10)
            .frame(maxWidth: HStackXOffset)

            Spacer()

            Button(action: goToNextWeek) {
                Image(systemName: "chevron.right")
                    .fontWeight(.bold)
            }
            .padding(10)
            .frame(maxWidth: HStackXOffset)
        }
    }
}

struct daysOfWeekHeader: View {
    var HStackXOffset: CGFloat = defaultHStackOffset
    let daysOfWeek: [String]
    let weekStartDate: Date
    
    var body: some View {
        HStack(spacing: 0, ){
            
            Color.clear
                .frame(width:self.HStackXOffset)
            
            ForEach(getWeekDates(startingFrom: weekStartDate), id: \.self) { date in
                Text(dateFormatter.string(from: date))
                    .frame(maxWidth: .infinity)
            }
            Color.clear
                .frame(width:self.HStackXOffset)
        }
        .padding(.horizontal, 5)
        .frame(height: 50)
    }
}

struct WeekdayHeader: View {
    let goToPreviousWeek: () -> Void
    let goToNextWeek: () -> Void
    var daysOfWeek: [String] = defaultDaysOfWeek
    let weekStartDate: Date
    
    init(goToPreviousWeek: @escaping () -> Void, goToNextWeek: @escaping () -> Void, daysOfWeek: [String] = defaultDaysOfWeek,
         weekStartDate: Date) {
        self.goToPreviousWeek = goToPreviousWeek
        self.goToNextWeek = goToNextWeek
        self.daysOfWeek = daysOfWeek
        self.weekStartDate = weekStartDate
    }
    
    
    var body: some View {
        ZStack{
            WeekNavigationView(goToPreviousWeek: goToPreviousWeek, goToNextWeek: goToNextWeek)
            daysOfWeekHeader(daysOfWeek: daysOfWeek, weekStartDate: weekStartDate)
        }
    }
}


