//
//  CalendarView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI
import SymbolPicker
func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: dateComponents) ?? .now
}

func getWeekStartDate(_ date: Date) -> Date {
    let calendar = Calendar.current
    let weekStartDate = calendar.startOfDay(for: date.addingTimeInterval(-date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 604800)))
    let localeWeightedDay = weekStartDate.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
    return localeWeightedDay
}

struct EventEditor: View{
    @State private var isSymbolPickerShown: Bool = false
    @State private var selectedSymbol: String = "pencil"
    @State private var dateStart: Date = .now
    @State private var dateEnd: Date = .now
    @State private var color: Color = .teal
    @State private var mainImage: String = "Select image"
    private var imageURLS:[String:String]
    
    init(_ imageURLS: [String:String]){
        self.imageURLS = imageURLS
    }
    var body : some View {
            VStack{
                Divider()
                    .overlay(alignment: .center, content: {Text("Time interval")})
                
                DatePicker(selection: $dateStart){
                    Text("Start date")
                }
                .padding(.horizontal, 10)
                DatePicker(selection: $dateEnd){
                    Text("End date")
                }
                .padding(.horizontal, 10)
                
                Divider()
                    .overlay(alignment: .center, content: {Text("Appearance")})
                HStack{
                    Button(action: {isSymbolPickerShown = true})
                    {
                        Image(systemName: selectedSymbol)
                            .fontWeight(.bold)
                            .fontWidth(.expanded)
                        Text("Edit icon")
                    }
                    .sheet(isPresented: $isSymbolPickerShown) {
                        SymbolPicker(symbol: $selectedSymbol)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 10)
                    Spacer()
                }
                
                ColorPicker("Background color", selection:$color)
                    .padding(.horizontal, 10)
                Divider()
                    .overlay(alignment: .center, content: {Text("Content")})
                HStack{
                    Text("Main image")
                    Spacer()
                    Button(action:{print("Add image")})
                    {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.clear).opacity(0.5)
                            .overlay(alignment: .center){
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(5)
                            }
                            .padding(10)
                            .frame(width: 50, height: 50)
                    }
                    if imageURLS.count > 0{
                        if mainImage == "Select image"{
                            Text(mainImage)
                        }
                        Picker(selection: $mainImage, label: Text("Main image")){
                            ForEach(["cola", "abobus"], id: \.self){
                                key in
                                Text(key).tag(key)
                                    
                            }
                        }
                        .navigationTitle("Select image")
                        .fontWeight(.bold)
                        .overlay(alignment: .leading) {
                            
                        }
                        
                    }
                    
                }
                .padding(.horizontal, 10)
                
                //Spacer()
            }
                
    }
}


struct CalendarView: View {
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    let minuteHeight = 2
    let HStackXOffset = CGFloat(Double(50))
    let eventList: [Event]
    @State var weekStartDate: Date = getWeekStartDate(.now)
    init(eventList: [Event]) {
        self.eventList = eventList
        print(weekStartDate)
    }
    var body: some View {
        NavigationStack{
            ZStack(alignment: .topLeading){
                HStack{
                    Button(action: self.goToPreviousWeek)
                    {
                        Image(systemName: "chevron.left")
                            .fontWeight(.bold)
                    }
                    .padding(10)
                    .frame(maxWidth: self.HStackXOffset)
                    
                    Spacer()
                    Button(action: self.goToNextWeek)
                    {
                        Image(systemName: "chevron.right")
                            .fontWeight(.bold)
                    }
                    .padding(10)
                    .frame(maxWidth: self.HStackXOffset)
                    
                }
                
                VStack (spacing: 0){
                    HStack(spacing: 0){
                        
                        Color.black
                            .opacity(0)
                            .frame(width:self.HStackXOffset)
                        
                        ForEach(daysOfWeek.indices, id: \.self){
                            index in
                            Text(daysOfWeek[index])
                                .frame(maxWidth: .infinity)
                        }
                        Color.black
                            .opacity(0)
                            .frame(width:self.HStackXOffset)
                    }
                    .padding(.horizontal, 5)
                    .frame(height: 50)
                    
                    
                    ScrollView(.vertical){
                        ZStack(alignment: .topLeading){
                            HStack
                            {
                                Color.black
                                    .opacity(0)
                                    .frame(width:self.HStackXOffset)
                                
                                ForEach(daysOfWeek.indices, id:\.self){
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
                                                eventList[event].getVisibleObject()
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
                            CalendarBackgroundView(minuteHeight: self.minuteHeight)
                        }
                    }
                }

            }
            .overlay(alignment: .bottomTrailing){
                NavigationLink(destination: CalendarBackgroundView(minuteHeight: self.minuteHeight)){
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.teal).opacity(0.5)
                        .overlay(alignment: .center){
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                        }
                        .padding(10)
                        .frame(width: 125, height: 125)
                }
            }
            
        }
    }
    
    func goToNextWeek(){
        self.weekStartDate = self.weekStartDate.addingTimeInterval(60 * 60 * 24 * 7)
    }
    func goToPreviousWeek(){
        self.weekStartDate = self.weekStartDate.addingTimeInterval(-60 * 60 * 24 * 7)
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
    let duration: Int
    let dayOfWeek: Int
    let mainImageURL: String
    let sideImagesURL: [String]

    init(systemImage: String, color: String, dateTimeStart: Date, dateTimeEnd: Date, minuteHeight: Int,
         mainImageURL: String, sideImagesURL: [String]) {
        self.systemImage = systemImage
        self.color = color
        self.dateTimeStart = dateTimeStart
        self.dateTimeEnd = dateTimeEnd
        self.mainImageURL = mainImageURL
        self.sideImagesURL = sideImagesURL
        self.minuteHeight = minuteHeight
        self.dayOfWeek = Calendar.current.component(.weekday, from: self.dateTimeStart)
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
                        destination: DetailView(mainImage: self.mainImageURL, sideImages: self.sideImagesURL))
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
//    CalendarView(eventList:
//                    [Event (
//                        systemImage: "fork.knife",
//                        color: "Teal",
//                        dateTimeStart: dateFrom(19,9,2024,0,0),
//                        dateTimeEnd: dateFrom(19,9,2024,0, 30),
//                        minuteHeight: 2,
//                        mainImageURL: "abobus", sideImagesURL: ["abobusMnogo"]),
//                     Event (
//                         systemImage: "fork.knife",
//                         color: "Teal",
//                         dateTimeStart: dateFrom(11,9,2024,0,0),
//                         dateTimeEnd: dateFrom(11,9,2024,1, 15),
//                         minuteHeight: 2,
//                         mainImageURL: "abobus", sideImagesURL: ["abobusMnogo"])])
    EventEditor(["b":"a"])
}


