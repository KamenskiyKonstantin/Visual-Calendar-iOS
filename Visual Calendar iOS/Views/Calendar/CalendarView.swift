//
//  CalendarView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI

struct CalendarView: View {
    // MARK: - View Model
    @ObservedObject var viewModel: CalendarViewModel

    // MARK: - Sheet
    @State private var logoutFormShown: Bool = false

    var body: some View {
        
        if viewModel.isLoading {
            ProgressView("Loading...")
        }
        else{
            NavigationStack {
                VStack(spacing: 0) {
                    WeekdayHeader(
                        decreaseCurrentDate: viewModel.decreaseDate,
                        increaseCurrentDate: viewModel.increaseDate,
                        HStackXOffset: viewModel.HStackXOffset,
                        currentDate: $viewModel.currentDate,
                        mode: $viewModel.mode
                    )

                    ScrollView(.vertical) {
                        ZStack(alignment: .topLeading) {
                            HStack {
                                Color.clear.frame(width: viewModel.HStackXOffset)
                                CalendarTable(viewModel: viewModel)
                                Color.clear.frame(width: viewModel.HStackXOffset)
                            }

                            CalendarBackgroundView(minuteHeight: viewModel.minuteHeight)
                        }
                    }
                }
                .confirmationDialog(
                    "Are you sure you want to proceed?",
                    isPresented: $logoutFormShown,
                    titleVisibility: .visible
                ) {
                    Button("OK") {
                        viewModel.logout()
                    }
                    Button("Cancel", role: .cancel) {
                        logoutFormShown = false
                    }
                }
                .overlay(alignment: .bottom) {
                    ButtonPanel(
                        logoutFormShown: $logoutFormShown,
                        calendarMode: $viewModel.mode,
                        currentDate: $viewModel.currentDate,
                        deleteMode: $viewModel.deleteMode,
                        isParentMode: viewModel.isParentMode,
                        
                        viewModel: viewModel.eventEditorModel
                    )
                }
            }
            .onAppear {
                viewModel.load()
            }
        }

    }
}

//#Preview {
//    CalendarView(viewModel: MockCalendarViewModel().withParentMode)
//}
//

