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
    
    @State private var topLeftAngle: Double = 0
    @State private var topRightAngle: Double = 0
    @State private var bottomRightAngle: Double = 0
    @State private var bottomLeftAngle: Double = 0
    
    var body: some View {
        GeometryReader { proxy in
            Path.topLeftArc(proxy: proxy, rotation: .radians(self.topLeftAngle), color: self.status.color)
                .setupAnimationOnAppear(flag: self.status.spins, onFlagTrue: { self.topLeftAngle += .pi * 2 }, onFlagFalse: { self.topLeftAngle = 0 })
            Path.topRightArc(proxy: proxy, rotation: .radians(self.topRightAngle), color: self.status.color)
                .setupAnimationOnAppear(flag: self.status.spins, onFlagTrue: { self.topRightAngle -= .pi * 2 }, onFlagFalse: { self.topRightAngle = 0 })
            Path.bottomRightArc(proxy: proxy, rotation: .radians(self.bottomRightAngle), color: self.status.color)
                .setupAnimationOnAppear(flag: self.status.spins, onFlagTrue: { self.bottomRightAngle += .pi * 2 }, onFlagFalse: { self.bottomRightAngle = 0 })
            Path.bottomLeftArc(proxy: proxy, rotation: .radians(self.bottomLeftAngle), color: self.status.color)
                .setupAnimationOnAppear(flag: self.status.spins, onFlagTrue: { self.bottomLeftAngle -= .pi * 2 }, onFlagFalse: { self.bottomLeftAngle = 0 })
        }
    }
    
}

private extension GeometryProxy {
    
    var center: CGPoint {
        .init(x: size.width / 2, y: size.height / 2)
    }
    
    var fitRadius: CGFloat {
        min(size.width, size.height) / 2
    }
    
}

private extension Animation {
    
    static func repeatAnimation(duration: TimeInterval) -> Animation {
        linear(duration: duration).repeatForever(autoreverses: false)
    }
    
}

private extension View {
    
    func setupAnimationOnAppear(flag: Bool, onFlagTrue: @escaping () -> Void, onFlagFalse: @escaping () -> Void) -> some View {
        onAppear {
            if flag == true {
                withAnimation(Animation.repeatAnimation(duration: .random(in: 2 ... 5)), onFlagTrue)
            } else {
                withAnimation(.easeOut(duration: 0.2), onFlagFalse)
            }
        }
    }
    
}

private extension Path {
    
    private static let marginDegrees: Double = 5
    private typealias ArcAngles = (startAngle: Angle, endAngle: Angle)
    private static let topLeftArcAngles: ArcAngles = ((.degrees(180 + marginDegrees), .degrees(270 - marginDegrees)))
    private static let topRightArcAngles: ArcAngles = ((.degrees(270 + marginDegrees), .degrees(0 - marginDegrees)))
    private static let bottomRightArcAngles: ArcAngles = ((.degrees(0 + marginDegrees), .degrees(90 - marginDegrees)))
    private static let bottomLeftArcAngles: ArcAngles = ((.degrees(90 + marginDegrees), .degrees(180 - marginDegrees)))
    
    private static func addArc(center: CGPoint, radius: CGFloat, angles: ArcAngles, rotation: Angle, color: Color, lineWidth: CGFloat) -> some View {
        Path { path in
            path.addArc(center: center, radius: radius, startAngle: angles.startAngle, endAngle: angles.endAngle, clockwise: false)
        }
        .rotation(rotation)
        .stroke(color, lineWidth: lineWidth)
    }
    
    static func topLeftArc(proxy: GeometryProxy, rotation: Angle, color: Color) -> some View {
        Path.addArc(center: proxy.center, radius: proxy.fitRadius - 22, angles: topLeftArcAngles, rotation: rotation, color: color, lineWidth: 10)
    }
    
    static func topRightArc(proxy: GeometryProxy, rotation: Angle, color: Color) -> some View {
        ZStack {
            Path.addArc(center: proxy.center, radius: proxy.fitRadius - 12, angles: topRightArcAngles, rotation: rotation, color: color, lineWidth: 4)
            Path.addArc(center: proxy.center, radius: proxy.fitRadius - 30, angles: topRightArcAngles, rotation: rotation, color: color, lineWidth: 10)
        }
    }
    
    static func bottomRightArc(proxy: GeometryProxy, rotation: Angle, color: Color) -> some View {
        Path.addArc(center: proxy.center, radius: proxy.fitRadius - 14, angles: bottomRightArcAngles, rotation: rotation, color: color, lineWidth: 10)
    }
    
    static func bottomLeftArc(proxy: GeometryProxy, rotation: Angle, color: Color) -> some View {
        Path.addArc(center: proxy.center, radius: proxy.fitRadius - 10, angles: bottomLeftArcAngles, rotation: rotation, color: color, lineWidth: 10)
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
