////
////  Sections.swift
////  Visual Calendar iOS
////
////  Created by Konstantin Kamenskiy on 26.05.2025.
////

import SwiftUI
import MCEmojiPicker

struct NameEditor: View {
    @ObservedObject var viewModel: EventEditorModel
    
    @Binding var name: String
    @Binding var fileURL: URL?
    @Binding var isPresented: Bool

    @State private var isUploading = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter a name for your image")) {
                    TextField("Image name", text: $name)
                        .disabled(isUploading)
                }

                if isUploading {
                    Section {
                        ProgressView("Uploading...")
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }

                Section {
                    Button("Upload") {
                        viewModel.createUserImage(with: name)
                    }
                    .disabled(isUploading || name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Upload File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }.disabled(isUploading)
                }
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
    @ObservedObject var viewModel: EventEditorModel
    
    
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
                        viewModel.isEmojiPickerShown = true
                    }
                    .emojiPicker(isPresented: $viewModel.isEmojiPickerShown, selectedEmoji: $viewModel.selectedSymbol)
                    .buttonStyle(.bordered)
                    Text(viewModel.selectedSymbol)
                }
                HStack {
                    Text("Select background color")
                    Spacer()
                    Picker("", selection: self.$viewModel.backgroundColor) {
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
    
    @State private var isLibrarySheetShown = false
    
    @ObservedObject var viewModel: EventEditorModel
    
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
                LibrarySelectionSheet(dismiss: {isLibrarySheetShown = false}, viewModel: viewModel)
            }
            
            //Manual file add
            Button {
                fileImporterPresented = true
            } label: {
                Label("Add Image", systemImage: "plus")
            }
            .buttonStyle(.bordered)
            
            if !viewModel.images.isEmpty {
                PickerView(viewModel: viewModel, name: "main Image", selection: self.$viewModel.mainImageURL)
            }
            
            if !sideImages.isEmpty {
                ForEach(sideImages.indices, id: \.self) { index in
                    if !viewModel.images.isEmpty {
                        PickerView(viewModel: viewModel, name: "Side image \(index+1)", selection: self.$viewModel.sideImagesURL[index])
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
    @ObservedObject var viewModel: EventEditorModel
    let name: String
    
    @Binding var selection: String
    
    var groupedImageSections: [(group: String, items: [any NamedURL])] {
        viewModel.images.map { (key, value) in
            (group: key, items: value.sorted { $0.display_name < $1.display_name })
        }.sorted { $0.group < $1.group }
    }
    
    var body: some View {
        HStack{
            Text(name)
            Spacer()
            Picker("", selection: $selection) {
                Text("Select \(name)").tag("")

                ForEach(groupedImageSections, id: \.group) { section in
                    Section(header: Text(section.group)) {
                        ForEach(section.items, id: \.file_url) { item in
                            Text(item.display_name).tag(item.file_url)
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
    var dismiss: () -> Void
    
    @ObservedObject var viewModel: EventEditorModel
    
    @State private var isProcessing = false
    @State private var selectedLibrary: String?

    var body: some View {
        List(viewModel.allLibraries, id: \.self) { library in
            Button {
                selectedLibrary = library.system_name
                isProcessing = true
                Task {
                    await handleAdd(library: library)
                }
            } label: {
                HStack {
                    Text(library.localized_name)
                    Spacer()
                    if isProcessing && selectedLibrary == library.system_name {
                        ProgressView()
                    }
                }
            }
            .disabled(isProcessing)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss)
                    .disabled(isProcessing)
            }
        }
    }

    private func handleAdd(library: LibraryInfo) async {
        viewModel.addLibrary(libraryName: library.system_name)
        isProcessing = false
        selectedLibrary = nil
    }
}

struct TitleManagement: View {
    @Binding var title: String
    @Binding var saveAsPreset: Bool
    
    @ObservedObject var viewModel: EventEditorModel
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
                let preset = bestMatchingKeyword(from: title, keywords: Array(viewModel.presets.compactMap({$0.presetName})))
                

                if preset != "Custom", let matchedPreset = viewModel.presets.first(where:{$0.presetName == preset}) {
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
