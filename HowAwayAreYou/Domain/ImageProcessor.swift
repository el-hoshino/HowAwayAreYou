//
//  ImageProcessor.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/12.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation
import Combine
import CoreImage

protocol ImageProcessorInput: AnyObject {
    var cvPixelBufferPublisher: AnyPublisher<CVPixelBuffer?, Never> { get }
}

final class ImageProcessor<Input: ImageProcessorInput>: ObservableObject {
    
    let input: Input
    private let context: CIContext = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var publishedImageData: ImageData?
    private func updatePublishedImageData(_ data: ImageData?) {
        DispatchQueue.main.async {
            self.publishedImageData = data
        }
    }
    
    init(input: Input) {
        self.input = input
        let cancellable = input.cvPixelBufferPublisher.sink { [unowned self] buffer in
            guard let buffer = buffer else {
                self.updatePublishedImageData(nil)
                return
            }
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)!
            let imageData = ImageData(cgImage: cgImage, scale: 1, orientation: .right)
            self.updatePublishedImageData(imageData)
        }
        cancellables.insert(cancellable)
    }
    
    private func makeCIImage(from buffer: CVPixelBuffer) -> CIImage {
        
        return CIImage(cvPixelBuffer: buffer)
        
    }
    
    private func findPerson(in ciImage: CIImage) -> (center: CGPoint, relativeSize: CGSize)? {
        
        
        
        return nil
        
    }
    
}

extension ImageProcessor: ProcessedImageInputObject {
    
    var imageData: ImageData? {
        publishedImageData
    }
    
    var target: Target? {
        nil
    }
    
}
