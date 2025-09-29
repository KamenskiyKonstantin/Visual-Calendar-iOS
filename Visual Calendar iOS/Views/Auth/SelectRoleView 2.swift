//
//  SelectRoleView 2.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 29.09.2025.
//

import SwiftUI

struct SelectRoleView: View {
    @StateObject var viewModel: SelectRoleViewModel
    @State private var showAdultModal = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                // Child Button
                Button(action: {
                    viewModel.switchChild()
                }) {
                    Text("Child")
                        .font(.title)
                        .frame(width: 300, height: 80)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                // Adult Button
                Button(action: {
                    showAdultModal = true
                }) {
                    Text("Adult")
                        .font(.title)
                        .frame(width: 300, height: 80)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.load()
            }
            .sheet(isPresented: $showAdultModal) {
                AdultVerificationModal(viewModel: viewModel)
            }
        }
    }
}

struct AdultVerificationModal: View {
    @ObservedObject var viewModel: SelectRoleViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("\(viewModel.verificationValA) + \(viewModel.verificationValB) = ?")
                .font(.largeTitle)

            TextField("", text: $viewModel.userVerificationAnswer)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title)
                .frame(width: 100)
                .textFieldStyle(.roundedBorder)

            Button("Submit") {
                viewModel.switchAdult()
            }
            .font(.title2)
            .padding()
            .frame(width: 200)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(20)

            Spacer()
        }
        .padding()
    }
}
