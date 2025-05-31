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
    var body: some View {
        VStack(alignment: .leading) {
            
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
}

struct daysOfWeekHeader: View {
    var HStackXOffset: CGFloat = defaultHStackOffset
    let daysOfWeek: [String]
    let weekStartDate: Date
    
    var body: some View {
        HStack(spacing: 0, ){
            
            Color.clear
                .frame(width:self.HStackXOffset)
            
            ForEach(0..<7, id: \.self) { date in
                VStack{
                    
                    let currentDate = Calendar.current.date(byAdding: .day, value: date, to: self.weekStartDate)!
                    if Calendar.current.isDateInToday(currentDate) {
                        Text(currentDate.getFormattedDate())
                            .foregroundStyle(Color(.systemGreen))
                            .frame(maxWidth: .infinity)
                        Text(daysOfWeek[date])
                            .foregroundStyle(Color(.systemGreen))
                            .frame(maxWidth: .infinity)
                    }
                    else{
                        Text(currentDate.getFormattedDate())
                            .frame(maxWidth: .infinity)
                        Text(daysOfWeek[date])
                            .frame(maxWidth: .infinity)
                        
                    }
                    
                    
                }
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
    @Binding var weekStartDate: Date
    
    
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text(self.weekStartDate.description)
                Spacer()
            }
            ZStack{
                WeekNavigationView(goToPreviousWeek: goToPreviousWeek, goToNextWeek: goToNextWeek)
                daysOfWeekHeader(daysOfWeek: daysOfWeek, weekStartDate: weekStartDate)
            }
        }
       
    }
}


