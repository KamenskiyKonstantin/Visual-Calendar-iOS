////
////  EventEditor.swift
////  Visual Calendar iOS
////
////  Created by Konstantin Kamenskiy on 23.01.2025.
////
//
import SwiftUI
import UniformTypeIdentifiers

struct EventEditor: View {
    @ObservedObject var model: EventEditorModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        
        if model.isLoading {
            ProgressView("Loading...")
        }
        else{
            NavigationStack {
                Form {
                    // MARK: - Title & Preset
                    TitleManagement(
                        title: $model.title,
                        
                        saveAsPreset: $model.saveAsPreset,
                        viewModel: model,
                        applyPreset: model.applyPreset
                    )
                    
                    // MARK: - Date Section
                    EventDateSection(
                        dateStart: $model.dateStart,
                        dateEnd: $model.dateEnd,
                        repeatType: $model.repeatType
                    )
                    
                    // MARK: - Appearance
                    EventAppearanceSection(
                        selectedSymbol: $model.selectedSymbol,
                        isSymbolPickerShown: .constant(false),
                        backgroundColor: $model.backgroundColor,
                        textColor: $model.textColor
                    )
                    
                    // MARK: - Content
                    EventContentSection(
                        fileImporterPresented: $model.fileImporterPresented,
                        mainImage: $model.mainImageURL,
                        sideImages: $model.sideImagesURL,
                        viewModel: model
                    )
                    
                    // MARK: - Actions & Error
                    Section {
                        if let error = model.validationError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button("Submit") {
                            model.submit()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        if model.eventID != nil {
                            Button("Delete", role: .destructive) {
                                model.deleteEvent()
                            }
                        }
                    }
                }
                .navigationTitle("Edit Event")
                .onAppear {
                    model.load()
                    model.setDismissal {dismiss()}
                }
                .fileImporter(
                    isPresented: $model.fileImporterPresented,
                    allowedContentTypes: [.image],
                    onCompletion: model.fileCallback
                )
                .sheet(isPresented: $model.isNameEditorShown) {
                    NameEditor(
                        viewModel: model,
                        name: $model.addedFilename,
                        
                        fileURL: $model.addedFilePath,
                        isPresented: $model.isNameEditorShown
                    )
                }
                .sheet(isPresented: $model.showPresetUploadWarning) {
                    DuplicatePresetWarning(
                        isPresented: $model.showPresetUploadWarning,
                        onContinue: {
                            model.forceSubmit()
                        }
                    )
                }
            }
        }
    }
}

struct DuplicatePresetWarning: View {
    @Binding var isPresented: Bool
    var onContinue: () -> Void
    var body: some View {
        Text("This preset already exists, continuing will overwrite it.")
    }
}
