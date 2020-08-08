//
//  Sequence+.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/25.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation

extension Sequence {
    
    func sorted <P> (by keyPath: KeyPath<Element, P>, _ comparison: (P, P) throws -> Bool) rethrows -> [Element] {
        
        try sorted(by: { try comparison($0[keyPath: keyPath], $1[keyPath: keyPath]) })
        
    }
    
}
