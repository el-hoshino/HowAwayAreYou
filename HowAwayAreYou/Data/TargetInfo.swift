//
//  TargetInfo.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/20.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation
import CoreGraphics

struct TargetInfo {
    var relativePosition: CGPoint
    var relativeSize: CGSize
    var orientation: ImageData.Orientation
    var distance: Float
    
    var orientatedRelativePosition: CGPoint {
        switch orientation {
        case .up:
            return relativePosition
            
        case .right:
            return .init(x: 1 - relativePosition.y, y: relativePosition.x)
        }
    }
    
    var orientatedRelativeSize: CGSize {
        switch orientation {
        case .up:
            return relativeSize
            
        case .right:
            return .init(width: relativeSize.height, height: relativeSize.width)
        }
    }
}
