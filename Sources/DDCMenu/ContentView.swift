import SwiftUI

struct ContentView: View {
    @EnvironmentObject var displayManager: DisplayManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("SwiftDDC Menu")
                .font(.headline)
                .padding([.top, .leading, .trailing])

            Divider()

            ScrollView {
                VStack {
                    if let mainDisplay = displayManager.mainDisplay {
                        DisplayDetailView(display: mainDisplay)
                            .padding(.horizontal)
                        if !displayManager.otherDisplays.isEmpty {
                            Divider().padding(.vertical, 4)
                            Text("Other Displays")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    }

                    if displayManager.otherDisplays.isEmpty && displayManager.mainDisplay == nil {
                        Text("No external displays found.")
                            .padding()
                    } else {
                        ForEach(displayManager.otherDisplays, id: \.edidUUID) { display in
                            DisclosureGroup {
                                DisplayDetailView(display: display)
                            } label: {
                                Text(display.productName ?? "Unknown Display")
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Button("Refresh") {
                    displayManager.refreshDisplays()
                }
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }.padding()
        }
        .frame(width: 350, height: 450)
    }
}