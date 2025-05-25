//
//  CalendarTable.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI
struct CalendarTable: View {
    let daysOfWeek = defaultDaysOfWeek
    let minuteHeight: Int
    let HStackXOffset = defaultHStackOffset
    
    let APIHandler: ServerAPIinteractor
    
    @State var eventList: [Event]
    @State var weekStartDate: Date = getWeekStartDate(.now)
    @State var isInDeleteMode: Bool = false
    
    var body: some View {
        HStack
        {
            Color.clear
                .frame(width:self.HStackXOffset)
            
            ForEach(0..<7, id:\.self){
                dayOfWeekindex in
                ZStack(alignment: .top)
                {
                    Color.clear
                    ForEach(eventList.indices, id: \.self){
                        event in
                        let currentEvent: Event = eventList[event]
                        let timeSinceWeekStart: TimeInterval = currentEvent.dateTimeStart.timeIntervalSince(self.weekStartDate)
                        let daysSinceWeekStart: Int = Int(floor(timeSinceWeekStart / (60 * 60 * 24)))
                        
                        if dayOfWeekindex - 1 == daysSinceWeekStart{
                            currentEvent.getVisibleObject()
                        }

                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
            }
            Color.black
                .opacity(0)
                .frame(width:self.HStackXOffset)
        }
        .padding(.horizontal, 5)
    }
}
