//
//  CGRect+.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/08/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

import CoreGraphics

extension CGRect {
    
    var center: CGPoint {
        .init(x: midX, y: midY)
    }
    
}
