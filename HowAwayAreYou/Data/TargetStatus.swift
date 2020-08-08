//
//  TargetStatus.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/08/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation

enum TargetStatus {
    
    case open
    case locked(dangerLevel: Double)
    
    init(dangerLevel: Double?) {
        
        switch dangerLevel {
        case .none:
            self = .open
            
        case .some(let level):
            self = .locked(dangerLevel: level)
        }
        
    }
    
}
