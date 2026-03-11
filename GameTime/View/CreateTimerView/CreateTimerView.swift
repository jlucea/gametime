
import SwiftUI

struct CreateTimerView: View {
    
    @StateObject private var viewModel: ViewModel
    @FocusState private var isNameFieldFocused: Bool
    
    @State private var showColorPicker: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let maxNameLenght: Int = 24
    
    init(isPresented: Binding<Bool>, _ manager: GTTimerManager? = nil) {
        self._viewModel = StateObject(wrappedValue: ViewModel(isPresented: isPresented, manager))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack (spacing: 6) {
                
                TimerDurationPicker(duration: $viewModel.duration)
                
                Form {
                    HStack {
                        Text("Name")
                            .frame(minWidth: 0, idealWidth: .infinity, alignment: .leading)
                        TextField("Name", text: $viewModel.name)
                            .onChange(of: viewModel.name) { newValue in
                                if newValue.count > maxNameLenght {
                                    viewModel.name = String(newValue.prefix(maxNameLenght))
                                }
                            }
                            .focused($isNameFieldFocused)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            .submitLabel(.done)
                            .frame(minHeight: 0, maxHeight: .infinity)  // Use all of the row's vertical space
                    }
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
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveAndClose()
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
                DispatchQueue.main.async {
                    isNameFieldFocused = true
                }
            }
        }
    }
    
}

#Preview {
    CreateTimerView(isPresented: Binding.constant(true))
}
