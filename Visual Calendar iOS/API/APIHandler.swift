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
                    flowType: .pkce,
                    
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

    // MARK: - Auth

    func signUp(email: String, password: String) async throws {
        try await wrap("signUp", requiresAuth: false) {
            try await authService.signUp(email: email, password: password)
        }
    }

    func login(email: String, password: String) async throws {
        try await wrap("login", requiresAuth: false) {
            try await authService.login(email: email, password: password)
        }
    }

    func logout() async throws {
        try await wrap("logout") {
            try await authService.logout()
        }
    }
    
    func verifySession() async throws {
        try await wrap("verifySession", requiresAuth: false) {
            try await authService.verifySession()
        }
    }

    // MARK: - Events

    func fetchEvents() async throws {
        try await wrap("fetchEvents") {
            let events = try await eventService.fetchEvents()
            self.eventList = events
        }
    }

    func upsertEvents(_ events: [Event]) async throws {
        try await wrap("upsertEvents") {
            self.eventList = events
            try await eventService.upsertEvents(events)
        }
    }

    func deleteEvent(_ uid: UUID) async throws {
        try await wrap("deleteEvent") {
            self.eventList.removeAll { $0.id == uid }
            try await eventService.upsertEvents(self.eventList)
        }
    }

    // MARK: - Images

    func upsertImage(imageData: Data, filename: String) async throws {
        try await wrap("upsertImage(\(filename))") {
            try await imageService.upsertImage(imageData: imageData, name: filename)
        }
    }

    func fetchImageURLs() async throws {
        try await wrap("fetchImageURLs") {
            let systemNames = try await libraryService.fetchConnectedSystemNames()
            let libraries = resolveLibraries(from: systemNames, using: availableLibraries)
            let result = try await imageService.fetchAllImageMappings(libraries: libraries)
            self.images = result
        }
    }

    // MARK: - Libraries

    func fetchExistingLibraries() async throws {
        try await wrap("fetchExistingLibraries") {
            let result = try await libraryService.fetchAllLibraries()
            self.availableLibraries = result
        }
    }

    func addLibrary(_ systemName: String) async throws {
        try await wrap("addLibrary(\(systemName))") {
            try await libraryService.addLibrary(systemName: systemName, from: availableLibraries)
            let libraries = try await libraryService.fetchAllLibraries()
            let result = try await imageService.fetchAllImageMappings(libraries: libraries)
            self.images = result
        }
    }

    // MARK: - Presets

    func fetchPresets() async throws {
        try await wrap("fetchPresets") {
            let loaded = try await presetService.fetchPresets()
            for preset_name in loaded.keys {
                print("Preset: \(preset_name), URL: \(loaded[preset_name]!.mainImageURL)")
            }
            self.presets = loaded
        }
    }

    func upsertPresets(title: String, preset: Preset) async throws {
        try await wrap("upsertPresets(\(title))") {
            _ = try await presetService.uploadUserPreset(title: title, preset: preset)
            self.presets[title] = preset
        }
    }

    // MARK: - Timer Polling

    func startPeriodicFetch() {
        fetchTimer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    try? await self?.fetchEvents()
                }
            }
    }

    func stopPeriodicFetch() {
        fetchTimer?.cancel()
        fetchTimer = nil
    }

    // MARK: - Error Classifier Wrapper

    private func wrap<T>(
        _ job: String,
        requiresAuth: Bool = true,
        _ operation: () async throws -> T
    ) async throws -> T {
        do {
            if requiresAuth {
                try await verifySession()
            }

            return try await operation()
        } catch {
            try ErrorClassifier.classifyAndThrow(error, job: job) // surface error to layers up
        }
    }
}
