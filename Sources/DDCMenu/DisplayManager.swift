import Foundation
import SwiftDDC
import CoreGraphics

class DisplayManager: ObservableObject {
    @Published var mainDisplay: DDCDisplay?
    @Published var otherDisplays: [DDCDisplay] = []

    init() {
        self.refreshDisplays()
    }

    func refreshDisplays() {
        let allDisplays = DisplayFinder.findAll()
        let mainDisplayID = CGMainDisplayID()

        // Find the DDCDisplay that corresponds to the main display ID
        // We need to get CoreDisplay info to bridge the gap.
        var foundMainDisplay: DDCDisplay?
        for display in allDisplays {
            // This is a simplified matching logic. A real implementation might need
            // to be more robust, e.g., by matching serial numbers or EDID UUIDs.
            // For now, we assume a simple correlation might exist via properties.
            // A better way is to get CGDirectDisplayID from IORegistry if possible.
            // Let's find the DisplayInfo for the main display first.
            if let mainDisplayInfo = DisplayInfo(displayID: mainDisplayID),
               mainDisplayInfo.uuid == display.edidUUID {
                foundMainDisplay = display
                break
            }
        }

        DispatchQueue.main.async {
            self.mainDisplay = foundMainDisplay
            self.otherDisplays = allDisplays.filter { $0.edidUUID != foundMainDisplay?.edidUUID }
        }
    }
}