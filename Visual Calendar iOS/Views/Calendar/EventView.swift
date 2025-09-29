//
//  EventView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 15.07.2025.
//

import SwiftUI

//struct EventView: View {
//    let eventID: UUID
//    let deleteMode: Bool
//    let minuteHeight: Int = 2
//
//    @EnvironmentObject var api: APIHandler
//    @EnvironmentObject var warningHandler: WarningHandler
//    @EnvironmentObject var viewSwitcher: ViewSwitcher
//
//    private var event: Event? {
//        api.eventList.first(where: { $0.id == eventID })
//    }
//
//    var body: some View {
//        if let event = event {
//            content(for: event)
//        } else {
//            Color.clear
//        }
//    }
//
//    @ViewBuilder
//    func content(for event: Event) -> some View {
//        let height = Int(event.dateTimeEnd.timeIntervalSince(event.dateTimeStart)) / 60 * minuteHeight
//        let hour = Calendar.current.component(.hour, from: event.dateTimeStart)
//        let minute = Calendar.current.component(.minute, from: event.dateTimeStart)
//        let offsetY = (hour * 60 + minute) * minuteHeight
//
//        VStack(alignment: .leading) {
//            if deleteMode {
//                Button {
//                    AsyncExecutor.runWithWarningHandler(warningHandler: warningHandler, api: api, viewSwitcher: viewSwitcher) {
//                        try await api.deleteEvent(event.id)
//                    }
//                } label: {
//                    rectangleView(event: event, strokeColor: .red)
//                }
//            }
//            else {
//                NavigationLink(destination: DetailView(eventID: event.id)) {
//                    rectangleView(event: event, strokeColor: colorFromName(event.textColor))
//                }
//            }
//        }
//        .font(.caption)
//        .frame(
//            maxWidth: .infinity,
//            minHeight: CGFloat(height), maxHeight: CGFloat(height),
//            alignment: .topLeading
//        )
//        .offset(y: CGFloat(offsetY + 30 * minuteHeight))
//    }
//
//    @ViewBuilder
//    func rectangleView(event: Event, strokeColor: Color) -> some View {
//        if #available(iOS 17.0, *) {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(colorFromName(event.backgroundColor))
//                .stroke(strokeColor, lineWidth: 1)
//                .overlay(alignment: .center) {
//                    if let emojiImage = emojiToImage(event.systemImage, fontSize: 64) {
//                        Image(uiImage: emojiImage)
//                            .resizable()
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .padding(event.duration >= 60 ? 10 : 5)
//                            .aspectRatio(1, contentMode: .fit)
//                    }
//                }
//                .overlay(alignment: .bottomTrailing) {
//                    if event.reaction != .none,
//                       let reactionImage = emojiToImage(event.reaction.emoji, fontSize: 16) {
//                        Image(uiImage: reactionImage)
//                            .resizable()
//                            .aspectRatio(1, contentMode: .fit)
//                            .frame(width: 20, height: 20)
//                            .padding(3)
//                            .background(Color.white.opacity(0.9))
//                            .clipShape(RoundedRectangle(cornerRadius: 5))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 5)
//                                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.8)
//                            )
//                    }
//                }
//        } else {
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(colorFromName(event.backgroundColor))
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(strokeColor, lineWidth: 1)
//                    .overlay(alignment: .center) {
//                        if let emojiImage = emojiToImage(event.systemImage, fontSize: 64) {
//                            Image(uiImage: emojiImage)
//                                .resizable()
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .padding(event.duration >= 60 ? 10 : 5)
//                                .aspectRatio(1, contentMode: .fit)
//                        }
//                    }
//                    .overlay(alignment: .bottomTrailing) {
//                        if event.reaction != .none,
//                           let reactionImage = emojiToImage(event.reaction.emoji, fontSize: 16) {
//                            Image(uiImage: reactionImage)
//                                .resizable()
//                                .aspectRatio(1, contentMode: .fit)
//                                .frame(width: 20, height: 20)
//                                .padding(3)
//                                .background(Color.white.opacity(0.9))
//                                .clipShape(RoundedRectangle(cornerRadius: 5))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.gray.opacity(0.4), lineWidth: 0.8)
//                                )
//                        }
//                    }
//            }
//        }
//            
//    }
//}
