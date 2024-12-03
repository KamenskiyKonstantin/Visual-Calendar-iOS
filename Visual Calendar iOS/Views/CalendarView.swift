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

func DateToIntList(date: Date) -> [Int]{
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date)
    let day = components.day
    let month = components.month
    let year = components.year
    let hour = components.hour
    let minute = components.minute
    return [day!, month!, year!, hour!, minute!]
}

struct NameEditor: View{
    @Binding var name: String
    var callback: () -> Void
    init(_ name: Binding<String>, callback: @escaping () -> Void){
        _name = name
        self.callback = callback
    }
    var body: some View{
        VStack{
            Text("Please name your file")
            TextField("Name", text: $name)
            Button("Ok"){
                self.callback()
            }
        }
    }
}

struct EventEditor: View{
    @State private var isSymbolPickerShown: Bool = false
    @State private var selectedSymbol: String = "pencil"
    @State private var dateStart: Date = .now
    @State private var dateEnd: Date = .now
    @State private var color: Color = .teal
    @State private var mainImage: String = "Select image"
    @State private var fileImporterPresented: Bool = false
    @State private var sideImages: [String] = []
    @State private var imageURLS:[String:String]
    @State private var isNameEditorShown: Bool = false
    @State private var addedFilename: String = "Unnamed"
    @State private var addedOriginalFilename: String = ""
    
    @Environment(\.dismiss) private var dismiss
    private var APIHandler: ServerAPIinteractor
    let updateCallback: ([String:Any]) -> Void
    
    
    init(imageURLS: [String:String], APIHandler: ServerAPIinteractor, callback: @escaping ([String:Any]) -> Void){
        self.imageURLS = imageURLS
        self.APIHandler = APIHandler
        updateCallback = callback
    }
    func fileCallback (_ result: Result<URL, any Error>) {
        do{
            let file: URL = try result.get()
            isNameEditorShown.toggle()
            self.addedOriginalFilename = file.lastPathComponent
            imageURLS[file.lastPathComponent] = file.absoluteString
            
                
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func terminateNameEditor(){
        isNameEditorShown = false
        
        Task{
            try await self.APIHandler.upsertImage(image: Data(contentsOf: URL(string: self.imageURLS[addedOriginalFilename]!)!),
                filename: "\(addedFilename).\(addedOriginalFilename.split(separator: ".").last!)")
            self.imageURLS.removeValue(forKey: addedOriginalFilename)
            self.imageURLS = await self.APIHandler.fetchImageURLS()
        }
        
         
    }
    
    
    
    func generateEvent() -> [String:Any]{
        
        var sideURLS:[String] = []
        for url in self.sideImages {
            if (self.imageURLS.keys.contains(url)) {
                sideURLS.append(imageURLS[url]!)
            }
        }
        
        return [
            "timeStart":DateToIntList(date: self.dateStart),
            "timeEnd":DateToIntList(date: self.dateEnd),
            "color": String(self.color.description),
            "systemImage":self.selectedSymbol,
            "mainImageURL":self.imageURLS[self.mainImage] ?? "",
            "sideImageURLS":sideURLS
        ]
    }
    
    var body : some View {
        NavigationStack{
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
                    Button(action:{fileImporterPresented = true})
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
                    Spacer()
                }
                HStack{
                    Text("Main image")
                    
                    if imageURLS.count > 0{
                        Picker(selection: $mainImage, label: Text("Select image"))
                        {
                            ForEach(imageURLS.keys.sorted(), id: \.self){
                                key in
                                Text(key).tag(key)
                                
                            }
                        }

                        .buttonBorderShape(.capsule)
                        .pickerStyle(NavigationLinkPickerStyle())
                        .padding(.horizontal, 10)
                    }
                    
                }
                .padding(.horizontal, 10)
                ScrollView(.vertical){
                    ForEach(sideImages.indices, id: \.self){ imageIndex in
                        HStack{
                            Text("Side image \(imageIndex + 1)")
                            
                            if imageURLS.count > 0{
                                Picker(selection: $sideImages[imageIndex], label: Text("Select image"))
                                {
                                    ForEach(imageURLS.keys.sorted(), id: \.self){
                                        key in
                                        Text(key).tag(key)
                                        
                                    }
                                }

                                .buttonBorderShape(.capsule)
                                .pickerStyle(NavigationLinkPickerStyle())
                                .padding(.horizontal, 10)
                            }
                            
                        }
                        .padding(.horizontal, 10)
                        
                    }
                    Button("Add side image"){
                        sideImages.append("")
                    }
                    .padding(10)
                    .buttonBorderShape(.capsule)
                }
                Button ("Submit"){
                    self.updateEvents()
                }
                .buttonStyle(.bordered)
                .padding(10)
                .background(Color.blue)
                .buttonBorderShape(.capsule)
                
            }
        }
        .fileImporter(isPresented: $fileImporterPresented, allowedContentTypes: [.directory, .png], onCompletion: fileCallback)
        .sheet(isPresented: $isNameEditorShown){ NameEditor($addedFilename, callback: terminateNameEditor)}
            
                
    }
    
