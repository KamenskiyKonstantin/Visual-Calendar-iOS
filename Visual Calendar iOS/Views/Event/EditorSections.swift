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
    
    

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editor.Image.ImageName.Section.Header".localized)) {
                    TextField("Editor.Image.ImageName.Field.Placeholder".localized, text: $name)
                        .disabled(viewModel.isUploadingImage)
                }

                if viewModel.isUploadingImage {
                    Section {
                        ProgressView("Editor.Images.Uploading.ProgressView.Title".localized)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
                else{
                    Section {
                        Button("Editor.Image.Upload.Button.Title".localized) {
                            viewModel.createUserImage(with: name)
                            
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                }

                }
            }
            .navigationTitle("Editor.Image.Upload.Button.Title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Editor.Image.CancelUpload.Button.Title".localized) {
                        isPresented = false
                    }.disabled(viewModel.isUploadingImage)
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
        Section(header: Text("Editor.Date.Section.Header".localized)) {
            DatePicker("Editor.Date.Start.Picker.Label".localized, selection: $dateStart, displayedComponents: [.date, .hourAndMinute])
            DatePicker("Editor.Date.End.Picker.Label".localized, selection: $dateEnd, displayedComponents: [.date, .hourAndMinute])
            
            Picker("Editor.Date.Repetition.Picker.Label".localized, selection: $repeatType) {
                ForEach(EventRepetitionType.allValues, id: \.self) { option in
                    Text(String("RepetitionOptions.\(option.displayName)".localized)).tag(option)
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
        Section(header: Text("Editor.Appearance.Section.Header".localized)) {
            VStack{
                HStack {

                    Text("Editor.Appearance.Emoji.Picker.Label".localized)
                    Spacer()
                    Button("Editor.Appearance.PickEmojiButtonLabel".localized) {
                        viewModel.isEmojiPickerShown = true
                    }
                    .emojiPicker(isPresented: $viewModel.isEmojiPickerShown, selectedEmoji: $viewModel.selectedSymbol)
                    .buttonStyle(.bordered)
                    Text(viewModel.selectedSymbol)
                }
                HStack {
                    Text("Editor.Appearance.BackgroundColor.Picker.Label".localized)
                    Spacer()
                    Picker("", selection: self.$viewModel.backgroundColor) {
                        Text("Editor.Appearance.DefaultColor.Picker.Label".localized).tag("")
                        ForEach(colorOptions, id:\.self){
                            color in
                            Text("Color.\(color)".localized).tag(color)
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
        Section(header: Text("Editor.Content.Section.Header".localized)) {
            Button {
                isLibrarySheetShown = true
            } label: {
                Label("Editor.Content.AddLibrary.Button.Title".localized, systemImage: "books.vertical")
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
                Label("Editor.Content.AddFile.Button.Title".localized, systemImage: "plus")
            }
            .buttonStyle(.bordered)
            
            if !viewModel.images.isEmpty {
                PickerView(viewModel: viewModel, name: "Editor.Content.MainImage.Picker.Title".localized, selection: self.$viewModel.mainImageURL)
            }
            
            if !sideImages.isEmpty {
                ForEach(sideImages.indices, id: \.self) { index in
                    if !viewModel.images.isEmpty {
                        PickerView(viewModel: viewModel, name: String(format: "Editor.Content.SideImage.Picker.Title".localized, index+1), selection: self.$viewModel.sideImagesURL[index])
                    }
                }
            }
            
            Button("Editor.Content.AddSideImage.Button.Title".localized) {
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
                Text(String(format: "Editor.Picker.DefaultOption.Text".localized, name)).tag("")

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
                Button("Editor.AddLibrary.Cancel.Button.Title".localized, action: dismiss)
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
        Section(header: Text("Editor.QuickSetup.Section.Title".localized).font(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                
                // Label + TextEditor
                VStack(alignment: .leading, spacing: 4) {
                    Text("Editor.QuickSetup.Title.TextEdit.Label".localized)
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
                            Text(String(format: "Editor.QuickSetup.UsePreset.Button.Title".localized, preset))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }

                // Save toggle
                Toggle("Editor.QuickEdit.SaveAsPreset.Toggle.Title".localized, isOn: $saveAsPreset)
            }
            .padding(.vertical, 4)
        }
    }
}
