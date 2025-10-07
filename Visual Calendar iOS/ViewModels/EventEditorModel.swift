//
//  EventEditorModelProtocol.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 05.10.2025.
//


import Foundation
import SwiftUI

@MainActor
protocol EventEditorModelProtocol: ObservableObject {
    var title: String { get set }
    var selectedSymbol: String { get set }

    var backgroundColor: String { get set }
    var textColor: String { get set }

    var dateStart: Date { get set }
    var dateEnd: Date { get set }
    var repeatType: EventRepetitionType { get set }

    var mainImageURL: String { get set }
    var sideImagesURL: [String] { get set }

    var saveAsPreset: Bool { get set }
    var validationError: String? { get }

    var showPresetUploadWarning: Bool { get set }
    var isForced: Bool { get set }

    var fileImporterPresented: Bool { get set }
    var isNameEditorShown: Bool { get set }
    var addedFilename: String { get set }
    var addedFilePath: URL? { get set }

    var dismissAction: () -> Void { get set }

    func submit()
    func forceSubmit()
    func deleteEvent()
    func applyPreset(title: String, preset: Preset)
    func fileCallback(_ result: Result<URL, Error>)
}

@MainActor
final class EventEditorModel: ObservableObject {
    // MARK: internal state
    private var hasLoaded: Bool = false
    private var dismissalCallback: (() -> Void)?
    
    // MARK: - Dependencies
    private let api: APIHandler
    private let warningHandler: WarningHandler
    private let viewSwitcher: ViewSwitcher
    
    // MARK: Callbacks
    private var fetchEventsCallback: (() async -> Void)?
    private var fetchImagesCallback: (() async -> Void)?
    

    // MARK: - Associated Event
    private(set) var eventID: UUID? = nil
    

    // MARK: - Form State
    @Published var title: String = ""
    
    @Published var selectedSymbol: String = "😀"
    @Published var isEmojiPickerShown: Bool = false

    @Published var backgroundColor: String = ""
    @Published var textColor: String = ""

    @Published var dateStart: Date = Date()
    @Published var dateEnd: Date = Date().addingTimeInterval(3600)
    @Published var repeatType: EventRepetitionType = .once

    @Published var mainImageURL: String = ""
    @Published var sideImagesURL: [String] = []

    @Published var saveAsPreset: Bool = false
    @Published var validationError: String?

    @Published var showPresetUploadWarning: Bool = false
    @Published var isForced: Bool = false

    @Published var fileImporterPresented: Bool = false
    @Published var isNameEditorShown: Bool = false
    @Published var addedFilename: String = "Unnamed"
    @Published var addedFilePath: URL?
    
    
    @Published var isLoading: Bool = false
    
    @Published var isSubmitting: Bool = false
    
    
    @Published var presets: [Preset] = []
    @Published var images: [String: [any NamedURL]] = [:]
    @Published var connectedLibraries: [LibraryInfo] = []
    @Published var allLibraries: [LibraryInfo] = []

    // MARK: - Init
    init(
        api: APIHandler,
        warningHandler: WarningHandler,
        viewSwitcher: ViewSwitcher
    ) {
        self.api = api
        self.warningHandler = warningHandler
        self.viewSwitcher = viewSwitcher
    }
    
    // MARK: Callbacks
    func setEventFetchCallback(_ callback: @escaping () async -> Void) {
        self.fetchEventsCallback = callback
    }
    
    func setImageFetchCallback(_ callback: @escaping () async -> Void) {
        self.fetchImagesCallback = callback
    }

    // MARK: Load
    func setEvent(_ event: Event) {
        self.eventID = event.id
        self.selectedSymbol = event.systemImage
        self.backgroundColor = event.backgroundColor
        self.textColor = event.textColor
        self.dateStart = event.dateTimeStart
        self.dateEnd = event.dateTimeEnd
        self.repeatType = event.repetitionType
        self.mainImageURL = event.mainImageURL
        self.sideImagesURL = event.sideImagesURL
        self.title = "Event"
    }
    
    func setDismissal(_ dismiss: @escaping () -> Void){
        self.dismissalCallback = dismiss
    }
    
    func load()  {
        guard !hasLoaded else {return}
        isLoading = true
        Task{

            presets = await api.fetchPresets()
            allLibraries = await api.fetchExistingLibraries()
            connectedLibraries = await api.fetchConnectedLibraries()
            images = await api.fetchImages(connectedLibraries)
            
            isLoading = false
            hasLoaded = true
        }
    }
    
    func reset() {
        self.eventID = nil
        self.selectedSymbol = "calendar"
        self.backgroundColor = "#007AFF"
        self.textColor = "#FFFFFF"
        self.dateStart = Date()
        self.dateEnd = Date().addingTimeInterval(3600)
        self.repeatType = .once
        self.mainImageURL = ""
        self.sideImagesURL = []
        self.hasLoaded = false
    }

