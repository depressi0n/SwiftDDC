//  Copyright © @waydabber

import CoreGraphics
import Foundation
import IOKit

// MARK: - Core Display and IOKit Function Declarations

/// IOAVServiceRef type alias for CFTypeRef (the raw IOKit service reference)
public typealias IOAVServiceRef = CFTypeRef

/// Core Display function declarations using @_silgen_name
@_silgen_name("IOAVServiceCreate")
public func IOAVServiceCreate(_ allocator: CFAllocator?) -> Unmanaged<IOAVServiceRef>!

@_silgen_name("IOAVServiceCreateWithService")
public func IOAVServiceCreateWithService(_ allocator: CFAllocator?, _ service: io_service_t)
    -> Unmanaged<IOAVServiceRef>!

@_silgen_name("IOAVServiceReadI2C")
public func IOAVServiceReadI2C(
    _ service: IOAVServiceRef, _ chipAddress: UInt32, _ offset: UInt32,
    _ outputBuffer: UnsafeMutableRawPointer, _ outputBufferSize: UInt32
) -> IOReturn

@_silgen_name("IOAVServiceWriteI2C")
public func IOAVServiceWriteI2C(
    _ service: IOAVServiceRef, _ chipAddress: UInt32, _ dataAddress: UInt32,
    _ inputBuffer: UnsafeRawPointer, _ inputBufferSize: UInt32
) -> IOReturn

@_silgen_name("CoreDisplay_DisplayCreateInfoDictionary")
public func CoreDisplay_DisplayCreateInfoDictionary(_ displayID: CGDirectDisplayID) -> Unmanaged<CFDictionary>!


// MARK: - Display Info Structure

/// Display information parsed from CoreDisplay dictionary
public struct DisplayInfo {
    public let displayID: CGDirectDisplayID
    public let vendorID: Int?
    public let productID: Int?
    public let serialNumber: Int?
    public let yearOfManufacture: Int?
    public let weekOfManufacture: Int?
    public let verticalImageSize: Int?
    public let horizontalImageSize: Int?
    public let productName: String?
    public let uuid: String?
    public let ioLocation: String?
    
    /// Initialize DisplayInfo from a display ID
    /// - Parameter displayID: The CGDirectDisplayID to query
    /// - Returns: nil if the display info cannot be retrieved
    public init?(displayID: CGDirectDisplayID) {
        // 获取显示器信息字典
        guard let infoDict = CoreDisplay_DisplayCreateInfoDictionary(displayID)?.takeRetainedValue() as? [String: Any] else {
            return nil
        }
        
        // 设置 displayID
        self.displayID = displayID
        
        // 安全地解析 vendorID 和 productID
        self.vendorID = infoDict[kDisplayVendorID] as? Int
        self.productID = infoDict[kDisplayProductID] as? Int
        
        // 解析序列号
        self.serialNumber = infoDict[kDisplaySerialNumber] as? Int
        
        // 解析制造信息，将 Int64 转换为 Int
        if let year = infoDict[kDisplayYearOfManufacture] as? Int64 {
            self.yearOfManufacture = Int(year)
        } else {
            self.yearOfManufacture = nil
        }
        
        if let week = infoDict[kDisplayWeekOfManufacture] as? Int64 {
            self.weekOfManufacture = Int(week)
        } else {
            self.weekOfManufacture = nil
        }
        
        // 解析图像尺寸信息，将 Int64 转换为 Int
        if let vSize = infoDict[kDisplayVerticalImageSize] as? Int64 {
            self.verticalImageSize = Int(vSize)
        } else {
            self.verticalImageSize = nil
        }
        
        if let hSize = infoDict[kDisplayHorizontalImageSize] as? Int64 {
            self.horizontalImageSize = Int(hSize)
        } else {
            self.horizontalImageSize = nil
        }
        
        // 解析产品名称（优先使用英文名称）
        if let nameList = infoDict["DisplayProductName"] as? [String: String] {
            self.productName = nameList["en_US"] ?? nameList.first?.value
        } else {
            self.productName = nil
        }
        
        // 解析 UUID（使用字符串键名）
        self.uuid = infoDict["UUID"] as? String
        
        // 解析显示器位置信息
        self.ioLocation = infoDict[kIODisplayLocationKey] as? String
    }
}
