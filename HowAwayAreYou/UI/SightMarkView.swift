//
//  SightMarkView.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/18.
//  Copyright © 2020 Crazism. All rights reserved.
//

import SwiftUI

struct SightMarkView: View {
    
    enum Status {
        
        case open
        case locked(dangerLevel: Double)
        
        var spins: Bool {
            switch self {
            case .open:
                return true
            case .locked:
                return false
            }
        }
        
        var color: Color {
            switch self {
            case .open:
                return Color.gray.opacity(0.8)
                
            case .locked(dangerLevel: let level):
                return .init(hue: (1 - level) / .pi, saturation: 0.8, brightness: 0.8)
            }
        }
        
    }
    
    let status: Status
    
    @State private var angles: [Double] = [0, 0, 0, 0]
        
    var body: some View {
        ZStack {
            Circle()
                .inset(by: 5)
                .trim(from: 0.02, to: 0.23)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                .fill(status.color)
                .rotationEffect(.radians(angles[0]))
            Circle()
                .inset(by: 10)
                .trim(from: 0.27, to: 0.48)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                .fill(status.color)
                .rotationEffect(.radians(-angles[1]))
            Circle()
                .inset(by: 12)
                .trim(from: 0.52, to: 0.73)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                .fill(status.color)
                .rotationEffect(.radians(angles[2]))
            ZStack {
                Circle()
                    .trim(from: 0.77, to: 0.98)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .butt))
                    .fill(status.color)
                
                Circle()
                    .inset(by: 15)
                    .trim(from: 0.77, to: 0.98)
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .butt))
                    .fill(status.color)
            }
                .rotationEffect(.radians(-angles[3]))
        }
        .onAppear {
            self.toggleSpinAnimation(spins: self.status.spins)
        }
    }
    
    func toggleSpinAnimation(spins: Bool) {
        for i in self.angles.indices {
            withAnimation(.strokeAnimation(spins: spins)) {
                self.angles[i] = spins ? .pi * 2 : 0
            }
        }
    }
    
}

private extension Animation {
    
    private static func repeatAnimation(duration: TimeInterval) -> Animation {
        linear(duration: duration).repeatForever(autoreverses: false)
    }
    
    static func strokeAnimation(spins: Bool) -> Animation {
        spins ? repeatAnimation(duration: .random(in: 2 ... 5)) : .easeOut(duration: 0.2)
    }
    
}

struct TargetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SightMarkView(status: .open)
            SightMarkView(status: .locked(dangerLevel: 0))
            SightMarkView(status: .locked(dangerLevel: 0.5))
            SightMarkView(status: .locked(dangerLevel: 1))
        }
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
