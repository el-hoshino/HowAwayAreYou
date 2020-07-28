//
//  ImageData.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/19.
//  Copyright © 2020 Crazism. All rights reserved.
//

import UIKit
import SwiftUI

struct ImageData {
    
    enum Orientation {
        case up
        case right
    }
    
    let cgImage: CGImage
    let scale: CGFloat
    let orientation: Orientation
    
    var image: UIImage {
        UIImage(cgImage: cgImage, scale: scale, orientation: orientation.uiOrientation)
    }
    
    init(uiImage: UIImage) {
        self.cgImage = uiImage.cgImage!
        self.scale = uiImage.scale
        self.orientation = Orientation(uiOrientation: uiImage.imageOrientation)
    }
    
    init(cgImage: CGImage, scale: CGFloat, orientation: Orientation) {
        self.cgImage = cgImage
        self.scale = scale
        self.orientation = orientation
    }
    
}

extension ImageData.Orientation {
    
    init(uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:
            self = .up
            
        case .right:
            self = .right
            
        default:
            assertionFailure()
            self = .up
        }
    }
    
    var uiOrientation: UIImage.Orientation {
        switch self {
        case .up:
            return .up
            
        case .right:
            return .right
        }
    }
    
    var swiftOrientation: Image.Orientation {
        switch self {
        case .up:
            return .up
            
        case .right:
            return .right
        }
    }
    
}
