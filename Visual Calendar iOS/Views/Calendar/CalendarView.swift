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
    @ObservedObject var api: APIHandler
    let viewSwitcher: ViewSwitcher
    
    // MARK: State Properties
    @State var currentDate: Date = Date().startOfWeek()
    
    @State var isParentMode: Bool
    @State var deleteMode: Bool = false
    
    @State var mode: CalendarMode = .Week
    
    
    //MARK: Sheet showers
    @State var logoutFormShown: Bool = false
    
    
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
                                api: api,
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
                                Task{
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
                        api: api,
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





struct DetailView: View{
    let mainImage: String
    let sideImages: [String]
    init(mainImage: String, sideImages: [String] = []) {
        self.mainImage = mainImage
        self.sideImages = sideImages
    }
    
    var body: some View{
        VStack{

            AsyncImage(url:URL(string:self.mainImage)){
                asyncImage in
                if let image = asyncImage.image{
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                 }
            }
                
            Divider()
            ForEach(sideImages, id: \.self){
                sideImage in
                HStack{
                    AsyncImage(url:URL(string:sideImage)){
                        asyncImage in
                        if let image = asyncImage.image{
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                         }
                    }
                    
                }
            }
        }
    }
}



