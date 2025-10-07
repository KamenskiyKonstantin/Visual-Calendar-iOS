//
//  EventView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 05.10.2025.
//


import SwiftUI

struct EventView: View {
    //TODO: pass raw events
    
    let eventID: UUID
    @ObservedObject var viewModel: CalendarViewModel
    let minuteHeight: Int
    let dateStart: [Int]
    let reaction: EventReaction

    private var event: Event? {
        viewModel.events.first(where: { $0.id == eventID })
    }
    
    private var isParent: Bool {
        viewModel.isParentMode
    }

    var body: some View {
        if let event = event {
            content(for: event)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private func content(for event: Event) -> some View {
        let height = max(1, Int(event.dateTimeEnd.timeIntervalSince(event.dateTimeStart)) / 60) * minuteHeight
        let startHour = Calendar.current.component(.hour, from: event.dateTimeStart)
        let startMinute = Calendar.current.component(.minute, from: event.dateTimeStart)
        let offsetY = (startHour * 60 + startMinute) * minuteHeight

        NavigationLink(destination:
                        {if isParent { EventEditor(model: viewModel.eventEditorModel)} else {DetailView(viewModel: viewModel.detailViewModel)}})
        {
            rectangleView(event: event, strokeColor: colorFromName(event.textColor))
        }
        .simultaneousGesture(TapGesture().onEnded {
            print("Event tapped. ID: \(event.id)")
            if isParent{
                viewModel.eventEditorModel.setEvent(event)
            }
            else{
                viewModel.detailViewModel.setEvent(event)
                viewModel.detailViewModel.setTimeStart(dateStart)
                viewModel.detailViewModel.setReaction(reaction)
            }
        })
        .frame(
            maxWidth: .infinity,
            minHeight: CGFloat(height),
            maxHeight: CGFloat(height),
            alignment: .topLeading
        )
        .offset(y: CGFloat(offsetY + 30 * minuteHeight))
    }

    // MARK: - Event Styling
    @ViewBuilder
    private func rectangleView(event: Event, strokeColor: Color) -> some View {
        let background = colorFromName(event.backgroundColor)
        let emojiImage = emojiToImage(event.systemImage, fontSize: 64)
        let reactionImage = emojiToImage(reaction.emoji, fontSize: 64)

        if #available(iOS 17.0, *) {
            RoundedRectangle(cornerRadius: 10)
                .fill(background)
                .stroke(strokeColor, lineWidth: 1)
                .overlay(alignment: .center) {
                    if let emojiImage = emojiImage {
                        Image(uiImage: emojiImage)
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(event.duration >= 60 ? 10 : 5)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if reaction != .none, let reactionImage = reactionImage {
                        reactionOverlay(reactionImage)
                    }
                }

        } else {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(background)

                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeColor, lineWidth: 1)

                if let emojiImage = emojiImage {
                    Image(uiImage: emojiImage)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(event.duration >= 60 ? 10 : 5)
                        .aspectRatio(1, contentMode: .fit)
                }

                if event.reaction != .none, let reactionImage = reactionImage {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            reactionOverlay(reactionImage)
                        }
                    }
                    .padding(3)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    @ViewBuilder
    private func reactionOverlay(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 20, height: 20)
            .padding(3)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.8)
            )
    }
    
}
