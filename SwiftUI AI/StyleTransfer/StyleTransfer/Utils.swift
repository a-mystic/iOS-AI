//
//  Utils.swift
//  StyleTransfer
//
//  Created by mystic on 2022/10/16.
//

import UIKit
import CoreML

extension MLMultiArray {
    convenience init(size: Int, selecting selectedIndex: Int) {
        do {
            try self.init(shape: [size] as [NSNumber], dataType: MLMultiArrayDataType.double)
        } catch {
            fatalError("Could not initialise MLMultiArray for MLModel options.")
        }
        for index in 0..<size {
            self[index] = (index == selectedIndex) ? 1 : 0
        }
    }
}

extension CVPixelBufferLockFlags {
    static let readAndWrite = CVPixelBufferLockFlags(rawValue: 0)
}

extension CVPixelBuffer {
    var width: Int { return CVPixelBufferGetWidth(self) }
    var height: Int { return CVPixelBufferGetHeight(self) }
    var bytesPerRow: Int { return CVPixelBufferGetBytesPerRow(self) }
    var baseAddress: UnsafeMutableRawPointer? { return CVPixelBufferGetBaseAddress(self) }
    
    func perform<T>(permission: CVPixelBufferLockFlags, action: () -> (T?)) -> T? {
        CVPixelBufferLockBaseAddress(self, permission)
        let output = action()
        CVPixelBufferUnlockBaseAddress(self, permission)
        return output
    }
}

extension CGContext {
    static func createContext(for pixelBuffer: CVPixelBuffer) -> CGContext? {
        return CGContext(
                         data: pixelBuffer.baseAddress,
                         width: pixelBuffer.width,
                         height: pixelBuffer.height,
                         bitsPerComponent: 0,
                         bytesPerRow: pixelBuffer.bytesPerRow,
                         space: CGColorSpaceCreateDeviceRGB(),
                         bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue
        )
    }
    
    func makeUIIamge() -> UIImage? {
        if let cgImage = self.makeImage() {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

extension CGSize: CustomStringConvertible {
    public var description: String { return "\(self.width) * \(self.height)" }
}
