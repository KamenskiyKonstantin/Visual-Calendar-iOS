import Foundation
import Supabase
import Combine
import SwiftyJSON

@MainActor
final class APIHandler {
    // MARK: - Services
    private let authService: AuthService
    private let eventService: EventService
    private let imageService: ImageService
    private let libraryService: LibraryService
    private let presetService: PresetService
    private let reactionService: ReactionService

    private let apiClient: SupabaseClient
    private var executor: AsyncExecutor?

    private var fetchTimer: AnyCancellable?

    // MARK: - Setup
    init() {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://kkmvjjzoouqqmempnxrg.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrbXZqanpvb3VxcW1lbXBueHJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2MjgyMTEsImV4cCI6MjA3NDIwNDIxMX0.ZeziIaDzLApRnTLKQdl0MMlqR5zjaI7BpuUhPvebcco",
            options: SupabaseClientOptions(
                auth: .init(
                    storage: KeychainLocalStorage(service: "com.calmtable.app", accessGroup: nil),
                    flowType: .pkce
                )
            )
        )

        self.apiClient = client
        self.authService = AuthService(client: client)
        self.eventService = EventService(client: client)
        self.imageService = ImageService(client: client)
        self.libraryService = LibraryService(client: client)
        self.presetService = PresetService(client: client)
        self.reactionService = ReactionService(client: client)
    }

    // MARK: - Dependency Injection
    func setExecutor(_ executor: AsyncExecutor) {
        self.executor = executor
    }

    private func requireExecutor() -> AsyncExecutor {
        guard let executor else {
            fatalError("FATAL: AsyncExecutor not set. Call setExecutor(_:) before using APIHandler.")
        }
        return executor
    }

    // MARK: - Auth
    func signUp(email: String, password: String, confirmPassword: String) async -> Bool {
        await requireExecutor().run("signUp")
        {
            try await self.authService.signUp(email: email, password: password, confirmPassword: confirmPassword)
        }.value != nil
    }

    func login(email: String, password: String) async -> Bool {
        await requireExecutor().run("login") {
            try await self.authService.login(email: email, password: password)
        }.value != nil
    }

    func logout() async -> Bool {
        await requireExecutor().run("logout") {
            try await self.authService.logout()
        }.value != nil
    }

    func verifySession() async -> Bool {
        await requireExecutor().run("verifySession") {
            try await self.authService.verifySession()
        }.value != nil
    }

    var isAuthenticated: Bool {
        self.authService.isAuthenticated
    }

    // MARK: - Events
    func fetchEvents() async -> [Event] {
        guard await verifySession() else { return [] }
        return await requireExecutor().run("fetchEvents") {
            try await self.eventService.fetchEvents()
        }.value ?? []
    }

    func createEvent(_ event: Event) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("create Event") {
            try await self.eventService.createEvent(event)
        }.value != nil
    }
    
    func updateEvent(_ newEvent: Event) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("update Event") {
            try await self.eventService.updateEvent(newEvent)
        }.value != nil
    }


    func deleteEvent(_ eventID: UUID) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("deleteEvent") {
            try await self.eventService.deleteEvent(eventID)
        }.value != nil
    }

    // MARK: - Images
    func createImage(_ imageData: Data, _ displayName: String) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("upsertImage (\(displayName))") {
            try await self.imageService.createImage(imageData: imageData, displayName: displayName)
        }.value != nil
    }

    func fetchImages(_ libraries: [LibraryInfo]) async -> [String: [any NamedURL]] {
        guard await verifySession() else { return [:] }
        return await requireExecutor().run("fetchImageURLs") {
            try await self.imageService.fetchAllImageMappings(libraries: libraries)
        }.value ?? [:]
    }
    
    func updateImage(_ imageData: Data, _ displayName: String) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("upsertImage (\(displayName))") {
            try await self.imageService.updateImage(imageData: imageData, displayName: displayName)
        }.value != nil
    }
    
    func deleteImage(_ displayName: String) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("Delete Image") {
            try await self.imageService.deleteImage(displayName: displayName)
        }.value != nil
    }

    // MARK: - Libraries
    func fetchExistingLibraries() async -> [LibraryInfo] {
        guard await verifySession() else { return [] }
        return await requireExecutor().run("fetchAllLibraries") {
            try await self.libraryService.fetchAllLibraries()
        }.value ?? []
    }
    
    func fetchConnectedLibraries() async -> [LibraryInfo] {
        guard await verifySession() else { return [] }
        return await requireExecutor().run("fetchConnectedLibraries") {
            try await self.libraryService.fetchConnectedLibraries()
        }.value ?? []
    }

    func addLibrary(_ systemName: String) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("addLibrary") {
            try await self.libraryService.addLibrary(systemName: systemName)
            return true
        }.value ?? false
    }
    
    func removeLibrary(_ systemName: String) async -> Bool{
        guard await verifySession() else { return false }
        return await requireExecutor().run("remove library") {
            try await self.libraryService.removeLibrary(systemName: systemName)
            return true
        }.value ?? false
    }

    // MARK: - Presets
    func createPreset( preset: Preset) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("upsertPreset(\(preset.presetName))") {
            try await self.presetService.createPreset(preset)
        }.value != nil
    }
    
    func fetchPresets() async -> [Preset] {
        guard await verifySession() else { return [] }
        return await requireExecutor().run("fetchPresets") {
            try await self.presetService.fetchPresets()
        }.value ?? []
    }
    
    func updatePreset(preset: Preset) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("upsertPreset(\(preset.presetName))") {
            try await self.presetService.updatePreset(preset)
        }.value != nil
    }

    func deletePreset(presetName: String) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("deletePreset(\(presetName))") {
            try await self.presetService.deletePreset(named: presetName)
        }.value != nil
    }
    
    // MARK: Reaction Service
    func fetchAllReactions(for events: [Event]) async -> [UUID: [EventReactionRow]] {
            guard await verifySession() else { return [:] }
            return await requireExecutor().run("fetchAllReactions") {
                try await self.reactionService.fetchAllReactions(for: events)
            }.value ?? [:]
        }

    func setReaction(for eventID: UUID, timeStart: [Int], reaction: EventReaction) async -> Bool {
        guard await verifySession() else { return false }
        return await requireExecutor().run("setReaction") {
            try await self.reactionService.setReaction(for: eventID, timeStart: timeStart, reaction: reaction)
        }.value != nil
    }

}


