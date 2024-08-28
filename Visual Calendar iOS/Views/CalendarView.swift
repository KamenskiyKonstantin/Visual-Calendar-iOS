//
//  CalendarView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI

func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: dateComponents) ?? .now
}

struct CalendarView: View {
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    let minuteHeight = 2
    
    let eventList = [Event (systemImage: "gwrhigjwrh",
                      color: "Teal",
                      dateTimeStart: dateFrom(9,5,2023,0,0),
                      dateTimeEnd: dateFrom(9,5,2023,1,30),
                      minuteHeight: 2),
                     Event (systemImage: "gwrhigjwrh",
                                       color: "Teal",
                                       dateTimeStart: dateFrom(9,5,2023,2,0),
                                       dateTimeEnd: dateFrom(9,5,2023,4,30),
                                       minuteHeight: 2),
                     
                     Event (systemImage: "gwrhigjwrh",
                           color: "Teal",
                           dateTimeStart: dateFrom(9,5,2023,9,0),
                           dateTimeEnd: dateFrom(9,5,2023,10,0),
                           minuteHeight: 2),
                     
    ]
    var body: some View {
        VStack (spacing: 0){
            HStack{
                ForEach(daysOfWeek.indices){
                    index in
                    Text(daysOfWeek[index])
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                }
            }
            .frame(height: 50)
            .offset(x:50, y:0)
            ScrollView(.vertical){
                ZStack(alignment: .topLeading){
                    CalendarBackgroundView(minuteHeight: self.minuteHeight)
                    
                    ForEach(eventList.indices){
                        event_index in
                        eventList[event_index].getVisibleObject()
                    }
                }
            }
        }
    }
}

struct CalendarBackgroundView: View{
    let hours = ["12 am", "1 am", "2 am", "3 am", "4 am", "5 am",
                 "6 am", "7 am", "8 am", "9 am", "10 am", "11 am",
                 "12 pm"]
    let minuteHeight: Int
    init(minuteHeight: Int) {
        self.minuteHeight = minuteHeight
    }
    var body: some View{
        VStack(spacing: 0){
            ForEach(hours, id: \.self){
                hour in
                HStack{
                    Text(hour)
                    VStack{
                        Divider()
                    }
                }
                .frame(height: CGFloat(Double(minuteHeight*60)))
            }
        }
    }
}

class Event{
    let systemImage: String
    let color: String
    let dateTimeStart: Date
    let dateTimeEnd: Date
    let minuteHeight : Int
    
    init(systemImage: String, color: String, dateTimeStart: Date, dateTimeEnd: Date, minuteHeight: Int) {
        self.systemImage = systemImage
        self.color = color
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
        self.minuteHeight = minuteHeight
    }
    
    func getVisibleObject() -> some View{
        let height = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart)) / 60 * self.minuteHeight
        let hour = Calendar.current.component(.hour, from: self.dateTimeStart)
        let minute = Calendar.current.component(.minute, from: self.dateTimeStart)
        let offsetY = (hour*60+minute)*self.minuteHeight
        
        let dayOfWeek = Calendar.current.component(.weekday, from: self.dateTimeStart)
        let offsetX = 100*dayOfWeek
        
        return VStack(alignment: .leading) {
                Text(self.systemImage).bold()
                }
                .font(.caption)
                .frame(maxWidth: 200, alignment: .leading)
                .frame(height: CGFloat(Double(height)), alignment: .top)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.teal).opacity(0.5)
                )
                .offset(x: CGFloat(Double(50+offsetX)), y: CGFloat(Double(offsetY+60)))

        
        
    }
    
    
}
#Preview {
    CalendarView()
}
