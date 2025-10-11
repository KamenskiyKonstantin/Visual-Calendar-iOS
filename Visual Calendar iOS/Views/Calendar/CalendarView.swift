//
//  CalendarView.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 28.08.2024.
//

import SwiftUI

struct TimeOverlay: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack{
            let current = Date()
            let currentHour = Calendar.current.component(.hour, from: current)
            let currentMinute = Calendar.current.component(.minute, from: current)
            let totalMinutes = currentHour * 60 + currentMinute
            
            let offsetY: CGFloat = CGFloat(totalMinutes) * CGFloat(viewModel.minuteHeight)
            
            Rectangle()
                .fill(Color(.systemRed))
                .frame(height:2, alignment: .topLeading)
                .offset(y: offsetY + CGFloat(30 * viewModel.minuteHeight))
            
        }
    }
}

struct CalendarView: View {
    // MARK: - View Model
    @ObservedObject var viewModel: CalendarViewModel

    // MARK: - Sheet
    @State private var logoutFormShown: Bool = false

    var body: some View {
        
        if viewModel.isLoading {
            ProgressView("Calendar.Loading.ProgressView.Title".localized)
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
                            Color.clear


                            HStack {
                                Color.clear.frame(width: viewModel.HStackXOffset)
                                CalendarTable(viewModel: viewModel)
                                Color.clear.frame(width: viewModel.HStackXOffset)
                            }
                            

                            CalendarBackgroundView(minuteHeight: viewModel.minuteHeight)
                            HStack {
                                TimeOverlay(viewModel: viewModel)
                            }
                            
                            
                            
                        }
                    }
                }
                .confirmationDialog(
                    "Calendar.Logout.ConfirmationDialog.Title".localized,
                    isPresented: $logoutFormShown,
                    titleVisibility: .visible
                ) {
                    Button("Calendar.Logout.ConfirmationDialog.OK".localized) {
                        viewModel.logout()
                    }
                    Button("Calendar.Logout.ConfirmationDialog.Cancel".localized, role: .cancel) {
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


