//
//  CalendarViewModel.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 16.09.2025.
//

import Foundation

@MainActor
final class CalendarViewModel: ObservableObject {
    private var hasLoaded: Bool = false
    
    // MARK: - Dependencies
    private let api: APIHandler
    private let warningHandler: WarningHandler
    private let viewSwitcher: ViewSwitcher

    // MARK: - State
    @Published var currentDate: Date = Date().startOfWeek()
    @Published var deleteMode: Bool = false
    @Published var mode: CalendarMode = .Week
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var isParentMode: Bool = false

    init(
        api: APIHandler,
        warningHandler: WarningHandler,
        viewSwitcher: ViewSwitcher,
    ) {
        self.api = api
        self.warningHandler = warningHandler
        self.viewSwitcher = viewSwitcher
    }
    
    func setParentMode(_ isParentMode: Bool) {
        self.isParentMode = isParentMode
    }
    
    // MARK: internal logic
    func load() {
        if hasLoaded {return}
        
        // here we will be making A LOT of API calls
        
        print("I am doing some stuff here!!!!")
        hasLoaded = true
    }
    
    func reset() {
        hasLoaded = false
    }

    // MARK: - Actions

    func increaseDate() {
        switch mode {
        case .Week:
            currentDate = currentDate.addingTimeInterval(60 * 60 * 24 * 7)
        case .Day:
            currentDate = currentDate.addingTimeInterval(60 * 60 * 24)
        }
    }

    func decreaseDate() {
        switch mode {
        case .Week:
            currentDate = currentDate.addingTimeInterval(-60 * 60 * 24 * 7)
        case .Day:
            currentDate = currentDate.addingTimeInterval(-60 * 60 * 24)
        }
    }
    
    



}
