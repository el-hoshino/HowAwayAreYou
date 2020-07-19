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
    var imageData: ImageData? { get }
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
        Image.from(imageInput.imageData?.image)
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

private extension Image.Orientation {
    
    var uiOrientation: UIImage.Orientation {
        switch self {
        case .right:
            return .right
            
        default:
            return .up
        }
    }
    
}

private extension Image {
    
    static func from(_ uiImage: UIImage?) -> Image {
        
        guard let uiImage = uiImage else {
            return Image(uiImage: UIImage())
        }
        
        // Seems like there's a bug while directly generate Image from rotated UIImage that aspectRatio can't retrieved the correct rotated width/height,
        // so as a workaround, generate Image from the UIImage's CGImage.
        return Image(decorative: uiImage.cgImage!, scale: uiImage.scale, orientation: uiImage.imageOrientation.swiftOrientation)
        
    }
    
}

private extension UIImage.Orientation {
    
    private func transformToSwiftRawValue(from uiRawValue: Int) -> UInt8 {
        
        /*
         | RawValue | UIImage.Orientation | Image.Orientation |
         |:--------:|--------------------:|:------------------|
         |         0|                  up | up                |
         |         1|                down | left              |
         |         2|                left | upMirrored        |
         |         3|               right | leftMirrored      |
         |         4|          upMirrored | downMirrored      |
         |         5|        downMirrored | rightMirrored     |
         |         6|        leftMirrored | down              |
         |         7|       rightMirrored | right             |
         */
        
        if uiRawValue % 2 == 0 {
            return UInt8(uiRawValue / 2)
            
        } else if uiRawValue > Image.Orientation.allCases.count / 2 {
            return UInt8(uiRawValue / 2 + 2)
            
        } else {
            return UInt8(uiRawValue / 2 + 6)
        }
        
    }
    
    var swiftOrientation: Image.Orientation {
        let uiRawValue = rawValue
        let swiftRawValue = transformToSwiftRawValue(from: uiRawValue)
        return Image.Orientation(rawValue: swiftRawValue)!
    }
    
}

struct CameraFinderView_Preview: PreviewProvider {
    
    final class MockImageInput: ProcessedImageInputObject {
        
        var imageData: ImageData? {
           ImageData(uiImage:  #imageLiteral(resourceName: "DummyBackground"))
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
