//
//  CalendarTable.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI

public enum CalendarMode {
    case Week
    case Day
}


struct CalendarTable: View {
    let minuteHeight: Int
    @ObservedObject var api: APIHandler
    @Binding var currentDate: Date
    @Binding var mode: CalendarMode
    @Binding var deleteMode: Bool
    
    
    private var daysWithEvents: [(Int, [Event])] {
        eventsPerDay.enumerated().map { ($0.offset, $0.element) }
    }
    
    private func dayOffset(for event: Event) -> Int {
        let timeSinceWeekStart = event.dateTimeStart.timeIntervalSince(currentDate)
        return Int(floor(timeSinceWeekStart / (60 * 60 * 24)))
    }
    
    var body: some View {
        if mode == .Week {
            weekView
        } else {
            dayView
        }
    }

    private var weekView: some View {
        HStack {
            ForEach(daysWithEvents, id: \.0) { dayOfWeekIndex, eventsForDay in
                ZStack(alignment: .top) {
                    Color.clear
                    
                    ForEach(eventsForDay, id: \.self) { event in
                        event.getVisibleObject(deleteMode: deleteMode, deletionAPI: api)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 5)
        }
    }

    private var dayView: some View {
        HStack {
            ZStack(alignment: .top) {
                Color.clear
                ForEach(eventsAtGivenDay(currentDate), id: \.self) { event in
                    event.getVisibleObject(deleteMode: deleteMode, deletionAPI: api)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
}


extension CalendarTable {
    private var eventsPerDay: [[Event]] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            guard let targetDate = calendar.date(byAdding: .day, value: offset, to: currentDate) else {
                return []
            }
            return eventsAtGivenDay(targetDate)
        }
    }
    
    private func eventsAtGivenDay(_ date: Date) -> [Event] {
        api.eventList.filter { $0.occurs(on: date) }
    }
    
}
