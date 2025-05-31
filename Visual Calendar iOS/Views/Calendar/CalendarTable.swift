//
//  CalendarTable.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 25.05.2025.
//

import SwiftUI

struct CalendarTable: View {
    let minuteHeight: Int
    @ObservedObject var api: APIHandler
    @Binding var weekStartDate: Date

    let HStackXOffset: CGFloat = defaultHStackOffset

    // Computed property to group events by day index (0-6)
    private var eventsPerDay: [[Event]] {
        var weekBuckets: [[Event]] = Array(repeating: [], count: 7)
        let calendar = Calendar.current

        for event in api.eventList {
            let dayIndex = calendar.dateComponents([.day], from: weekStartDate, to: event.dateTimeStart).day ?? -1
            if (0...6).contains(dayIndex) {
                weekBuckets[dayIndex].append(event)
            }
        }
        return weekBuckets
    }

    // Enumerate the days with their events for easy ForEach
    private var daysWithEvents: [(Int, [Event])] {
        eventsPerDay.enumerated().map { ($0.offset, $0.element) }
    }

    // Calculate day offset from week start
    private func dayOffset(for event: Event) -> Int {
        let timeSinceWeekStart = event.dateTimeStart.timeIntervalSince(weekStartDate)
        return Int(floor(timeSinceWeekStart / (60 * 60 * 24)))
    }

    var body: some View {
        HStack {
            Color.clear
                .frame(width: HStackXOffset)

            ForEach(daysWithEvents, id: \.0) { dayOfWeekIndex, eventsForDay in
                ZStack(alignment: .top) {
                    Color.clear

                    ForEach(eventsForDay, id: \.self) { event in
                        if dayOfWeekIndex == dayOffset(for: event) {
                            event.getVisibleObject()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Color.clear
                .frame(width: HStackXOffset)
        }
        .padding(.horizontal, 5)
    }
}

extension Event: Hashable, Equatable {
    static func == (lhs: Event, rhs: Event) -> Bool {
            return lhs.dateTimeStart == rhs.dateTimeStart && lhs.systemImage == rhs.systemImage
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(dateTimeStart)
            hasher.combine(systemImage)
        }
}

