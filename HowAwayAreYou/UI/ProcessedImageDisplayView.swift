//
//  ProcessedImageDisplayView.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/12.
//  Copyright © 2020 Crazism. All rights reserved.
//

import SwiftUI
import UIKit

protocol ProcessedImageInputObject: ObservableObject {
    var image: UIImage { get }
    typealias Target = (position: CGPoint, scale: CGFloat, scaleCriterionLengthKeyPath: KeyPath<CGSize, CGFloat>, distance: CGFloat)
    var target: Target? { get }
}

struct ProcessedImageDisplayView<ImageInput: ProcessedImageInputObject>: View {
    
    @ObservedObject var imageInput: ImageInput
    
    private var targetPosition: CGPoint {
        imageInput.target?.position ?? .init(x: 0.5, y: 0.5)
    }
    
    private var targetStatus: SightMarkView.Status {
        switch imageInput.dangerLevel {
        case .none:
            return .open
            
        case .some(let level):
            return .locked(dangerLevel: level)
        }
    }
    
    private func circleDiameter(by proxy: GeometryProxy) -> CGFloat {
        imageInput.targetDiameter(by: proxy) ?? proxy.size.width * 0.6
    }
    
    private func circlePosition(by proxy: GeometryProxy) -> CGPoint {
        targetPosition * proxy.size
    }
    
    var body: some View {
        Image(uiImage: imageInput.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(GeometryReader { (proxy) in
                withAnimation(.easeOut(duration: 0.2)) {
                    SightMarkView(status: self.targetStatus)
                        .frame(width: self.circleDiameter(by: proxy), height: self.circleDiameter(by: proxy))
                        .position(self.circlePosition(by: proxy))
                }
            })
    }
    
}

private extension ProcessedImageInputObject {
    
    var dangerLevel: Double? {
        
        guard let distance = target?.distance else {
            return nil
        }
        
        if distance >= 2 {
            return 0
            
        } else if distance <= 1 {
            return 1
            
        } else {
            return 2 - Double(distance)
        }
        
    }
    
    func targetDiameter(by proxy: GeometryProxy) -> CGFloat? {
        
        guard let target = target else {
            return nil
        }
        
        let scale = target.scale
        let criterionLength = proxy.size[keyPath: target.scaleCriterionLengthKeyPath]
        
        return criterionLength * scale
        
    }
    
}

private extension GeometryProxy {
    
    func criterionLength(by keyPath: KeyPath<CGSize, CGFloat>) -> CGFloat {
        size[keyPath: keyPath]
    }
    
}

private extension CGPoint {
    
    static func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        .init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }
    
}

struct CameraFinderView_Preview: PreviewProvider {
    
    final class MockImageInput: ProcessedImageInputObject {
        
        var image: UIImage {
            #imageLiteral(resourceName: "DummyBackground")
        }
        
        var timer: Timer!
        
        var target: ProcessedImageInputObject.Target? = nil
        
        private func random(in range: ClosedRange<CGFloat>) -> CGFloat {
            CGFloat.random(in: range)
        }
        
        init() {
            self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] (timer) in
                
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                if self.target == nil {
                    self.target = (.init(x: self.random(in: 0 ... 1), y: self.random(in: 0 ... 1)), self.random(in: 0.2 ... 0.8), \.width, self.random(in: 0.2 ... 3))
                } else {
                    self.target = nil
                }
                
            })
        }
        
    }
    
    static let input = MockImageInput()
    
    static var previews: some View {
        
        ProcessedImageDisplayView(imageInput: input)
        
    }
    
}
