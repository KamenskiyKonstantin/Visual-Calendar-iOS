//
//  CalendarViewModel.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 16.09.2025.
//

//import Foundation
//
//@MainActor
//final class CalendarViewModel: ObservableObject {
//    // MARK: - Dependencies
//    private let api: APIHandler
//    private let warningHandler: WarningHandler
//    private let viewSwitcher: ViewSwitcher
//
//    // MARK: - State
//    @Published var currentDate: Date = Date().startOfWeek()
//    @Published var deleteMode: Bool = false
//    @Published var mode: CalendarMode = .Week
//    @Published var events: [Event] = []
//
//    init(
//        api: APIHandler,
//        warningHandler: WarningHandler,
//        viewSwitcher: ViewSwitcher,
//        isParentMode: Bool = false
//    ) {
//        self.api = api
//        self.warningHandler = warningHandler
//        self.viewSwitcher = viewSwitcher
//        self.isParentMode = isParentMode
//    }
//
//    let minuteHeight = 2
//    let HStackXOffset = defaultHStackOffset
//    let isParentMode: Bool
//
//    // MARK: - Actions
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
//    func fetchEvents() async {
//        do {
//            let fetchedEvents = try await api.fetchEvents()
//            self.events = fetchedEvents
//        } catch {
//            print("Error fetching events: \(error)")
//        }
//    }
//
//    func updateEvents(event: Event) async {
//        // 1. Optimistically update local listx
//        self.events.append(event)
//
//        // 2. Try to push to server
//        AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: api, viewSwitcher: viewSwitcher) {
//            try await self.api.upsertEvents(self.events)
//
//            // 3. Pull server truth if needed
//            let canonical = try await self.api.fetchEvents()
//            self.events = canonical
//        }
//    }
//
//    func logout() {
//        AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: api, viewSwitcher: viewSwitcher) {
//            try await self.api.logout()
//            self.viewSwitcher.switchToLogin()
//        }
//    }
//}
