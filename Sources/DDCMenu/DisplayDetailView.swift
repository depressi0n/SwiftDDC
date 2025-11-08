import SwiftUI
import SwiftDDC

struct DisplayDetailView: View {
    let display: DDCDisplay

    @State private var brightness: Float = 0
    @State private var contrast: Float = 0
    @State private var currentInput: InputSource?

    var body: some View {
        VStack(alignment: .leading) {
            Text(display.productName ?? "Unknown Display")
                .font(.headline)
            
            // Brightness Slider
            HStack {
                Image(systemName: "sun.max.fill")
                Slider(value: $brightness, in: 0...100, onEditingChanged: { editing in
                    if !editing {
                        writeVCP(code: 0x10, value: UInt16(brightness))
                    }
                })
            }

            // Contrast Slider
            HStack {
                Image(systemName: "circle.lefthalf.filled")
                Slider(value: $contrast, in: 0...100, onEditingChanged: { editing in
                    if !editing {
                        writeVCP(code: 0x12, value: UInt16(contrast))
                    }
                })
            }
            
            // Input Source Picker
            Picker("Input", selection: $currentInput) {
                ForEach(commonInputs) { input in
                    Text(input.name).tag(input as InputSource?)
                }
            }
            .onChange(of: currentInput) { newInput in
                if let value = newInput?.value {
                    writeVCP(code: 0x60, value: value)
                }
            }
        }
        .padding()
        .onAppear(perform: readInitialValues)
    }

    private func readInitialValues() {
        DispatchQueue.global(qos: .userInitiated).async {
            let b = display.service?.read(command: 0x10) // Brightness
            let c = display.service?.read(command: 0x12) // Contrast
            let i = display.service?.read(command: 0x60) // Input Source
            
            DispatchQueue.main.async {
                if let b = b { self.brightness = Float(b.current) }
                if let c = c { self.contrast = Float(c.current) }
                if let i = i {
                    self.currentInput = commonInputs.first { $0.value == i.current }
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