    func updateEvents()
    {
        
        self.updateCallback(self.generateEvent())
        dismiss()
        
    }
}


struct CalendarView: View {
    let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    let minuteHeight = 2
    let HStackXOffset = CGFloat(Double(50))
    @State var eventList: [Event]
    let APIHandler: ServerAPIinteractor
    let imageList: [String:String]
    @State var weekStartDate: Date = getWeekStartDate(.now)
    init(eventList: [Event], APIHandler: ServerAPIinteractor, imageList: [String:String]) {
        self.eventList = eventList
        self.APIHandler = APIHandler
        self.imageList = imageList
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
                NavigationLink(destination:
                                EventEditor(imageURLS:imageList,
                                            APIHandler:self.APIHandler,
                                            callback:self.updateEvents)){
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
    
    init(dictionary: [String:Any]){
        self.systemImage = dictionary["systemImage"] as! String
        self.color = dictionary["color"] as! String
        let timeStart = dictionary["timeStart"] as! [Int]
        let timeEnd = dictionary["timeEnd"] as! [Int]
        self.dateTimeStart = dateFrom(timeStart[0], timeStart[1], timeStart[2], timeStart[3], timeStart[4])
        self.dateTimeEnd = dateFrom(timeEnd[0], timeEnd[1], timeEnd[2], timeEnd[3], timeEnd[4])
        self.minuteHeight = 2
        self.mainImageURL = dictionary["mainImageURL"] as! String
        self.sideImagesURL = dictionary["sideImageURLS"] as! [String]
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
    
    func getDictionary() -> [String: Any] {
        return  [
            "timeStart":DateToIntList(date: self.dateTimeStart),
            "timeEnd":DateToIntList(date: self.dateTimeEnd),
            "color":self.color,
            "systemImage":self.systemImage,
            "mainImageURL":self.mainImageURL,
            "sideImageURLS":self.sideImagesURL
        ]
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
//                        dateTimeStart: dateFrom(19,9    ,2024,0,0),
//                        dateTimeEnd: dateFrom(19,9,2024,0, 30),
//                        minuteHeight: 2,
//                        mainImageURL: "abobus", sideImagesURL: ["abobusMnogo"]),
//                     Event (
//                         systemImage: "fork.knife",
//                         color: "Teal",
//                         dateTimeStart: dateFrom(11,9,2024,0,0),
//                         dateTimeEnd: dateFrom(11,9,2024,1, 15),
//                         minuteHeight: 2,
//                         mainImageURL: "abobus", sideImagesURL: ["abobusMnogo"])],
//                 APIHandler: ServerAPIinteractor(), imageList:[:])
    EventEditor(imageURLS:["b":"a"], APIHandler: ServerAPIinteractor(), callback: { _ in print("none") })
}


