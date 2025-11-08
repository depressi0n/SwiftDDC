import SwiftUI
import SwiftDDC

struct DisplayDetailView: View {
    let display: DDCDisplay
    @EnvironmentObject var displayManager: DisplayManager

    @State private var brightness: Float = 0
    @State private var contrast: Float = 0
    
    @State private var currentInputID: UInt16?
    @State private var unknownInput: InputSource?
    @State private var isInitialLoad = true
    @State private var isSwitchingInput: Bool = false
    @State private var pendingInputID: UInt16?

    private var allAvailableInputs: [InputSource] {
        var inputs = commonInputs
        if let unknown = unknownInput, !inputs.contains(where: { $0.value == unknown.value }) {
            inputs.append(unknown)
        }
        return inputs.sorted { $0.name < $1.name }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Sliders for Brightness and Contrast (unchanged)
            HStack {
                Image(systemName: "sun.max.fill")
                Slider(value: $brightness, in: 0...100, onEditingChanged: { editing in
                    if !editing { writeVCP(code: 0x10, value: UInt16(brightness)) }
                })
            }
            HStack {
                Image(systemName: "circle.lefthalf.filled")
                Slider(value: $contrast, in: 0...100, onEditingChanged: { editing in
                    if !editing { writeVCP(code: 0x12, value: UInt16(contrast)) }
                })
            }

            // Input Source Selector
            HStack {
                Image(systemName: "cable.connector")
                Text("Input:")
                Spacer()
                HStack(spacing: 6) {
                    ForEach(allAvailableInputs) { input in
                        InputSourceButton(
                            input: input,
                            isActive: currentInputID == input.value,
                            isPending: pendingInputID == input.value,
                            isDisabled: isSwitchingInput,
                            action: {
                                guard !isInitialLoad, !isSwitchingInput, currentInputID != input.value else { return }
                                switchInput(to: input.value)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: readInitialValues)
        .onReceive(displayManager.refreshPublisher) { _ in
            readInitialValues()
        }
    }

    private func readInitialValues() {
        isInitialLoad = true
        DispatchQueue.global(qos: .userInitiated).async {
            let b = display.service?.read(command: 0x10)
            let c = display.service?.read(command: 0x12)
            let i = display.service?.read(command: 0x60)
            
            DispatchQueue.main.async {
                if let b = b { self.brightness = Float(b.current) }
                if let c = c { self.contrast = Float(c.current) }

                if let i = i {
                    let currentValue = UInt16(i.current & 0xFF)
                    if let matchedInput = commonInputs.first(where: { $0.value == currentValue }) {
                        self.currentInputID = matchedInput.value
                    } else {
                        let unknown = InputSource(name: "Unknown (Value: \(currentValue))", value: currentValue)
                        self.unknownInput = unknown
                        self.currentInputID = unknown.value
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isInitialLoad = false
                }
            }
        }
    }

    private func writeVCP(code: UInt8, value: UInt16) {
        DispatchQueue.global(qos: .userInitiated).async {
            _ = display.service?.write(command: code, value: value)
        }
    }
    
    private func switchInput(to inputID: UInt16) {
        isSwitchingInput = true
        pendingInputID = inputID
        
        DispatchQueue.global(qos: .userInitiated).async {
            _ = display.service?.write(command: 0x60, value: inputID)
            
            DispatchQueue.main.async {
                self.currentInputID = inputID
                self.isSwitchingInput = false
                self.pendingInputID = nil
            }
        }
    }
}

// MARK: - Input Source Button Component

private struct InputSourceButton: View {
    let input: InputSource
    let isActive: Bool
    let isPending: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isPending {
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 12, height: 12)
                }
                Text(input.name)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(6)
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isActive { return .accentColor }
        return Color.primary.opacity(0.1)
    }
    
    private var textColor: Color {
        if isActive { return .white }
        return .primary
    }
}