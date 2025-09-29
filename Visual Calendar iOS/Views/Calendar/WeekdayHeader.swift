////
////  WeekdayHeader.swift
////  Visual Calendar iOS
////
////  Created by Konstantin Kamenskiy on 25.05.2025.
////
//
//import SwiftUI
//
//struct WeekNavigationView: View {
//    let decreaseCurrentDate: () -> Void
//    let increaseCurrentDate: () -> Void
//    let HStackXOffset: CGFloat
//    var body: some View {
//        VStack(alignment: .leading) {
//            
//            HStack {
//                Button(action: decreaseCurrentDate) {
//                    Image(systemName: "chevron.left")
//                        .fontWeight(.bold)
//                }
//                .padding(10)
//                .frame(maxWidth: HStackXOffset)
//                Spacer()
//
//                Button(action: increaseCurrentDate) {
//                    Image(systemName: "chevron.right")
//                        .fontWeight(.bold)
//                }
//                .padding(10)
//                .frame(maxWidth: HStackXOffset)
//            }
//        }
//        
//    }
//}
//
//struct daysOfWeekHeader: View {
//    
//    var HStackXOffset: CGFloat
//    let daysOfWeek: [String]
//    @Binding var currentDate: Date
//    @Binding var mode: CalendarMode
//    
//    
//    
//    var body: some View {
//        if mode == .Week {
//            HStack(spacing: 0, ){
//                
//                Color.clear
//                    .frame(maxWidth: HStackXOffset)
//                
//                
//                ForEach(0..<7, id: \.self) { date in
//                    VStack{
//                        
//                        let currentDate = Calendar.current.date(byAdding: .day, value: date, to: self.currentDate)!
//                        Button (action: {
//                            self.currentDate = currentDate
//                            self.mode = .Day
//                        }){
//                            VStack(alignment: .leading){
//                                if Calendar.current.isDateInToday(currentDate) {
//                                    Text(currentDate.getFormattedDate())
//                                        .foregroundStyle(Color(.systemGreen))
//                                        .frame(maxWidth: .infinity)
//                                    Text(daysOfWeek[date])
//                                        .foregroundStyle(Color(.systemGreen))
//                                        .frame(maxWidth: .infinity)
//                                }
//                                else{
//                                    Text(currentDate.getFormattedDate())
//                                        .frame(maxWidth: .infinity)
//                                    Text(daysOfWeek[date])
//                                        .frame(maxWidth: .infinity)
//                                    
//                                }
//                            }
//                            
//                        }
//                        
//                    }
//                }
//                
//                Color.clear
//                    .frame(maxWidth: HStackXOffset)
//            }
//            .padding(.horizontal, 5)
//            .frame(height: 50)
//        }
//        else if mode == .Day {
//            HStack(spacing: 0, ){
//                Spacer()
//                VStack{
//                    let dayOfWeek = Calendar.current.component(.weekday, from: self.currentDate) - 1
//                    Button(action: {
//                        currentDate = currentDate.startOfWeek()
//                        mode = .Week
//                    }){
//                        VStack{
//                            if Calendar.current.isDateInToday(currentDate) {
//                                Text(currentDate.getFormattedDate())
//                                    .foregroundStyle(Color(.systemGreen))
//                                    .frame(maxWidth: .infinity)
//                                Text(daysOfWeek[dayOfWeek])
//                                    .foregroundStyle(Color(.systemGreen))
//                                    .frame(maxWidth: .infinity)
//                            }
//                            else{
//                                Text(currentDate.getFormattedDate())
//                                    .frame(maxWidth: .infinity)
//                                Text(daysOfWeek[dayOfWeek])
//                                    .frame(maxWidth: .infinity)
//                                
//                            }
//                        }
//                    }
//
//                }
//                .frame(maxWidth: 200)
//                Spacer()
//            }
//        }
//    }
//}
//
//struct WeekdayHeader: View {
//    let decreaseCurrentDate: () -> Void
//    let increaseCurrentDate: () -> Void
//    var daysOfWeek: [String] = defaultDaysOfWeek
//    let HStackXOffset: CGFloat
//    @Binding var currentDate: Date
//    @Binding var mode: CalendarMode
//    
//    var body: some View {
//        
//        ZStack{
//            WeekNavigationView(
//                               decreaseCurrentDate: decreaseCurrentDate,
//                               increaseCurrentDate: increaseCurrentDate,
//                               HStackXOffset: HStackXOffset)
//            daysOfWeekHeader(HStackXOffset: HStackXOffset,daysOfWeek: daysOfWeek,
//                             currentDate: $currentDate,
//                             mode: $mode)
//        }
//
//       
//    }
//}
//
//
