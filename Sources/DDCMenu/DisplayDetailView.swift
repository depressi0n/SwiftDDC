import SwiftUI
import SwiftDDC

struct DisplayDetailView: View {
    let display: DDCDisplay

    @State private var brightness: Float = 0
    @State private var contrast: Float = 0
    
    @State private var currentInputID: UInt16?
    @State private var unknownInput: InputSource?
    @State private var isInitialLoad = true

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

            // Refactored Input Source Picker
            Picker(selection: $currentInputID) {
                ForEach(allAvailableInputs) { input in
                    Text(input.name).tag(input.value as UInt16?)
                }
            } label: {
                HStack {
                    Image(systemName: "cable.connector")
                    Text("Input")
                    Spacer()
                    Text(allAvailableInputs.first { $0.value == currentInputID }?.name ?? "Reading...")
                        .foregroundColor(.secondary)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: currentInputID) { newValue in
                guard !isInitialLoad, let value = newValue else { return }
                writeVCP(code: 0x60, value: value)
            }
        }
        .padding()
        .onAppear(perform: readInitialValues)
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
}