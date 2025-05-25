//
//  EventEditor.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 23.01.2025.
//

import SwiftUI
import SymbolPicker

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

struct DateSelector : View {
    @Binding var dateStart: Date
    @Binding var dateEnd: Date
    
    var body: some View {
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
        }
    }
}

struct AppearanceSelector: View{
    @Binding var selectedSymbol: String
    @Binding var isSymbolPickerShown: Bool
    
    var body: some View{
        VStack{
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
        }
    }
}

struct ContentEditor: View {
    @Binding var fileImporterPresented: Bool
    @Binding var imageURLS:[String:String]
    @Binding var mainImage: String
    @Binding var sideImages:[String]
    var body: some View {
        VStack{
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
            
            self.addedOriginalFilename = file.lastPathComponent
            imageURLS[file.lastPathComponent] = file.absoluteString
            isNameEditorShown.toggle()
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
            await APIHandler.fetchImageURLS()
            
            self.imageURLS = self.APIHandler.images
        }
    }
    
    func generateEventDictionary() -> [String:Any]{
        
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
                DateSelector(dateStart: $dateStart, dateEnd: $dateEnd)
                
                AppearanceSelector(selectedSymbol: $selectedSymbol, isSymbolPickerShown: $isSymbolPickerShown)
                
                ContentEditor(fileImporterPresented: $fileImporterPresented,imageURLS: $imageURLS, mainImage: $mainImage, sideImages: $sideImages)
                
                
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
        self.updateCallback(self.generateEventDictionary())
        dismiss()
        
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
                            .fill(Color.accentColor).opacity(0.5)
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

#Preview {
    EventEditor(imageURLS:["b":"a"], APIHandler: ServerAPIinteractor(), callback: { _ in print("none") })
}


