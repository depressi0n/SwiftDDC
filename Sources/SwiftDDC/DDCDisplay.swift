//  Copyright © @waydabber

import Foundation

// MARK: - DDC Display Model

/// Represents a DDC display from IORegistry
public struct DDCDisplay {
    public var edidUUID: String = ""
    public var manufacturerID: String = ""
    public var productName: String = ""
    public var serialNumber: Int64 = 0
    public var alphanumericSerialNumber: String = ""
    public var location: String = ""
    public var ioDisplayLocation: String = ""
    public var transportUpstream: String = ""
    public var transportDownstream: String = ""
    public var service: IOAVService?
    public var serviceLocation: Int = 0
    public var displayAttributes: NSDictionary?
}