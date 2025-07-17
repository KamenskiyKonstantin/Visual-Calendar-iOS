//
//  APIHandler.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 15.07.2025.
//


//
//  FunctionalClasses.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//

import Foundation
import Supabase
import SwiftyJSON
import Combine

// MARK: - APIHandler (Coordinator)
@MainActor
class APIHandler: ObservableObject {
    private let authService: AuthService
    private let imageService: ImageService
    private let eventService: EventService
    private let libraryService: LibraryService
    private let presetService: PresetService
    private let apiClient: SupabaseClient

    @Published private(set) var eventList: [Event] = []
    @Published private(set) var images: [String:[NamedURL]] = [:]
    @Published private(set) var availableLibraries: [LibraryInfo] = []
    @Published private(set) var presets: [String: Preset] = [:]
    
    private var fetchTimer: AnyCancellable?

    init() {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://wlviarpvbxdaoytfeqnm.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsdmlhcnB2YnhkYW95dGZlcW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIxNTk0MzksImV4cCI6MjAzNzczNTQzOX0.zoQJTA3Tu_fpe24BrxDjhMtlfxfd_3Nx8TM1t8V3PK0",
            options: SupabaseClientOptions(
                auth: .init(
                    storage: KeychainLocalStorage(service: "com.visualcalendar.supabase", accessGroup: nil),
                    flowType: .pkce
                )
    )
        )
        self.apiClient = client
        self.authService = AuthService(client: client)
        self.imageService = ImageService(client: client)
        self.eventService = EventService(client: client)
        self.libraryService = LibraryService(client: client)
        self.presetService = PresetService(client: client)
        startPeriodicFetch()
        
    }

    var isAuthenticated: Bool {
        authService.isAuthenticated
    }

    func signUp(email: String, password: String) async throws {
        try await authService.signUp(email: email, password: password)
    }

    func login(email: String, password: String) async throws {
        try await authService.login(email: email, password: password)
    }

    func logout() async throws {
        try await authService.logout()
    }
    
    func fetchEvents() async throws {
        print("[\(Date.now.description)] Fetching events")
        let events = try await eventService.fetchEvents()
        print("Total of \(events.count) events fetched")
        self.eventList = events
        
    }

    func upsertEvents(_ events: [Event]) async throws {
        print("[\(Date.now.description)] Upserting a total of \(events.count) events")
        self.eventList = events
        try await eventService.upsertEvents(events)
        
    }
    
    func deleteEvent(_ uid: UUID) async throws{
        self.eventList.removeAll { $0.id == uid }
        try await eventService.upsertEvents(self.eventList)
        
    }

    func upsertImage(imageData: Data, filename: String) async throws {
        do {
            print("Delegating upsertion to ImageService, name: \(filename)")
            try await imageService.upsertImage(imageData: imageData, name: filename)
        } catch {
            throw error
        }
    }

    func fetchImageURLs() async throws {
        print("Fetching image URLs...")
        let systemNames = try await libraryService.fetchConnectedSystemNames()
        print("User has libs: \(systemNames)")
        let libraries = resolveLibraries(from: systemNames, using: availableLibraries)
        let result = try await imageService.fetchAllImageMappings(libraries: libraries)
        self.images = result
    }

    func fetchExistingLibraries() async throws {
        let result = try await libraryService.fetchAllLibraries()
        self.availableLibraries = result
    }

    func addLibrary(_ systemName: String) async throws {
        do {
            try await libraryService.addLibrary(systemName: systemName, from: availableLibraries)
            let libraries = try await libraryService.fetchAllLibraries()
            let result = try await imageService.fetchAllImageMappings(libraries: libraries)
            self.images = result
        } catch {
            if let postgrestError = error as? PostgrestError,
               postgrestError.message.contains("duplicate key value violates unique constraint") {
                throw APIError.duplicateLibrary
            } else {
                throw APIError.unknown(error)
            }
        }
    }

    func fetchPresets() async throws  {
        let presets = try await presetService.fetchPresets()
        self.presets = presets
    }
    
    func upsertPresets(title: String, preset: Preset) async throws {
        _ = try await presetService.uploadUserPreset(title: title, preset: preset)
        self.presets[title] = preset
    }
    
}

extension APIHandler {
    func startPeriodicFetch() {
            fetchTimer = Timer.publish(every: 60, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    Task{
                        try await self?.fetchEvents()
                    }
                }
        }
        
        func stopPeriodicFetch() {
            fetchTimer?.cancel()
            fetchTimer = nil
        }
}
