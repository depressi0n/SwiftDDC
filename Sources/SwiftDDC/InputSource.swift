import Foundation

public struct InputSource: Identifiable, Hashable {
    public var id: UInt16 { value }
    public let name: String
    public let value: UInt16

    public init(name: String, value: UInt16) {
        self.name = name
        self.value = value
    }
}

public let commonInputs: [InputSource] = [
    InputSource(name: "DisplayPort 1", value: 15),
    InputSource(name: "DisplayPort 2", value: 16),
    InputSource(name: "HDMI 1", value: 17),
    InputSource(name: "HDMI 2", value: 18),
    InputSource(name: "USB-C", value: 27),
]