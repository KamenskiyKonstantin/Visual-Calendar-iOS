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
    let APIHandler: ServerAPIinteractor
    let imageList: [String: String]
    let viewSwitcher: ViewSwitcher
    
    // MARK: State Properties
    @State var eventList: [Event]
    @State var weekStartDate: Date = getWeekStartDate(.now)
    @State var isParentMode: Bool
    @State var logoutFormShown: Bool = false
    
    
    
    init(eventList: [Event], APIHandler: ServerAPIinteractor, imageList: [String:String], isParentMode: Bool = false, viewSwitcher: ViewSwitcher ){
        self.eventList = eventList
        self.APIHandler = APIHandler
        self.imageList = imageList
        self.isParentMode = isParentMode
        self.viewSwitcher = viewSwitcher
    }
    var body: some View {
        NavigationStack{
            VStack{
                WeekdayHeader(goToPreviousWeek: goToPreviousWeek,
                              goToNextWeek: goToNextWeek,
                              weekStartDate: weekStartDate)
                ScrollView(.vertical){
                    ZStack(alignment: .topLeading){
                        CalendarTable(minuteHeight: minuteHeight, APIHandler: APIHandler, eventList: eventList, weekStartDate: weekStartDate)
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
                                    await APIHandler.logout()
                                }
                                viewSwitcher.switchToLogin()
                            }
                            Button("Cancel", role: .cancel){
                                logoutFormShown = false
                            }
                        }
            .overlay(alignment: .bottomTrailing){
                if (isParentMode) {
                    EditButtonView(imageList: imageList, APIHandler: APIHandler, updateEvents: updateEvents)
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
    
    func updateEvents(event: [String:Any]){
        var newJSON = [event]
        for item in self.eventList{
            newJSON.append(item.getDictionary())
        }
        self.eventList.append(Event(dictionary: event))
        
        self.APIHandler.upsertEvents(events: newJSON)
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
    CalendarView(eventList:
                    [Event (
                        systemImage: "fork.knife",
                        color: "Teal",
                        dateTimeStart: dateFrom(22,5,2025,0,0),
                        dateTimeEnd: dateFrom(22,5,2025,0, 30),
                        minuteHeight: 2,
                        mainImageURL: "test", sideImagesURL: ["test"]),
                     Event (
                         systemImage: "fork.knife",
                         color: "Teal",
                         dateTimeStart: dateFrom(23,5,2025,1,0),
                         dateTimeEnd: dateFrom(23,5,2025,10, 15),
                         minuteHeight: 2,
                         mainImageURL: "test", sideImagesURL: ["test"])],
                 APIHandler: ServerAPIinteractor(), imageList:[:], isParentMode: false, viewSwitcher: ViewSwitcher(apiHandler: ServerAPIinteractor()))

}


