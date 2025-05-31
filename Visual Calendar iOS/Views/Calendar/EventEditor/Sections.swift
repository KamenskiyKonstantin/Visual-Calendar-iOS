//
//  Sections.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 26.05.2025.
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


struct EventDateSection: View {
    @Binding var dateStart: Date
    @Binding var dateEnd: Date

    var body: some View {
        Section(header: Text("Time Interval")) {
            DatePicker("Start Date", selection: $dateStart, displayedComponents: [.date, .hourAndMinute])
            DatePicker("End Date", selection: $dateEnd, displayedComponents: [.date, .hourAndMinute])
        }
    }
}

struct EventAppearanceSection: View {
    @Binding var selectedSymbol: String
    @Binding var isSymbolPickerShown: Bool
    @Binding var backgroundColor: String
    @Binding var textColor: String

    let colorOptions = [
      "Black", "Blue", "Brown", "Cyan", "Gray", "Green", "Indigo", "Mint",
      "Orange", "Pink", "Purple", "Red", "Teal", "White", "Yellow"
    ]
    var body: some View {
        Section(header: Text("Appearance")) {
            VStack{
                HStack {
                    Label("Edit Icon", systemImage: selectedSymbol)
                        .font(.headline)
                    Spacer()
                    Button("Change") {
                        isSymbolPickerShown = true
                    }
                    .buttonStyle(.bordered)
                }
                HStack {
                    Text("Select background color")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: self.$backgroundColor) {
                        Text("Select a color").tag("")
                        ForEach(colorOptions, id:\.self){
                            color in
                            Text(color).tag(color)
                        }
                    }
                }
                HStack {
                    Text("Select pictogram color")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: self.$textColor, ) {
                        Text("Select a color").tag("")
                        ForEach(colorOptions, id:\.self){
                            color in
                            Text(color).tag(color)
                        }
                    }
                }
            }
           
            
        }
    }
}

struct EventContentSection: View {
    @Binding var fileImporterPresented: Bool
    @Binding var imageURLS: [String: [String: String]]
    @Binding var mainImage: String
    @Binding var sideImages: [String]

    var body: some View {
        Section(header: Text("Content")) {
            Button {
                fileImporterPresented = true
            } label: {
                Label("Add Image", systemImage: "plus")
            }
            .buttonStyle(.bordered)

            if !imageURLS.isEmpty {
                PickerView(imageURLS: imageURLS, name: "main Image", selection: self.$mainImage)
            }

            if !sideImages.isEmpty {
                ForEach(sideImages.indices, id: \.self) { index in
                    HStack {
                        Text("Side Image \(index + 1)")
                        Spacer()
                        if !imageURLS.isEmpty {
                            PickerView(imageURLS: self.imageURLS, name: "side image", selection: self.$sideImages[index])
                        }
                    }
                }
            }

            Button("Add Side Image") {
                sideImages.append("")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
    }
}

struct PickerView: View{
    let imageURLS: [String: [String: String]]
    let name: String
    
    @Binding var selection: String
    
    var body: some View {
        Picker(self.name, selection: self.$selection) {
            
            ForEach(imageURLS.keys.sorted(), id: \.self) { group in
                Text("Select \(name)").tag("")
                Section(header: Text(group)){
                    ForEach(imageURLS[group]?.keys.sorted() ?? [""], id: \.self){key in
                        Text(key).tag(key)
                    }
                    
                }
                
            }
        }
        .pickerStyle(MenuPickerStyle())
        .frame(maxWidth: 150)
    }
   
}
