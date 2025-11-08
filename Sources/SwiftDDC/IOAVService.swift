//  Copyright © @waydabber

import Foundation
import IOKit

// MARK: - IOAVService I2C Communication Wrapper

/// A struct that encapsulates IOAVServiceRef handle and provides I2C communication methods
public struct IOAVService {
    /// The underlying IOAVServiceRef handle
    private let service: IOAVServiceRef
    
    /// Initialize with an IOAVServiceRef handle
    /// - Parameter service: The IOAVServiceRef handle
    public init(service: IOAVServiceRef) {
        self.service = service
    }
    
    /// Perform I2C write operation
    /// - Parameters:
    ///   - chipAddress: I2C chip address
    ///   - dataAddress: I2C data register address
    ///   - data: Data buffer to write
    /// - Returns: true if write succeeded, false otherwise
    public func writeI2C(
        chipAddress: UInt32,
        dataAddress: UInt32,
        data: inout [UInt8]
    ) -> Bool {
        return IOAVServiceWriteI2C(
            self.service,
            chipAddress,
            dataAddress,
            &data,
            UInt32(data.count)
        ) == 0
    }
    
    /// Perform I2C read operation
    /// - Parameters:
    ///   - chipAddress: I2C chip address
    ///   - offset: I2C register offset
    ///   - buffer: Buffer to store read data
    /// - Returns: true if read succeeded, false otherwise
    public func readI2C(
        chipAddress: UInt32,
        offset: UInt32,
        buffer: inout [UInt8]
    ) -> Bool {
        return IOAVServiceReadI2C(
            self.service,
            chipAddress,
            offset,
            &buffer,
            UInt32(buffer.count)
        ) == 0
    }
    
    // MARK: - DDC Communication
    
    /// Build a complete DDC/CI write packet with proper checksum
    private static func buildDDCWritePacket(payload: [UInt8]) -> [UInt8] {
        let ARM64_DDC_7BIT_ADDRESS: UInt8 = 0x37
        let ARM64_DDC_DATA_ADDRESS: UInt8 = 0x51
        
        var packet: [UInt8] = [UInt8(payload.count + 1) | 0x80, UInt8(payload.count)] + payload
        
        var chkd: UInt8 = packet.count == 1 ? ARM64_DDC_7BIT_ADDRESS << 1 : ARM64_DDC_7BIT_ADDRESS << 1 ^ ARM64_DDC_DATA_ADDRESS
        for i in 0 ... packet.count - 1 {
            chkd ^= packet[i]
        }
        packet.append(chkd)
        
        return packet
    }
    
    /// DDC checksum calculator
    private static func checksum(chk: UInt8, data: inout [UInt8], start: Int, end: Int) -> UInt8 {
        var chkd: UInt8 = chk
        for i in start ... end {
            chkd ^= data[i]
        }
        return chkd
    }
    
    /// Perform DDC communication with retry logic
    /// - Parameters:
    ///   - send: Command payload to send
    ///   - reply: Buffer to store reply data
    ///   - writeSleepTime: Sleep time in microseconds after write
    ///   - numOfWriteCycles: Number of write cycles
    ///   - readSleepTime: Sleep time in microseconds before read
    ///   - numOfRetryAttemps: Number of retry attempts
    ///   - retrySleepTime: Sleep time in microseconds between retries
    /// - Returns: true if communication succeeded, false otherwise
    public func performDDCCommunication(
        send: inout [UInt8],
        reply: inout [UInt8],
        writeSleepTime: UInt32? = nil,
        numOfWriteCycles: UInt8? = nil,
        readSleepTime: UInt32? = nil,
        numOfRetryAttemps: UInt8? = nil,
        retrySleepTime: UInt32? = nil
    ) -> Bool {
        let ARM64_DDC_7BIT_ADDRESS: UInt8 = 0x37
        let ARM64_DDC_DATA_ADDRESS: UInt8 = 0x51
        let dataAddress = ARM64_DDC_DATA_ADDRESS
        var success = false
        
        var packet: [UInt8] = Self.buildDDCWritePacket(payload: send)
        
        for _ in 1 ... (numOfRetryAttemps ?? 4) + 1 {
            for _ in 1 ... max((numOfWriteCycles ?? 2) + 0, 1) {
                usleep(writeSleepTime ?? 10000)
                success = self.writeI2C(chipAddress: UInt32(ARM64_DDC_7BIT_ADDRESS), dataAddress: UInt32(dataAddress), data: &packet)
            }
            if !reply.isEmpty {
                usleep(readSleepTime ?? 50000)
                if self.readI2C(chipAddress: UInt32(ARM64_DDC_7BIT_ADDRESS), offset: UInt32(dataAddress), buffer: &reply) {
                    success = Self.checksum(chk: 0x50, data: &reply, start: 0, end: reply.count - 2) == reply[reply.count - 1]
                }
            }
            if success {
                return success
            }
            usleep(retrySleepTime ?? 20000)
        }
        return success
    }
    
    // MARK: - High-Level DDC Read/Write
    
    /// Read a DDC value from the display
    /// - Parameters:
    ///   - command: VCP command code
    ///   - writeSleepTime: Sleep time in microseconds after write
    ///   - numOfWriteCycles: Number of write cycles
    ///   - readSleepTime: Sleep time in microseconds before read
    ///   - numOfRetryAttemps: Number of retry attempts
    ///   - retrySleepTime: Sleep time in microseconds between retries
    /// - Returns: A tuple containing (current, max) values, or nil if failed
    public func read(
        command: UInt8,
        writeSleepTime: UInt32? = nil,
        numOfWriteCycles: UInt8? = nil,
        readSleepTime: UInt32? = nil,
        numOfRetryAttemps: UInt8? = nil,
        retrySleepTime: UInt32? = nil
    ) -> (current: UInt16, max: UInt16)? {
        var values: (UInt16, UInt16)?
        var send: [UInt8] = [command]
        var reply = [UInt8](repeating: 0, count: 11)
        if self.performDDCCommunication(
            send: &send,
            reply: &reply,
            writeSleepTime: writeSleepTime,
            numOfWriteCycles: numOfWriteCycles,
            readSleepTime: readSleepTime,
            numOfRetryAttemps: numOfRetryAttemps,
            retrySleepTime: retrySleepTime
        ) {
            let max = UInt16(reply[6]) * 256 + UInt16(reply[7])
            let current = UInt16(reply[8]) * 256 + UInt16(reply[9])
            values = (current, max)
        } else {
            values = nil
        }
        return values
    }
    
    /// Write a DDC value to the display
    /// - Parameters:
    ///   - command: VCP command code
    ///   - value: Value to write
    ///   - writeSleepTime: Sleep time in microseconds after write
    ///   - numOfWriteCycles: Number of write cycles
    ///   - numOfRetryAttemps: Number of retry attempts
    ///   - retrySleepTime: Sleep time in microseconds between retries
    /// - Returns: true if write succeeded, false otherwise
    public func write(
        command: UInt8,
        value: UInt16,
        writeSleepTime: UInt32? = nil,
        numOfWriteCycles: UInt8? = nil,
        numOfRetryAttemps: UInt8? = nil,
        retrySleepTime: UInt32? = nil
    ) -> Bool {
        var send: [UInt8] = [command, UInt8(value >> 8), UInt8(value & 255)]
        var reply: [UInt8] = []
        return self.performDDCCommunication(
            send: &send,
            reply: &reply,
            writeSleepTime: writeSleepTime,
            numOfWriteCycles: numOfWriteCycles,
            numOfRetryAttemps: numOfRetryAttemps,
            retrySleepTime: retrySleepTime
        )
    }
}
