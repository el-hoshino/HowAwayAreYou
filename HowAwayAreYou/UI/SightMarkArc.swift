//
//  SightMarkArc.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/08/09.
//  Copyright © 2020 Crazism. All rights reserved.
//

import UIKit

final class MarkArc: UIView {
    
    enum ArcPosition: Int, CaseIterable {
        
        case bottomRight = 0
        case bottomLeft
        case topLeft
        case topRight
        
    }
    
    let arcPosition: ArcPosition
    
    var arcColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }
    var spins: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var spinAnimator: UIViewPropertyAnimator?
    private var lockAnimator: UIViewPropertyAnimator?
    
    init(arcPosition: ArcPosition, arcColor: UIColor, spins: Bool) {
        
        self.arcPosition = arcPosition
        self.arcColor = arcColor
        self.spins = spins
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        updateSpinAnimation()
        
    }
    
    convenience init() {
        self.init(arcPosition: ArcPosition(rawValue: 0)!, arcColor: .black, spins: false)
    }
    
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        arcColor.setStroke()
        arcPosition.arcs(in: rect).forEach({ $0.stroke() })
        updateSpinAnimation()
    }
    
    private func updateSpinAnimation() {
        spins ? spin() : lock()
    }
    
    private func spin() {
        
        if spinAnimator?.isRunning ?? false {
            return
        }
        
        lockAnimator?.stopAnimation(true)
        
        setupSpinAnimator(duration: .random(in: 2 ... 5),
                          destination: arcPosition.spinDirection.rotationDestination)
        
    }
    
    private func lock() {
        
        if lockAnimator?.isRunning ?? false {
            return
        }
        
        spinAnimator?.stopAnimation(true)
        
        setupLockAnimator()
        
    }
    
    private func setupSpinAnimator(duration: TimeInterval, destination: CGFloat) {
        
        spinAnimator = .runningPropertyAnimator(withDuration: duration,
                                                delay: 0,
                                                options: [.curveLinear],
                                                animations: { [weak self, destination] in
            UIView.animateKeyframes(withDuration: 0,
                                    delay: 0,
                                    options: .calculationModeLinear,
                                    animations: { [weak self, destination] in
                                        
                let frameCount = 4
                let relativeDuration: TimeInterval = 1 / TimeInterval(frameCount)
                                        
                for keyFrame in (0 ..< frameCount) {
                    
                    let startTiming = TimeInterval(keyFrame) / TimeInterval(frameCount)
                    let rotationAngle = destination * CGFloat(keyFrame + 1) / CGFloat(frameCount)
                    
                    UIView.addKeyframe(withRelativeStartTime: startTiming, relativeDuration: relativeDuration) { [weak self] in
                        self?.transform = .init(rotationAngle: rotationAngle)
                    }
                    
                }
                                        
            })
                                                    
        }, completion: { [weak self, duration, destination] position in
            if position == .end {
                self?.setupSpinAnimator(duration: duration, destination: destination)
            }
        })
        
        spinAnimator?.startAnimation()
        
    }
    
    private func setupLockAnimator() {
        
        lockAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: { [weak self] in
            self?.transform = .identity
        })
        
        lockAnimator?.startAnimation()
        
    }
    
}

extension MarkArc {
    
    static func makeArcs(status: TargetStatus) -> [MarkArc] {
        
        let marks = MarkArc.ArcPosition.allCases.map { (position) -> MarkArc in
            let mark = MarkArc(arcPosition: position, arcColor: status.color, spins: status.spins)
            mark.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return mark
        }
        
        return marks
        
    }
    
    func update(_ status: TargetStatus) {
        
        arcColor = status.color
        spins = status.spins
        
    }
    
}

private extension MarkArc.ArcPosition {
    
    enum SpinDirection {
        
        case clockWise
        case counterClockWise
        
        var rotationDestination: CGFloat {
            switch self {
            case .clockWise:
                return .pi * 2
                
            case .counterClockWise:
                return .pi * -2
            }
        }
        
    }
    
    var spinDirection: SpinDirection {
        switch rawValue % 2 {
        case 0:
            return .clockWise
            
        case _:
            return .counterClockWise
        }
    }
    
    var arcPart: ClosedRange<CGFloat> {
        let start = CGFloat(rawValue) / CGFloat(Self.totalCount) + 0.01
        let end = CGFloat(rawValue + 1) / CGFloat(Self.totalCount) - 0.01
        return start ... end
    }
    
    private typealias ArcParameter = (radiusInset: CGFloat, lineWidth: CGFloat)
    private var arcParameters: [ArcParameter] {
        switch self {
        case .bottomRight:
            return [(5, 10)]
            
        case .bottomLeft:
            return [(8, 10)]
            
        case .topLeft:
            return [(14, 10)]
            
        case .topRight:
            return [(3, 5), (16, 12)]
        }
    }
    
    func arcs(in rect: CGRect) -> [UIBezierPath] {
        
        let paths = arcParameters.map { parameter -> UIBezierPath in
            let path = UIBezierPath.arc(center: rect.center,
                                        radius: rect.size.width * 0.5 - parameter.radiusInset,
                                        part: arcPart)
            path.lineWidth = parameter.lineWidth
            return path
        }
        
        return paths
        
    }
    
}

private extension TargetStatus {
    
    var spins: Bool {
        switch self {
        case .open:
            return true
        case .locked:
            return false
        }
    }
    
    var color: UIColor {
        switch self {
        case .open:
            return UIColor.gray.withAlphaComponent(0.8)
            
        case .locked(dangerLevel: let level):
            return .init(hue: (1 - CGFloat(level)) / .pi, saturation: 0.8, brightness: 0.8, alpha: 1)
        }
    }
    
}

private extension UIBezierPath {
    
    private static let totalAngle = CGFloat.pi * 2
    
    static func arc(center: CGPoint, radius: CGFloat, part: ClosedRange<CGFloat>) -> UIBezierPath {
        UIBezierPath(arcCenter: center,
                     radius: radius,
                     startAngle: totalAngle * part.lowerBound,
                     endAngle: totalAngle * part.upperBound,
                     clockwise: true)
    }
    
}
