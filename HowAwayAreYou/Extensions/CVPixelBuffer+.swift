//
//  CVPixelBuffer+.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/20.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation
import AVFoundation

extension CVPixelBuffer {
    
    var width: Int {
        CVPixelBufferGetWidth(self)
    }
    
    var height: Int {
        CVPixelBufferGetHeight(self)
    }
    
    func value(at point: CGPoint) -> Float {
        
        // Assume the CVPixelBuffer is Float32 data
        assert(CVPixelBufferGetPixelFormatType(self) == kCVPixelFormatType_DepthFloat32)
        
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0)) }
        let depthPointer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float32>.self)
        let depthAtPoint = depthPointer[Int(point.y) * width + Int(point.x)]
        
        return depthAtPoint

    }
    
    func value(atRelativePoint point: CGPoint) -> Float {
        
        let x = point.x * CGFloat(width)
        let y = point.y * CGFloat(height)
        
        return value(at: .init(x: x, y: y))
        
    }
    
}
