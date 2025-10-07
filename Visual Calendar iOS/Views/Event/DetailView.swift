//
//  DetailView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 05.10.2025.
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel

    var body: some View {
        if let event = viewModel.event {
            DetailViewBody(event: event)
        } else {
            Image(uiImage: emojiToImage("", fontSize: 64) ?? UIImage())
        }
    }

    @ViewBuilder
    private func DetailViewBody(event: Event) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                mainImage(url: event.mainImageURL)
                Divider()
                sideImages(urls: event.sideImagesURL)
                Divider()
                reactionButtons()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func mainImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
            } else {
                Color.gray.frame(height: 200).cornerRadius(12)
            }
        }
    }

    private func sideImages(urls: [String]) -> some View {
        VStack {
            ForEach(urls, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(8)
                    } else {
                        Color.gray.frame(height: 150).cornerRadius(8)
                    }
                }
            }
        }
    }

    private func reactionButtons() -> some View {
        HStack(spacing: 12) {
            ForEach(EventReaction.allCases.filter { $0 != .none }, id: \.self) { reaction in
                Button() {
                    viewModel.toggleReaction(reaction)
                } label: {
                    emojiButton(for: reaction, selected: viewModel.currentReaction == reaction)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.isInUITImeout)
            }
        }
    }

    private func emojiButton(for reaction: EventReaction, selected: Bool) -> some View {
        let image = emojiToImage(reaction.emoji, fontSize: 36) ?? UIImage()

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 44, height: 44)
            .padding(8)
            .background(selected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? Color.blue : Color.clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
