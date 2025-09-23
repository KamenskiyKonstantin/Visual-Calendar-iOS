//
//  APIHandler 2.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 22.09.2025.
//



@MainActor
final class APIHandler {
    // MARK: - Services
    private let authService: AuthService
    private let eventService: EventService
    private let imageService: ImageService
    private let libraryService: LibraryService
    private let presetService: PresetService

    private let apiClient: SupabaseClient
    private var executor: AsyncExecutor?

    private var fetchTimer: AnyCancellable?

    // MARK: - Setup
    init() {
        let client = SupabaseClient(
            supabaseURL: URL(string: "https://wlviarpvbxdaoytfeqnm.supabase.co")!,
            supabaseKey: "YOUR_SECRET_KEY",
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
    func signUp(email: String, password: String) async -> Bool {
        await requireExecutor().run("signUp")
        {
            try await self.authService.signUp(email: email, password: password)
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
        await requireExecutor().run("fetchEvents") {
            try await self.eventService.fetchEvents()
        }.value ?? []
    }

    func upsertEvents(_ events: [Event]) async -> Bool {
        await requireExecutor().run("upsertEvents") {
            try await self.eventService.upsertEvents(events)
        }.value != nil
    }

    func deleteEvent(_ uid: UUID, from currentList: [Event]) async -> [Event] {
        var updated = currentList.filter { $0.id != uid }
        let success = await requireExecutor().run("deleteEvent") {
            try await self.eventService.upsertEvents(updated)
        }.value != nil

        return success ? updated : currentList
    }

    // MARK: - Images
    func upsertImage(imageData: Data, filename: String) async -> Bool {
        await requireExecutor().run("upsertImage(\(filename))") {
            try await self.imageService.upsertImage(imageData: imageData, name: filename)
        }.value != nil
    }

    func fetchImageURLs(using libraries: [LibraryInfo]) async -> [String: [NamedURL]] {
        await requireExecutor().run("fetchImageURLs") {
            try await self.imageService.fetchAllImageMappings(libraries: libraries)
        }.value ?? [:]
    }

    // MARK: - Libraries
    func fetchExistingLibraries() async -> [LibraryInfo] {
        await requireExecutor().run("fetchAllLibraries") {
            try await self.libraryService.fetchAllLibraries()
        }.value ?? []
    }

    func addLibrary(_ systemName: String, available: [LibraryInfo]) async -> [String: [NamedURL]] {
        let result = await requireExecutor().run("addLibrary") {
            try await self.libraryService.addLibrary(systemName: systemName, from: available)
            let libraries = try await self.libraryService.fetchAllLibraries()
            return try await self.imageService.fetchAllImageMappings(libraries: libraries)
        }
        return result.value ?? [:]
    }

    // MARK: - Presets
    func fetchPresets() async -> [String: Preset] {
        await requireExecutor().run("fetchPresets") {
            try await self.presetService.fetchPresets()
        }.value ?? [:]
    }

    func upsertPreset(title: String, preset: Preset) async -> Bool {
        await requireExecutor().run("upsertPreset(\(title))") {
            try await self.presetService.uploadUserPreset(title: title, preset: preset)
        }.value != nil
    }
}
