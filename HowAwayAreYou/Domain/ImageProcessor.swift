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
    var running: Bool { get set }
    // For some reason (I guess it's something related to the frame rate) if you don't ask the CameraIO for metadata objects like faces,
    // CMSampleBufferGetImageBuffer will fail to get the image buffer from the output of AVCaptureDataOutputSynchronizer.
    // It's really weird that even I collect the metadata objects in CameraIO and just ignore it on publisher map, the problem still occurs.
    typealias Data = (sampleVideoPixelBuffer: CVPixelBuffer, depthDataPixelBuffer: CVPixelBuffer, facesRelativeBounds: [CGRect])
    var dataPublisher: AnyPublisher<Data?, Never> { get }
}

final class ImageProcessor<Input: ImageProcessorInput>: ObservableObject {
    
    let input: Input
    private let context: CIContext
    private var cancellables: Set<AnyCancellable> = []
    
    private typealias Data = (imageData: ImageData, targetInfo: TargetInfo?)
    @Published private var data: Data?
    
    init(input: Input) {
        
        let context = CIContext()
        self.context = context
        self.input = input
        
        observePixelBuffer()
        
    }
    
    private func observePixelBuffer() {
        
        input.dataPublisher
            .map({ [unowned self] in self.makePublishingData(from: $0) })
            .receive(on: RunLoop.main)
            .assign(to: \.data, on: self)
            .store(in: &cancellables)
                
    }
    
    private func findImageData(from inputData: ImageProcessorInput.Data, imageOrientation: ImageData.Orientation) -> ImageData {
        
        let sampleBuffer = inputData.sampleVideoPixelBuffer
        
        let ciImage = self.makeCIImage(from: sampleBuffer)
        let cgImage = self.context.createCGImage(ciImage, from: ciImage.extent)!
        let imageData = ImageData(cgImage: cgImage, scale: 1, orientation: imageOrientation)
        
        return imageData
        
    }
    
    private func findTargetInfo(from inputData: ImageProcessorInput.Data, imageOrientation: ImageData.Orientation) -> TargetInfo? {
        
        let sortedFacesRelativeBounds = inputData.facesRelativeBounds.sorted(by: \.center.squaredDistanceToRelativeCenter, <)
        guard let targetFaceRelativeBounds = sortedFacesRelativeBounds.first else {
            return nil
        }
        
        let depthBuffer = inputData.depthDataPixelBuffer
        let distance = self.findDistance(for: targetFaceRelativeBounds, from: depthBuffer)
        let targetInfo = TargetInfo(relativePosition: targetFaceRelativeBounds.center,
                                    relativeSize: targetFaceRelativeBounds.size,
                                    orientation: imageOrientation,
                                    distance: distance)
        
        return targetInfo
        
    }
    
    private func makePublishingData(from inputData: ImageProcessorInput.Data?) -> Data? {
        
        guard let inputData = inputData else {
            return nil
        }
        
        let imageOrientation = ImageData.Orientation.right
        let imageData = findImageData(from: inputData, imageOrientation: imageOrientation)
        let targetInfo = findTargetInfo(from: inputData, imageOrientation: imageOrientation)
        
        return (imageData, targetInfo)
        
    }
    
    private func makeCIImage(from buffer: CVPixelBuffer) -> CIImage {
        
        return CIImage(cvPixelBuffer: buffer)
        
    }
        
    private func findDistance(for relativeBounds: CGRect, from depthDataMap: CVPixelBuffer) -> Float {
        
        return depthDataMap.value(atRelativePoint: relativeBounds.center)
        
    }
    
}

extension ImageProcessor: ProcessedImageInputObject {
    
    var running: Bool {
        get { input.running }
        set { input.running = newValue }
    }
    
    var imageData: ImageData? {
        data?.imageData
    }
    
    var targetInfo: TargetInfo? {
        data?.targetInfo
    }
    
}

private extension CGPoint {
    
    static func / (lhs: CGPoint, rhs: CGSize) -> CGPoint {
        .init(x: lhs.x / rhs.width, y: lhs.y / rhs.height)
    }
    
    static var relativeCenter: CGPoint {
        .init(x: 0.5, y: 0.5)
    }
    
    func squaredDistance(to anotherPoint: CGPoint) -> CGFloat {
        (x - anotherPoint.x).squared() + (y - anotherPoint.y).squared()
    }
    
    var squaredDistanceToRelativeCenter: CGFloat {
        squaredDistance(to: .relativeCenter)
    }
    
}

private extension CGSize {
    
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        .init(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
    
}

private extension CGFloat {
    
    func squared() -> CGFloat {
        self * self
    }
    
}
