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


import SwiftUI

struct CalendarTable: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        if viewModel.mode == .Week {
            weekView
        } else {
            dayView
        }
    }

    // MARK: - Week View
    private var weekView: some View {
        HStack {
            ForEach(eventsPerDay.enumerated().map { ($0.offset, $0.element) }, id: \.0) { dayIndex, eventsForDay in
                let day = Calendar.current.date(byAdding: .day, value: dayIndex, to: viewModel.currentDate.startOfWeek()) ?? viewModel.currentDate
                ZStack(alignment: .top) {
                    Color.clear
                    ForEach(eventsForDay, id:\.self) { event in
                        
                        let dateStart = dateWithTime(from: day, using: event.dateTimeStart)
                        let reactions: [EventReactionRow] = viewModel.reactions[event.id] ?? []
                        let currentReaction = reactions.first(where: { $0.timestampMatches(dateStart) })
                        let matchingReaction = currentReaction?.emoji ?? ""
                        let finalReaction = reactionStringToEnum(matchingReaction)
                        
                        EventView(eventID: event.id, viewModel: viewModel, minuteHeight: viewModel.minuteHeight, dateStart: dateStart.toIntList(), reaction: finalReaction)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 5)
        }
    }

    // MARK: - Day View
    private var dayView: some View {
        HStack {
            ZStack(alignment: .top) {
                Color.clear
                ForEach(eventsAt(date: viewModel.currentDate)) { event in
                    let dateStart = viewModel.currentDate
                    let reactions: [EventReactionRow] = viewModel.reactions[event.id] ?? []
                    let currentReaction = reactions.first(where: { $0.timestampMatches(dateStart) })
                    let matchingReaction = currentReaction?.emoji ?? ""
                    let finalReaction = reactionStringToEnum(matchingReaction)
                    
                    EventView(eventID: event.id, viewModel: viewModel, minuteHeight: viewModel.minuteHeight, dateStart: dateStart.toIntList(), reaction: finalReaction)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Helpers
    private var eventsPerDay: [[Event]] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: viewModel.currentDate) else {
                return nil
            }
            return eventsAt(date: date)
        }
    }

    private func eventsAt(date: Date) -> [Event] {
        viewModel.events.filter { $0.occurs(on: date) }
    }
}


