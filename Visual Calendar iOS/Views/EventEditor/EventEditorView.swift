//
//  EventEditor.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 23.01.2025.
//

import SwiftUI
import MCEmojiPicker


struct EventEditor: View {
    // MARK: - Symbol Picker State
    @State private var isSymbolPickerShown = false
    @State private var selectedSymbol = "😀"
    
    // MARK: - Color State
    @State private var backgroundColor: String = ""
    @State private var textColor: String = ""
    
    // MARK: - Date State
    @State private var dateStart = Date()
    @State private var dateEnd = Date().addingTimeInterval(TimeInterval(60*60))
    @State private var repeatType: EventRepetitionType = .once
    
    // MARK: - Image State
    @State private var mainImageURL = ""
    @State private var sideImagesURL: [String] = []
    
    // MARK: - File Import State
    @State private var fileImporterPresented = false
    @State private var isNameEditorShown = false
    @State private var addedFilename = "Unnamed"
    @State private var addedFilePath: URL? = nil
    
    // MARK: - Event Details State
    @State private var title: String = ""
    @State private var saveAsPreset: Bool = false
    
    // MARK: - Validation State
    @State private var validationError: String? = nil
    
    // MARK: - Preset Upload Warning and Result State
    @State private var showPresetUploadWarning = false
    @State private var isForced:Bool = false
    

    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var APIHandler: APIHandler
    @EnvironmentObject var warningHandler: WarningHandler
    @EnvironmentObject var viewSwitcher: ViewSwitcher
    
    let updateCallback: (Event) async throws-> Void
    
    func validateInput() -> Bool {
        if dateStart >= dateEnd {
            validationError = "Start time must be before end time."
            return false
        }
        if mainImageURL.isEmpty {
            validationError = "Please select a main image."
            return false
        }
        if backgroundColor.isEmpty {
            validationError = "Please select a background color."
            return false
        }

        validationError = nil
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                
                TitleManagement(title:$title, api: APIHandler, saveAsPreset: $saveAsPreset, applyPreset: applyPreset)
                EventDateSection(dateStart: $dateStart, dateEnd: $dateEnd, repeatType: $repeatType)

                EventAppearanceSection(selectedSymbol: $selectedSymbol, isSymbolPickerShown: $isSymbolPickerShown, backgroundColor: $backgroundColor, textColor: $textColor)
                EventContentSection(
                    fileImporterPresented: $fileImporterPresented,
                    mainImage: $mainImageURL,
                    sideImages: $sideImagesURL,
                )

                Section {
                    if let error = validationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button("Submit") {
                        beginSubmission(force: false)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .navigationTitle("Edit Event")
            .fileImporter(isPresented: $fileImporterPresented, allowedContentTypes: [.image], onCompletion: fileCallback)
            .sheet(isPresented: $isNameEditorShown) {
                NameEditor(name: $addedFilename, fileURL: $addedFilePath, isPresented: $isNameEditorShown)
            }
            .sheet(isPresented: $showPresetUploadWarning) {
                DuplicatePresetWarning(
                    isPresented: $showPresetUploadWarning,
                    onContinue: {
                        forceSubmission()
                    }
                )
            }
        }
    }

    func fileCallback(_ result: Result<URL, Error>) {
        do {
            let file = try result.get()
            addedFilePath = file
            isNameEditorShown = true
        } catch {
            print(error.localizedDescription)
        }
    }
    func forceSubmission() {
        beginSubmission(force: true)
    }
    
    func beginSubmission(force: Bool = false) {
        if !saveAsPreset {
            updateEvents()
            return
        }
        AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: APIHandler, viewSwitcher: viewSwitcher) {
            try await APIHandler.fetchPresets()
            if APIHandler.presets.keys.contains(title) && !force {
                await MainActor.run {
                    showPresetUploadWarning = true
                }
                return
            }
            
            let current_preset = Preset(
                selectedSymbol: selectedSymbol,
                backgroundColor: backgroundColor,
                mainImageURL: mainImageURL,
                sideImageURLs: sideImagesURL
            )
            
            try await APIHandler.upsertPresets(title: title, preset: current_preset)
            
            await MainActor.run {
                updateEvents()
            }
        }
        
    }
    
    func updateEvents() {
        guard validateInput() else { return }
        print(repeatType)
        let event = generateEvent()
        print(event.repetitionType)
        AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: APIHandler, viewSwitcher: viewSwitcher) {
            var currentEvents = APIHandler.eventList

            if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
                currentEvents[index] = event
            } else {
                currentEvents.append(event)
            }

            try await APIHandler.upsertEvents(currentEvents)

            await MainActor.run {
                dismiss()
            }
        }
    }
    
    struct UploadResultMessage: Identifiable {
        let id = UUID()
        let message: String
    }
}

private extension EventEditor {
    func applyPreset(title: String, preset: Preset) {
        print(preset.mainImageURL)
        self.title = title
        selectedSymbol = preset.selectedSymbol
        backgroundColor = preset.backgroundColor
        mainImageURL = preset.mainImageURL
        sideImagesURL = preset.sideImageURLs
    }
    
    func handleURL(_ url: URL) -> Data? {
        guard url.startAccessingSecurityScopedResource() else {
            print("Permission denied to access file.")
            return nil
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let data = try Data(contentsOf: url)
            print("Loaded \(data.count) bytes.")
            return data
            
        } catch {
            print("Error loading file: \(error)")
            return nil
        }
        
    }
}

private extension EventEditor {
    func generateEvent() -> Event {
        let event: Event = Event(
            systemImage: selectedSymbol,
            dateTimeStart: dateStart,
            dateTimeEnd: dateEnd,
            mainImageURL: mainImageURL,
            sideImagesURL: sideImagesURL,
            id:UUID(),
            bgcolor: backgroundColor,
            textcolor: textColor,
            repetitionType: repeatType.displayName,
            reactionString: ""
            )
        return event
            
    }
}


struct DuplicatePresetWarning: View {
    @Binding var isPresented: Bool
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("A preset with this title already exists. Do you want to overwrite it?")
                .padding()
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                Spacer()
                Button("Continue") {
                    isPresented = false
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.leading, .trailing, .bottom])
        }
        .presentationDetents([.fraction(0.3)])
    }
}
