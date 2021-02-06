//
//  HowAwayAreYouApp.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2021/02/06.
//  Copyright © 2021 Crazism. All rights reserved.
//

import SwiftUI

@main
struct HowAwayAreYouApp: App {
    
    var imageProcessor: ImageProcessor<CameraIO>? = {
        guard let cameraIO = try? CameraIO() else { return nil }
        let processor = ImageProcessor(input: cameraIO)
        return processor
    }()
    
    var body: some Scene {
        WindowGroup {
            if let processor = imageProcessor {
                ProcessedImageDisplayView(imageInput: processor)
            } else {
                CameraWarningView()
            }
        }
    }
    
}

private struct CameraWarningView: View {
    
    var body: some View {
        Text("""
            😢Failed to launch camera.
            
            Please note that this app needs dual-camera or later to measure distance.
            """
        )
    }
    
}
