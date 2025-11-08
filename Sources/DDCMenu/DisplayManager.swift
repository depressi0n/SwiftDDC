import Foundation
import SwiftDDC
import CoreGraphics
import Combine

class DisplayManager: ObservableObject {
    @Published var mainDisplay: DDCDisplay?
    @Published var otherDisplays: [DDCDisplay] = []
    
    let refreshPublisher = PassthroughSubject<Void, Never>()

    init() {
        self.refreshDisplays()
    }

    func refreshDisplays() {
        let allDisplays = DisplayFinder.findAll()
        let mainDisplayID = CGMainDisplayID()

        // Find the DDCDisplay that corresponds to the main display ID
        // We need to get CoreDisplay info to bridge the gap.
        var foundMainDisplay: DDCDisplay?
        if let mainDisplayInfo = DisplayInfo(displayID: mainDisplayID) {
            // Primary matching strategy: EDID UUID
            if let mainUUID = mainDisplayInfo.uuid {
                foundMainDisplay = allDisplays.first { $0.edidUUID == mainUUID }
            }

            // Fallback strategy: Serial Number
            if foundMainDisplay == nil, let mainSerial = mainDisplayInfo.serialNumber {
                foundMainDisplay = allDisplays.first { $0.serialNumber == mainSerial }
            }
        }

        DispatchQueue.main.async {
            self.mainDisplay = foundMainDisplay
            self.otherDisplays = allDisplays.filter { $0.edidUUID != foundMainDisplay?.edidUUID }
            self.refreshPublisher.send()
        }
    }
}