    // MARK: Helpers
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

    private func generateEvent() -> Event {
        return Event(
            systemImage: selectedSymbol,
            dateTimeStart: dateStart,
            dateTimeEnd: dateEnd,
            mainImageURL: mainImageURL,
            sideImagesURL: sideImagesURL,
            id: eventID ?? UUID(),
            bgcolor: backgroundColor,
            textcolor: textColor,
            repetitionType: repeatType.displayName,
            reactionString: ""
        )
    }

    // MARK: - Submission
    func submit() {
        if saveAsPreset {handlePresetSubmission()}
        else {updateOrCreateEvent()}

    }

    func forceSubmit() {
        isForced = true
        submit()
    }
    
    
    // MARK: Event Service
    private func updateOrCreateEvent() {
        guard validateInput() else { return }
        guard self.fetchEventsCallback != nil else { fatalError("Fetch Events Callback is nil, required for updateOrCreateEvent") }
        guard self.dismissalCallback != nil else { fatalError("Dismissal Callback is nil, required for updateOrCreateEvent") }
        
        let id = eventID
        
        print("[-MODEL/EDITOR-] Saving event, UUID: \(eventID?.uuidString ?? "nil")")
        let newEvent = generateEvent()
        print("[-MODEL/EDITOR-] Saving event, UUID: \(eventID?.uuidString ?? "nil")")
        
        
        Task{
            var success: Bool
            isSubmitting = true
            
            if id != nil {
                print("[-MODEL/EDITOR-] Saving event, UUID: \(id!.uuidString), as UUID exists choosing to UPDATE")
                success = await api.updateEvent(newEvent)
            } else {
                success = await api.createEvent(newEvent)
            }
            if success {
                await self.fetchEventsCallback!()
            }
            
            isSubmitting = false
            dismissalCallback!()
            reset()

        }
    }
    
    func deleteEvent() {
        guard let id = eventID else { return }
        guard self.fetchEventsCallback != nil else { fatalError("Fetch Events Callback is nil, required for deleteEvent") }
        guard self.dismissalCallback != nil else { fatalError("Dismissal Callback is nil, required for deleteEvent") }
        
        Task {
            defer {
                reset()
            }
            let success = await api.deleteEvent(id)
            if success {
                await self.fetchEventsCallback!()
                dismissalCallback!()
            } else {
                validationError = "Failed to delete event."
            }
        }
    }

    // MARK: Presets handling
    private func handlePresetSubmission() {
        Task{
            let presets = await api.fetchPresets()
            let presetExists = presets.contains { $0.presetName == title }
            
            
            if presetExists && !isForced {
                showPresetUploadWarning = true
                return
            }
            
            let preset = Preset(
                selectedSymbol: selectedSymbol,
                backgroundColor: backgroundColor,
                mainImageURL: mainImageURL,
                sideImageURLs: sideImagesURL
            )
            
            // Create or update preset
            if presetExists {
                _ = await api.updatePreset(preset: preset)
            } else {
                _ = await api.createPreset(preset: preset)
            }
            
            
            updateOrCreateEvent()
        }
    }

    func applyPreset(title: String, preset: Preset) {
        self.title = title
        selectedSymbol = preset.selectedSymbol
        backgroundColor = preset.backgroundColor
        mainImageURL = preset.mainImageURL
        sideImagesURL = preset.sideImageURLs
    }

    // MARK: Image Handling
    func fileCallback(_ result: Result<URL, Error>) {
        do {
            let file = try result.get()
            addedFilePath = file
            isNameEditorShown = true
        } catch {
            print("Failed to access file: \(error)")
        }
    }
    
    func createUserImage(with name: String) {
        guard let filePath = addedFilePath else {
            return
        }
        guard self.fetchImagesCallback != nil else {
            fatalError("fetchImagesCallback is nil, required for creating user image")
        }
        
        Task {
            do {
                let imageData = try Data(contentsOf: filePath)
                let _ = await api.createImage(imageData, name)
                
                await fetchEventsCallback!()
                self.images = await self.api.fetchImages(self.connectedLibraries)
            }
            catch {
                warningHandler.showWarning("Failed to read file")
            }
        }
    }
        
    func addLibrary(libraryName: String){
        guard self.fetchImagesCallback != nil else {
            fatalError(
                "fetchImagesCallback is nil, required for adding library"
            )
        }
        
        Task{
            _ = await api.addLibrary(libraryName)
            self.connectedLibraries = await self.api.fetchConnectedLibraries()
            await self.fetchEventsCallback!()
            self.images = await self.api.fetchImages(self.connectedLibraries)
            
        }
    }



}
