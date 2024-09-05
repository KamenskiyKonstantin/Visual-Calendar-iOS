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

let fileManager = FileManager.default
struct CalendarView: View {
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    let minuteHeight = 2
    let HStackXOffset = CGFloat(Double(50))
    
    let eventList = [Event (systemImage: "fork.knife",
                      color: "Teal",
                      dateTimeStart: dateFrom(8,5,2023,0,0),
                      dateTimeEnd: dateFrom(8,5,2023,1, 15),
                      minuteHeight: 2),
                     Event (systemImage: "gwrhigjwrh",
                                   color: "Teal",
                                   dateTimeStart: dateFrom(1,9,2024,6,0),
                                   dateTimeEnd: dateFrom(1,9,2024,7,0),
                                   minuteHeight: 2),
                     
                     Event (systemImage: "gwrhigjwrh",
                           color: "Teal",
                           dateTimeStart: dateFrom(9,5,2023,9,0),
                           dateTimeEnd: dateFrom(9,5,2023,10,0),
                           minuteHeight: 2),
                     
    ]
    var body: some View {
        NavigationStack{
            VStack (spacing: 0){
                HStack(spacing: 0){
                    
                    Color.black
                        .opacity(0)
                        .frame(width:125)
                    
                    ForEach(daysOfWeek.indices){
                        index in
                        Text(daysOfWeek[index])
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 5)
                .frame(height: 50)
                
                
                ScrollView(.vertical){
                    ZStack(alignment: .topLeading){
                        HStack
                        {
                            Color.black
                                .opacity(0)
                                .frame(width:125)
                            
                            ForEach(daysOfWeek.indices){
                                dayOfWeekindex in
                                ZStack(alignment: .top)
                                {
                                    Color.clear
                                    ForEach(eventList.indices){
                                        
                                        event_index in
                                        
                                        if dayOfWeekindex == eventList[event_index].dayOfWeek{
                                            eventList[event_index].getVisibleObject()
                                        }

                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                            }
                        }
                        .padding(.horizontal, 5)
CalendarBackgroundView(minuteHeight: self.minuteHeight)
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
    let dayOfWeek: Int
    let duration: Int

    init(systemImage: String, color: String, dateTimeStart: Date, dateTimeEnd: Date, minuteHeight: Int) {
        self.systemImage = systemImage
        self.color = color
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
        self.minuteHeight = minuteHeight
        self.dayOfWeek =  Calendar.current.component(.weekday, from: self.dateTimeStart)
        self.duration = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart) / 60)
        
    }
    
    func getVisibleObject() -> some View{
        let height = Int(self.dateTimeEnd.timeIntervalSince(self.dateTimeStart)) / 60 * self.minuteHeight
        let hour = Calendar.current.component(.hour, from: self.dateTimeStart)
        let minute = Calendar.current.component(.minute, from: self.dateTimeStart)
        let offsetY = (hour*60+minute)*self.minuteHeight
    
        return
            VStack(alignment: .leading) {
                    NavigationLink(
                        destination: CalendarBackgroundView(minuteHeight:1))
                    {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.teal).opacity(0.5)
                            .overlay(alignment: .center)
                            {
                                if self.duration >= 60{
                                    Image(systemName: systemImage)
                                        .resizable()
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .padding(10)
                                }
                                else{
                                    Image(systemName: systemImage)
                                        .resizable()
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .padding(5)
                                }
                                
                            }
                            
                            
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: CGFloat(Double(height)), alignment: .top)
            .frame(alignment: .top)
            .offset(x: 0, y: CGFloat(Double(offsetY+30*self.minuteHeight)))
            

            
            
    }
    
    
}
struct DetailView: View{
    let mainImage: String
    let sideImages: [String]
    init(mainImage: String, sideImages: [String] = []) {
        self.mainImage = mainImage
        self.sideImages = sideImages
    }
    
    var body: some View{
        VStack{
            let mainUrl = fileManager.currentDirectoryPath+mainImage
            Image(mainUrl)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            Divider()
            ForEach(sideImages, id: \.self){
                sideImage in
                HStack{
                    Image(sideImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    Divider()
                    
                }
            }
        }
    }
}
#Preview {
    CalendarView()
}


