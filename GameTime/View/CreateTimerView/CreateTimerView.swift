
import SwiftUI

/// Form used to create new timers and edit existing ones.
struct TimerEditorView: View {
    
    enum Mode {
        case create
        case edit(timer: GTTimer)
    }
    
    @StateObject private var viewModel: ViewModel
    
    /// Keeps the name field focused when the view is presented so users can type immediately.
    @FocusState private var isNameFieldFocused: Bool
    
    @State private var showColorPicker: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var timerManager: GTTimerManager
    
    /// Hard limit to keep timer names short and consistent across the UI.
    private let maxNameLength: Int = 24
    
    init(mode: Mode, isPresented: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: ViewModel(mode: mode, isPresented: isPresented))
    }
    
    private var navigationTitleKey: LocalizedStringKey {
        viewModel.isCreateMode ? "timer_editor.navigation_title.create" : "timer_editor.navigation_title.edit"
    }
    
    private var saveButtonTitleKey: LocalizedStringKey {
        viewModel.isCreateMode ? "timer_editor.button.create" : "timer_editor.button.save"
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack (spacing: 6) {
                
                TimerDurationPicker(duration: $viewModel.duration)
                
                Form {
                    // Timer name row
                    HStack {
                        Text("Name")
                            .frame(minWidth: 0, idealWidth: .infinity, alignment: .leading)
                        TextField("Name", text: $viewModel.name)
                            .onChange(of: viewModel.name) { newValue in
                                if newValue.count > maxNameLength {
                                    viewModel.name = String(newValue.prefix(maxNameLength))
                                }
                            }
                            .focused($isNameFieldFocused)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .frame(minHeight: 0, maxHeight: .infinity)
                    }
                    // Color picker row (opens a modal color selector)
                    HStack {
                        Text("Color")
                        HStack {
                            Spacer()
                            Circle()
                                .foregroundStyle(viewModel.color)
                                .frame(width: 22, height: 22)
                        }
                        .frame(maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showColorPicker = true
                        }
                    }
                }
            }
            .navigationTitle(navigationTitleKey)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(saveButtonTitleKey) {
                        viewModel.saveAndClose(using: timerManager)
                    }
                }
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerView(selectedColor: $viewModel.color) {
                    showColorPicker = false
                }
                .padding(.top, 18)
            }
            .onAppear {
                // Delay one run loop so focus is applied after the form is laid out
                // We only autofocus in creation mode so edit mode does not force keyboard opening.
                if viewModel.autofocusNameField {
                    DispatchQueue.main.async {
                        isNameFieldFocused = true
                    }
                }
            }
        }
    }
    
}

#Preview {
    TimerEditorView(mode: .create, isPresented: Binding.constant(true))
        .environmentObject(GTTimerManager())
}
