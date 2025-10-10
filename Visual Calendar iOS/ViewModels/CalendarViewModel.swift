//
//  CalendarViewModel.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 16.09.2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
protocol CalendarViewModelProtocol: ObservableObject {
    var currentDate: Date { get set }
    var deleteMode: Bool { get set }
    var mode: CalendarMode { get set }
    var events: [Event] { get set }
    var isLoading: Bool { get set }
    var isParentMode: Bool { get set }
    var reactions: [UUID: [EventReactionRow]] {get set}
    
    var minuteHeight: Int { get }
    var HStackXOffset: CGFloat { get }
    
    var detailViewModel: DetailViewModel { get }

    func load()
    func reset()
    func increaseDate()
    func decreaseDate()
    func setParentMode(_ isParentMode: Bool)
    func logout()
}



@MainActor
final class CalendarViewModel: CalendarViewModelProtocol {


    // MARK: - Dependencies
    private let api: APIHandler
    private let warningHandler: WarningHandler
    private let viewSwitcher: ViewSwitcher

    // MARK: - State
    @Published var currentDate: Date = Date().startOfWeek()
    @Published var deleteMode: Bool = false
    @Published var mode: CalendarMode = .Week
    @Published var events: [Event] = []
    @Published var images: [String: [any NamedURL]] = [:]
    @Published var imageURLs: [ImageMapping] = []

    @Published var libraries: [LibraryInfo] = []
    @Published var reactions: [UUID:[EventReactionRow]] = [:]
    @Published var isLoading: Bool = false
    @Published var isParentMode: Bool = false
    
    // MARK: Public APIs
    var detailViewModel: DetailViewModel
    var eventEditorModel: EventEditorModel
    
    // MARK: CONSTANTS
    var minuteHeight: Int = 2
    var HStackXOffset: CGFloat = 50

    private var hasLoaded = false
    private var fetchTimer: AnyCancellable?

    // MARK: - Init
    init(api: APIHandler, warningHandler: WarningHandler, viewSwitcher: ViewSwitcher) {
        self.api = api
        self.warningHandler = warningHandler
        self.viewSwitcher = viewSwitcher
        self.detailViewModel = DetailViewModel(api: api, warningHandler: warningHandler)
        self.eventEditorModel = EventEditorModel(api: api, warningHandler: warningHandler, viewSwitcher: viewSwitcher)
    }

    deinit {
        fetchTimer?.cancel()
    }

    // MARK: - Lifecycle

    func load() {
        guard !hasLoaded else {print("Loading Canceled: Calendar already loaded"); return }
        isLoading = true
        Task{

            
            self.detailViewModel.setFetchCallback(self.fetchReactions)
            self.eventEditorModel.setEventFetchCallback(self.fetchEvents)
            self.eventEditorModel.setImageFetchCallback(self.fetchImages)
            await fetchAll()
            _ = await api.addLibrary("standard_library")
            eventEditorModel.load()
        
            startPolling()
            hasLoaded = true
            isLoading = false
        }

    }

    func reset() {
        // reset state
        hasLoaded = false
        // reset timer
        fetchTimer?.cancel()
        
        eventEditorModel.reset()
        
        // reset all STATES
        events = []
        
        
    }

    // MARK: - Polling

    func startPolling(interval: TimeInterval = 10) {
        fetchTimer?.cancel()
        fetchTimer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    await self.fetchAll()
                }
            }
    }

    // MARK: - Auth

    func logout() {
        Task {
            reset()
            _ = await api.logout()
            viewSwitcher.switchToLogin()
        }
    }

    // MARK: - Calendar Controls

    func increaseDate() {
        switch mode {
        case .Week:
            currentDate = currentDate.startOfWeek().addingTimeInterval(60 * 60 * 24 * 7)
        case .Day:
            currentDate = currentDate.addingTimeInterval(60 * 60 * 24)
        }
    }

    func decreaseDate() {
        switch mode {
        case .Week:
            currentDate = currentDate.startOfWeek().addingTimeInterval(-60 * 60 * 24 * 7)
        case .Day:
            currentDate = currentDate.addingTimeInterval(-60 * 60 * 24)
        }
    }

    func setParentMode(_ isParentMode: Bool) {
        self.isParentMode = isParentMode
    }
    
    // MARK: CALLBACKS
    private func fetchReactions() async {
        async let fetchedReactions = await api.fetchAllReactions(for: events)
        let reactions = await fetchedReactions
        self.reactions = reactions
    }
    
    private func fetchEvents() async {
        async let fetchedEvents = api.fetchEvents()
        let events = await fetchedEvents
        self.events = events
        
        async let fetchedImageMappings = api.resolveImageURLs(for: events)
        let imagesMap = await fetchedImageMappings
        self.imageURLs = imagesMap
    }
    
    private func fetchImages() async {
        let libraries = await api.fetchConnectedLibraries()
        let imagesMap = await api.fetchImages(libraries)
        self.images = imagesMap
        self.libraries = libraries
    }
        

    // MARK: - Private Fetching Logic

    private func fetchAll() async {

        async let fetchedEvents = api.fetchEvents()
        let events = await fetchedEvents
        self.events = events
        
        async let fetchedReactions = api.fetchAllReactions(for: events)
        let reactions = await fetchedReactions
        self.reactions = reactions
        
        async let fetchedImageMappings = api.resolveImageURLs(for: events)
        let imagesMap = await fetchedImageMappings
        self.imageURLs = imagesMap

    }
}

//@MainActor
//final class MockCalendarViewModel: CalendarViewModelProtocol {
//    var detailViewModel: DetailViewModel = DetailViewModel()
//    
//    @Published var currentDate: Date = Date().startOfWeek()
//    @Published var deleteMode: Bool = false
//    @Published var mode: CalendarMode = .Week
//    @Published var events: [Event] = [Event.mock()]
//    @Published var isLoading: Bool = false
//    @Published var isParentMode: Bool = false
//
//    var minuteHeight: Int = 2
//    var HStackXOffset: CGFloat = 50
//
//    func load() {}
//    func reset() {}
//    
//    
//    func increaseDate() {
//        switch mode {
//        case .Week:
//            currentDate = currentDate.addingTimeInterval(60 * 60 * 24 * 7)
//        case .Day:
//            currentDate = currentDate.addingTimeInterval(60 * 60 * 24)
//        }
//    }
//
//    func decreaseDate() {
//        switch mode {
//        case .Week:
//            currentDate = currentDate.addingTimeInterval(-60 * 60 * 24 * 7)
//        case .Day:
//            currentDate = currentDate.addingTimeInterval(-60 * 60 * 24)
//        }
//    }
//    
//
//    func setParentMode(_ isParentMode: Bool) {
//        self.isParentMode = isParentMode
//    }
//
//    func logout() {
//        print("Logout triggered")
//    }
//
//    func updateEvents() {
//        print("Events updated")
//    }
//    
//    var withParentMode: Self {
//        self.isParentMode = true
//        return self
//    }
//}
