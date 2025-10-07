//
//  DetailViewModel.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 05.10.2025.
//
import Foundation

import Foundation

@MainActor
protocol DetailViewModelProtocol: ObservableObject {
    var event: Event? { get }
    var timeStart: [Int] { get }
    var currentReaction: EventReaction { get }

    func setEvent(_ event: Event)
    func setTimeStart(_ time: [Int])
    func toggleReaction(_ newReaction: EventReaction)
}


@MainActor
class DetailViewModel: ObservableObject {
    // MARK: - Dependencies
    private let api: APIHandler
    private let warningHandler: WarningHandler
    private var fetchCallback: (() async -> Void)?

    // MARK: - State
    @Published private(set) var event: Event?
    @Published private(set) var timeStart: [Int] = []
    @Published private(set) var currentReaction: EventReaction = .none
    @Published private(set) var isInUITImeout: Bool = false

    // MARK: - Init
    init(api: APIHandler, warningHandler: WarningHandler) {
        self.api = api
        self.warningHandler = warningHandler
    }

    func setEvent(_ event: Event) {
        self.event = event
        self.currentReaction = event.reaction
    }

    func setTimeStart(_ time: [Int]) {
        self.timeStart = time
    }
    
    func setFetchCallback(_ callback: @escaping () async -> Void ){
        self.fetchCallback = callback
    }
    
    func setReaction(_ reaction: EventReaction){
        self.currentReaction = reaction
    }
    
    func toggleReaction(_ newReaction: EventReaction) {
        guard let eventID = event?.id else { return }
        guard fetchCallback != nil else { fatalError("Reaction refetch callback is not set") }
        
        isInUITImeout = true
        
        
        
        let finalReaction: EventReaction = (currentReaction == newReaction) ? .none : newReaction

        Task {
            defer{
                isInUITImeout = false
            }
            let success = await api.setReaction(for: eventID, timeStart: timeStart, reaction: finalReaction)
            
            if success {
                currentReaction = finalReaction
                await fetchCallback!()
                
            } else {
                warningHandler.showWarning("Failed to update reaction.")
            }
            try? await Task.sleep(nanoseconds: 500_000_000);
            
            
        }
    }
}

//final class MockDetailViewModel: DetailViewModel {
//    @Published override var event: Event?
//    @Published override var timeStart: [Int] = [5, 10, 2025, 14, 30]
//    @Published override var currentReaction: EventReaction = .smiley
//
//    override func setEvent(_ event: Event) {
//        self.event = event
//    }
//
//    override func setTimeStart(_ time: [Int]) {
//        self.timeStart = time
//    }
//
//    override func toggleReaction(_ newReaction: EventReaction) {
//        currentReaction = (currentReaction == newReaction) ? .none : newReaction
//    }
//}
