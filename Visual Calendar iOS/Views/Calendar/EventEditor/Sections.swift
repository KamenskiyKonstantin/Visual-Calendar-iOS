//
//  Sections.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 26.05.2025.
//

import SwiftUI
import MCEmojiPicker

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
    @Binding var repeatType: EventRepetitionType
    
    var body: some View {
        Section(header: Text("Time Interval")) {
            DatePicker("Start Date", selection: $dateStart, displayedComponents: [.date, .hourAndMinute])
            DatePicker("End Date", selection: $dateEnd, displayedComponents: [.date, .hourAndMinute])
            
            Picker("Repeat", selection: $repeatType) {
                ForEach(EventRepetitionType.allValues, id: \.self) { option in
                    Text(String(option.displayName)).tag(option)
                }
            }
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

                    Text("Select emoji")
                    Spacer()
                    Button("Change") {
                        isSymbolPickerShown.toggle()
                    }
                    .emojiPicker(isPresented: $isSymbolPickerShown, selectedEmoji: $selectedSymbol)
                    .buttonStyle(.bordered)
                    Text(selectedSymbol)
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
            }
            
            
        }
    }
}

struct EventContentSection: View {
    @Binding var fileImporterPresented: Bool
    @Binding var mainImage: String
    @Binding var sideImages: [String]
    @ObservedObject var api: APIHandler
    @State private var isLibrarySheetShown = false
    
    
    var body: some View {
        Section(header: Text("Content")) {
            Button {
                isLibrarySheetShown = true
            } label: {
                Label("Add Library", systemImage: "books.vertical")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .sheet(isPresented: $isLibrarySheetShown) {
                LibrarySelectionSheet(api: api) {
                    isLibrarySheetShown = false
                }
            }
            
            //Manual file add
            Button {
                fileImporterPresented = true
            } label: {
                Label("Add Image", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            
            if !api.images.isEmpty {
                PickerView(api: api, name: "main Image", selection: self.$mainImage)
            }
            
            if !sideImages.isEmpty {
                ForEach(sideImages.indices, id: \.self) { index in
                    if !api.images.isEmpty {
                        PickerView(api:api, name: "Side image \(index+1)", selection: self.$sideImages[index])
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
    @ObservedObject var api: APIHandler
    let name: String
    
    @Binding var selection: String
    
    var body: some View {
        HStack{
            Text(name)
            Spacer()
            Picker("", selection: self.$selection) {
                let imageURLS = self.api.images
                Text("Select \(name)").tag("")
                ForEach(imageURLS.keys.sorted(), id: \.self) { group in
                    Section(header: Text(group)){
                        ForEach(imageURLS[group]?.sorted(by: { $0.key < $1.key }) ?? [], id: \.key) { key, value in
                            Text(key).tag(value)
                        }
                        
                    }
                    
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity)
        }
    }
    
}

struct LibrarySelectionSheet: View {
    @ObservedObject var api: APIHandler
    var dismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(api.libraryEntries, id: \.self) { entry in
                    Button(entry) {
                        Task {
                            do {
                                try await api.addLibrary(entry)
                                dismiss()
                            } catch {
                                print("Error adding library: \(error)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Public Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TitleManagement: View {
    @Binding var title: String
    @ObservedObject var api: APIHandler
    @Binding var saveAsPreset: Bool
    var applyPreset: (String, Preset) -> Void  // Add this to the parent when calling this view

    var body: some View {
        Section(header: Text("Quick Setup").font(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                
                // Label + TextEditor
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextEditor(text: $title)
                        .frame(height: 80)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                // Preset suggestion
                
                let preset = bestMatchingKeyword(from: title, keywords: Array(api.presets.keys))
                

                if preset != "Custom", let matchedPreset = api.presets[preset] {
                    Button(action: {
                        applyPreset(preset, matchedPreset)
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle")
                            Text("Use preset: \(preset)")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }

                // Save toggle
                Toggle("Save as new preset", isOn: $saveAsPreset)
            }
            .padding(.vertical, 4)
        }
    }
}
