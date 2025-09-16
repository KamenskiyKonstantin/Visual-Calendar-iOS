//
//  CalendarView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI

struct CalendarView: View {
    // MARK: Constants
    let minuteHeight = 2
    let HStackXOffset = defaultHStackOffset
    
    // MARK: Dependencies
    @EnvironmentObject var api: APIHandler
    @EnvironmentObject var warningHandler: WarningHandler
    let viewSwitcher: ViewSwitcher
    
    // MARK: State Properties
    @State var currentDate: Date = Date().startOfWeek()
    
    @State var isParentMode: Bool
    @State var deleteMode: Bool = false
    
    @State var mode: CalendarMode = .Week
    
    
    //MARK: Sheet showers
    @State var logoutFormShown: Bool = false
    
    @EnvironmentObject var warninghandler: WarningHandler
    
    var body: some View {
        NavigationStack{
            VStack (spacing:0){
                WeekdayHeader(
                    decreaseCurrentDate: decreaseCurrentDate,
                    increaseCurrentDate: increaseCurrentDate,
                    HStackXOffset: HStackXOffset,
                    currentDate: $currentDate,
                    mode: $mode
                )
                ScrollView(.vertical){
                    ZStack(alignment: .topLeading){
                        HStack{
                            Color.clear.frame(width: HStackXOffset)
                            CalendarTable(
                                minuteHeight: minuteHeight,
                                currentDate: $currentDate,
                                mode: $mode,
                                deleteMode: $deleteMode)
                            Color.clear.frame(width: HStackXOffset)
                        }
                        CalendarBackgroundView(minuteHeight: minuteHeight)
                    }
                }
                
            }
            .confirmationDialog(
                            "Are you sure you want to proceed?",
                            isPresented: $logoutFormShown,
                            titleVisibility: .visible
            ) {
                            Button("OK") {
                                AsyncExecutor.runWithWarningHandler(warningHandler: warninghandler, api: api, viewSwitcher: viewSwitcher) {
                                    try await api.logout()
                                    viewSwitcher.switchToLogin()
                                }
                            }
                            Button("Cancel", role: .cancel){
                                logoutFormShown = false
                            }
                        }
            .overlay(alignment: .bottom,
                     content: {ButtonPanel(
                        logoutFormShown: $logoutFormShown,
                        calendarMode: $mode,
                        currentDate: $currentDate,
                        deleteMode: $deleteMode,
                        isParentMode: isParentMode,
                        updateEvents: updateEvents)})

        }
            
    }
    
    func increaseCurrentDate(){
        if mode == .Week{
            self.currentDate = self.currentDate.addingTimeInterval(60 * 60 * 24 * 7)
        }
        else if mode == .Day{
            self.currentDate = self.currentDate.addingTimeInterval(60 * 60 * 24)
        }
        
    }
    func decreaseCurrentDate(){
        if mode == .Week{
            self.currentDate = self.currentDate.addingTimeInterval(-60 * 60 * 24 * 7)
        }
        else if mode == .Day{
            self.currentDate = self.currentDate.addingTimeInterval(-60 * 60 * 24)
        }
    }
    
    func updateEvents(event: Event) async throws{
        print("Updater received event: \(event.getString())")
        let newEvents: [Event] = api.eventList+[event]
        print("New events: \(newEvents)")
        try await api.upsertEvents(newEvents)
        try await api.fetchEvents()
    }
    
    func refetchEvents() async {
        do {
            try await api.fetchEvents()
        }
        catch{
            print("Error fetching events: \(error)")
        }
    }
    
    
}

struct CalendarBackgroundView: View{
    let hours = [
        "00:00", "01:00", "02:00", "03:00", "04:00", "05:00",
        "06:00", "07:00", "08:00", "09:00", "10:00", "11:00",
        "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
        "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"
    ]
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
                        .padding(.leading, 10)
                    VStack{
                        Divider()
                    }
                }
                .frame(height: CGFloat(Double(minuteHeight*60)))
            }
        }
    }
}





struct DetailView: View {
    let eventID: UUID
    @EnvironmentObject var api: APIHandler
    @EnvironmentObject var warningHandler: WarningHandler
    @EnvironmentObject var viewSwitcher: ViewSwitcher

    var event: Event? {
        api.eventList.first(where: { $0.id == eventID })
    }

    var body: some View {
        if let event = event {
            DetailViewBody(event: event)
        } else {
            Image(uiImage: emojiToImage("❌", fontSize: 64) ?? UIImage())
        }
    }

    @ViewBuilder
    func DetailViewBody(event: Event) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                mainImage(event: event)
                Divider()
                sideImages(event: event)
                Divider()
                reactionButtons(event: event)
            }
            .padding()
        }
    }

    private func mainImage(event: Event) -> some View {
        AsyncImage(url: URL(string: event.mainImageURL)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
            }
        }
    }

    private func sideImages(event: Event) -> some View {
        VStack {
            ForEach(event.sideImagesURL, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }

    private func reactionButtons(event: Event) -> some View {
        HStack(spacing: 12) {
            ForEach(EventReaction.allCases.filter { $0 != .none }, id: \.self) { reaction in
                Button {
                    let newReaction = (event.reaction == reaction) ? .none : reaction
                    updateEventReaction(newReaction)
                } label: {
                    emojiButton(for: reaction, selected: event.reaction == reaction)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func emojiButton(for reaction: EventReaction, selected: Bool) -> some View {
        let image = emojiToImage(reaction.emoji, fontSize: 36) ?? UIImage()

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 44, height: 44)
            .padding(8)
            .background(selected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? Color.blue : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    func updateEventReaction(_ newReaction: EventReaction) {
        guard var new_event = event else { return }
        new_event.reaction = newReaction

        AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: api, viewSwitcher: viewSwitcher) {
            var events = api.eventList
            if let index = events.firstIndex(where: { $0.id == new_event.id }) {
                events[index] = new_event
                try await api.upsertEvents(events)
            }
        }
    }
}
