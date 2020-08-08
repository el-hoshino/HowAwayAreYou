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
    var running: Bool { get set }
    var imageData: ImageData? { get }
    var targetInfo: TargetInfo? { get }
}

struct ProcessedImageDisplayView<ImageInput: ProcessedImageInputObject>: View {
    
    @ObservedObject var imageInput: ImageInput
    
    private var targetPosition: CGPoint {
        imageInput.targetInfo?.orientatedRelativePosition ?? .init(x: 0.5, y: 0.5)
    }
    
    private var targetStatus: TargetStatus {
        .init(dangerLevel: imageInput.dangerLevel)
    }
    
    private var warningText: String {
        switch imageInput.dangerLevel {
        case .none:
            return "Searching for face..."
            
        case .some(let level):
            switch level {
            case 0:
                return "Safe social distance"
                
            case 0...0.5:
                return "Approaching!"
                
            case 0.5...:
                return "Warning: TOO CLOSE!!"
                
            default:
                assertionFailure()
                return ""
            }
        }
    }
    
    private func circleDiameter(by proxy: GeometryProxy) -> CGFloat {
        imageInput.targetDiameter(by: proxy) ?? proxy.size.width * 0.5
    }
    
    private func circlePosition(by proxy: GeometryProxy) -> CGPoint {
        targetPosition * proxy.size
    }
    
    private func warningTextPosition(by proxy: GeometryProxy) -> CGPoint {
        let positionForCircle = circlePosition(by: proxy)
        let diameterForCircle = circleDiameter(by: proxy)
        return .init(x: positionForCircle.x, y: positionForCircle.y + (diameterForCircle / 2) + 16)
    }
    
    var body: some View {
        Image.from(imageInput.imageData)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(GeometryReader { (proxy) in
                ZStack {
                    SightMarkView(status: self.targetStatus)
                        .frame(width: self.circleDiameter(by: proxy), height: self.circleDiameter(by: proxy))
                        .position(self.circlePosition(by: proxy))
                    Text(self.warningText)
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.5))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .position(self.warningTextPosition(by: proxy))
                }
                    .animation(Animation.easeOut(duration: 0.2))
            })
            .onAppear {
                self.imageInput.running = true
            }
            .onDisappear {
                self.imageInput.running = false
            }
    }
    
}

private extension ProcessedImageInputObject {
    
    var dangerLevel: Double? {
        
        guard let distance = targetInfo?.distance else {
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
        
        guard let targetInfo = targetInfo else {
            return nil
        }
        
        let relativeSize = targetInfo.orientatedRelativeSize
        let size = relativeSize * proxy.size
        
        return size.longestLength
        
    }
    
}

private extension CGPoint {
    
    static func * (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        .init(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }
    
}

private extension CGSize {
    
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }
    
    var longestLength: CGFloat {
        max(width, height)
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
    
    static func from(_ imageData: ImageData?) -> Image {
        
        guard let imageData = imageData else {
            return Image(uiImage: UIImage())
        }
        
        // Seems like there's a bug while directly generate Image from rotated UIImage that aspectRatio can't retrieved the correct rotated width/height,
        // so as a workaround, generate Image from the UIImage's CGImage.
        return Image(decorative: imageData.cgImage, scale: imageData.scale, orientation: imageData.orientation.swiftOrientation)
        
    }
    
}

struct ProcessedImageDisplayView_Previews: PreviewProvider {
    
    final class MockImageInput: ProcessedImageInputObject {
        
        var timer: Timer!
        
        var running: Bool = false
        
        var imageData: ImageData? {
           ImageData(uiImage: #imageLiteral(resourceName: "DummyBackground"))
        }
        
        @Published var targetInfo: TargetInfo?
        
        private func random(in range: ClosedRange<CGFloat>) -> CGFloat {
            CGFloat.random(in: range)
        }
        
        init() {
            self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] (timer) in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if self.targetInfo == nil {
                    self.targetInfo = self.randomTargetInfo()
                } else {
                    self.targetInfo = nil
                }
            })
        }
        
        private func randomTargetInfo() -> TargetInfo {
            .init(relativePosition: .init(x: .random(in: 0.2 ... 0.8),
                                          y: .random(in: 0.2 ... 0.8)),
                  relativeSize: .init(width: .random(in: 0.1 ... 0.4),
                                      height: .random(in: 0.1 ... 0.4)),
                  orientation: .up,
                  distance: .random(in: 0.5 ... 5))
        }
        
    }
    
    static let input = MockImageInput()
    
    static var previews: some View {
        
        ProcessedImageDisplayView(imageInput: input)
        
    }
    
}
