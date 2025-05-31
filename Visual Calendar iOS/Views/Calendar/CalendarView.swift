//
//  CalendarView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI


// MARK: Date-Time transformations—


struct CalendarView: View {
    // MARK: Constants
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    let minuteHeight = 2
    let HStackXOffset = defaultHStackOffset
    
    // MARK: Dependencies
    @ObservedObject var api: APIHandler
    let viewSwitcher: ViewSwitcher
    let imageList: [String:[String: String]]
    
    
    // MARK: State Properties
    @State var weekStartDate: Date = Date().startOfWeek()
    @State var isParentMode: Bool
    @State var logoutFormShown: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                WeekdayHeader(goToPreviousWeek: goToPreviousWeek,
                              goToNextWeek: goToNextWeek,
                              weekStartDate: $weekStartDate)
                ScrollView(.vertical){
                    ZStack(alignment: .topLeading){
                        CalendarTable(
                            minuteHeight: minuteHeight,
                            api: api,
                            weekStartDate: $weekStartDate)
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
            
            .overlay(alignment: .bottomTrailing){
                if (isParentMode) {
                    EditButtonView(
                        imageList: imageList,
                        APIHandler: api,
                        updateEvents: self.updateEvents)
                }
            }
            .overlay(alignment: .topTrailing){
                Button(action:{Task{await refetchEvents()}}){
                    Image(systemName: "arrow.clockwise.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            
            .overlay(alignment: .bottomLeading, content: {
                LogoutButtonView(logoutFormShown: $logoutFormShown)
            })
            
        }
            
    }
    
    func goToNextWeek(){
        self.weekStartDate = self.weekStartDate.addingTimeInterval(60 * 60 * 24 * 7)
    }
    func goToPreviousWeek(){
        self.weekStartDate = self.weekStartDate.addingTimeInterval(-60 * 60 * 24 * 7)
        print(self.weekStartDate)
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
#Preview {
    CalendarView(api: APIHandler(eventList:
                                    [Event (
                                        systemImage: "fork.knife",
                                        dateTimeStart: Date.from(day: 22, month: 5,year:2025,hour:0,minute:0),
                                        dateTimeEnd: Date.from(day: 22,month: 5,year: 2025, hour:0, minute:30),
                                        minuteHeight: 2,
                                        mainImageURL: "test", sideImagesURL: ["test"]),
                                     Event (
                                         systemImage: "plus",
                                         dateTimeStart: Date.from(day: 23, month: 5,year:2025,hour:1,minute:15),
                                         dateTimeEnd: Date.from(day: 23, month: 5,year:2025,hour:10,minute:15),
                                         minuteHeight: 2,
                                         mainImageURL: "test", sideImagesURL: ["test"]),
                                     Event (
                                        systemImage: "fork.knife",
                                        dateTimeStart: Date.from(day: 23, month: 5,year:2025,hour:0,minute:0),
                                        dateTimeEnd: Date.from(day: 22, month: 5,year:2025,hour:2,minute:30),
                                        minuteHeight: 2,
                                        mainImageURL: "test", sideImagesURL: ["test"]),
                                    ],),
                 viewSwitcher: ViewSwitcher(api: APIHandler()),
                 imageList:[:],

                 isParentMode: true)

}


