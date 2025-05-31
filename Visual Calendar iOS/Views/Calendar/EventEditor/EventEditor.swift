//
//  EventEditor.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 23.01.2025.
//

import SwiftUI
import SymbolPicker

struct EventEditor: View {
    @State private var isSymbolPickerShown = false
    @State private var selectedSymbol = "pencil"
    @State private var backgroundColor: String = ""
    @State private var textColor: String = ""
    @State private var dateStart = Date()
    @State private var dateEnd = Date()
    @State private var mainImage = ""
    @State private var fileImporterPresented = false
    @State private var sideImages: [String] = []
    @State public var imageURLS: [String: [String: String]]
    @State private var isNameEditorShown = false
    @State private var addedFilename = "Unnamed"
    @State private var addedOriginalFilename = ""
    
    @State private var validationError: String? = nil

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var APIHandler: APIHandler
    let updateCallback: (Event) async throws-> Void
    
    func validateInput() -> Bool {
        if dateStart >= dateEnd {
            validationError = "Start time must be before end time."
            return false
        }
        if mainImage.isEmpty {
            validationError = "Please select a main image."
            return false
        }
        if backgroundColor.isEmpty {
            validationError = "Please select a background color."
            return false
        }
        if textColor.isEmpty {
            validationError = "Please select a foreground color."
            return false
        }

        validationError = nil
        return true
    }
    
    func findImageURL(imageName: String) -> String? {
        for (_, value) in imageURLS {
            for (image_name, image_url) in value {
                if image_name == imageName {
                    return image_url
                }
            }
        }
        return nil
    }
    
    func convertImageListToURLLists(imageNames: [String]) -> [String] {
        var result: [String] = []
        for imageName in imageNames {
            if let imageURL = findImageURL(imageName: imageName) {
                result.append(imageURL)
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            Form {
                EventDateSection(dateStart: $dateStart, dateEnd: $dateEnd)

                EventAppearanceSection(selectedSymbol: $selectedSymbol, isSymbolPickerShown: $isSymbolPickerShown, backgroundColor: $backgroundColor, textColor: $textColor)

                EventContentSection(
                    fileImporterPresented: $fileImporterPresented,
                    imageURLS: $imageURLS,
                    mainImage: $mainImage,
                    sideImages: $sideImages
                )

                Section {
                    if let error = validationError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button("Submit") {
                        updateEvents()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
            }
            .navigationTitle("Edit Event")
            .sheet(isPresented: $isSymbolPickerShown) {
                SymbolPicker(symbol: $selectedSymbol)
            }
            .fileImporter(isPresented: $fileImporterPresented, allowedContentTypes: [.image], onCompletion: fileCallback)
            .sheet(isPresented: $isNameEditorShown) {
                NameEditor($addedFilename, callback: terminateNameEditor)
            }
        }
    }

    // MARK: - Helper Methods

    func fileCallback(_ result: Result<URL, Error>) {
        do {
            let file = try result.get()
            addedOriginalFilename = file.lastPathComponent
            if imageURLS["User"] == nil {
                imageURLS["User"] = [:]
            }
            imageURLS["User"]?[addedOriginalFilename] = file.absoluteString
            isNameEditorShown = true
        } catch {
            print(error.localizedDescription)
        }
    }

    func terminateNameEditor() {
        Task {
            guard let urlString = imageURLS["User"]?[addedOriginalFilename],
                  let url = URL(string: urlString),
                  let data = try? Data(contentsOf: url) else {
                return
            }

            let ext = addedOriginalFilename.split(separator: ".").last ?? "png"
            let newName = "\(addedFilename).\(ext)"

            try await APIHandler.upsertImage(imageData: data, filename: newName)
            try await APIHandler.fetchImageURLs()
            await MainActor.run {
                imageURLS = APIHandler.images
                isNameEditorShown = false
            }
            
        }
        
    }

    func generateEvent() -> Event {
        let event: Event = Event(
            systemImage: selectedSymbol,
            dateTimeStart: dateStart,
            dateTimeEnd: dateEnd,
            minuteHeight: defaultMinuteHeight,
            mainImageURL: findImageURL(imageName: mainImage) ?? "",
            sideImagesURL: convertImageListToURLLists(imageNames: sideImages),
            id:UUID(),
            bgcolor: backgroundColor,
            textcolor: textColor,
            )
        return event
            
    }

    func updateEvents() {
        guard validateInput() else { return }
        let event = generateEvent()
        Task {
            
                var currentEvents = APIHandler.eventList
                

                if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
                    currentEvents[index] = event // Update existing
                } else {
                    currentEvents.append(event) // Add new
                }
            do {
                // 3. Save to server
                try await APIHandler.upsertEvents(currentEvents)
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error upserting events: \(error)")
            }
            
        }
    }
}



#Preview {
    EventEditor(imageURLS:["User":["b":"a"]], APIHandler: APIHandler(), updateCallback: { _ in print("none") })
}


