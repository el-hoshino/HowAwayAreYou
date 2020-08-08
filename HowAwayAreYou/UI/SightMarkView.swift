//
//  SightMarkView.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/18.
//  Copyright © 2020 Crazism. All rights reserved.
//

import SwiftUI
import UIKit

struct SightMarkView: UIViewRepresentable {
    
    var status: TargetStatus
    
    init(status: TargetStatus) {
        self.status = status
    }
    
    func makeUIView(context: Context) -> SightMarkUIView {
        SightMarkUIView(status: status)
    }
    
    func updateUIView(_ uiView: SightMarkUIView, context: Context) {
        uiView.status = status
    }
    
}

final class SightMarkUIView: UIView {
    
    var status: TargetStatus {
        didSet {
            refresh()
        }
    }
    
    private let markViews: [MarkArc]
        
    init(status: TargetStatus) {
        
        self.markViews = MarkArc.makeArcs(status: status)
        self.status = status
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
        markViews.forEach({ addSubview($0) })
        
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        markViews.forEach({ $0.setNeedsDisplay() })
    }
    
    private func refresh() {
        markViews.forEach { $0.update(status) }
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
