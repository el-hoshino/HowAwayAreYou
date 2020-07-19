//
//  ImageData.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/19.
//  Copyright © 2020 Crazism. All rights reserved.
//

import UIKit

struct ImageData {
    
    var image: UIImage
    
    init(uiImage: UIImage) {
        self.image = uiImage
    }
    
    init(cgImage: CGImage, scale: CGFloat, orientation: UIImage.Orientation) {
        self.image = UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }
    
}
