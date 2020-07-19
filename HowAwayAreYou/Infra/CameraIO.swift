//
//  CameraIO.swift
//  HowAwayAreYou
//
//  Created by 史 翔新 on 2020/07/12.
//  Copyright © 2020 Crazism. All rights reserved.
//

import Foundation
import Combine
import AVFoundation
import CoreImage

final class CameraIO {
    
    let captureSession: AVCaptureSession
    let captureDevice: AVCaptureDevice
    
    private let captureOutputReceiver: CaptureOutputReceiver
    private let outputProcessQueue = DispatchQueue(label: "CameraIO")
    
    let outputSampleBufferPublisher: CurrentValueSubject<CMSampleBuffer?, Never> = .init(nil)
    let outputDepthDataPublisher: CurrentValueSubject<AVDepthData?, Never> = .init(nil)
    
    enum CameraIOInitError: Error {
        case failedToFindDevice
    }
    
    init() throws {
        
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera],
                                                            mediaType: .depthData,
                                                            position: .front)
        .devices.first else {
            throw CameraIOInitError.failedToFindDevice
        }
        
        let session = AVCaptureSession()
        
        session.beginConfiguration()
        
        session.sessionPreset = .photo
        
        let input = try AVCaptureDeviceInput(device: device)
        session.addInput(input)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        let depthDataOutput = AVCaptureDepthDataOutput()
        let receiver = CaptureOutputReceiver()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: videoDataOutput.availableVideoPixelFormatTypes[0]] as [String: Any]
        videoDataOutput.setSampleBufferDelegate(receiver, queue: outputProcessQueue)
        depthDataOutput.setDelegate(receiver, callbackQueue: outputProcessQueue)
        session.addOutput(videoDataOutput)
        session.addOutput(depthDataOutput)
        
        depthDataOutput.isFilteringEnabled = true
        
        let depthFormats = device.activeFormat.supportedDepthDataFormats
        let filtered = depthFormats.filter({
            CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat32
        })
        let selectedFormat = filtered.max(by: {
            first, second in CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
        })

        try device.lockForConfiguration()
        device.activeDepthDataFormat = selectedFormat
        device.unlockForConfiguration()

        session.commitConfiguration()

        self.captureSession = session
        self.captureDevice = device
        self.captureOutputReceiver = receiver
        
        receiver.delegate = self
        
        session.startRunning()
        
    }
    
}

extension CameraIO: CaptureOutputDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connections: AVCaptureConnection) {
        outputSampleBufferPublisher.send(sampleBuffer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        outputSampleBufferPublisher.send(nil)
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
        
        let point = CGPoint(x: 30, y: 30)
        CVPixelBufferLockBaseAddress(depthData.depthDataMap, CVPixelBufferLockFlags(rawValue: 0))
        let depthPointer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthData.depthDataMap), to: UnsafeMutablePointer<Float32>.self)
        let width = CVPixelBufferGetWidth(depthData.depthDataMap)
        let distanceAtXYPoint = depthPointer[Int(point.y * CGFloat(width) + point.x)]
        print(distanceAtXYPoint)
        outputDepthDataPublisher.send(depthData)
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didDrop depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection, reason: AVCaptureOutput.DataDroppedReason) {
        outputDepthDataPublisher.send(nil)
    }
    
}

private protocol CaptureOutputDelegate: AnyObject {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connections: AVCaptureConnection)
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection)
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didDrop depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection, reason: AVCaptureOutput.DataDroppedReason)
}

private final class CaptureOutputReceiver: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureDepthDataOutputDelegate {
    
    weak var delegate: CaptureOutputDelegate?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(output, didOutput: sampleBuffer, from: connection)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(output, didDrop: sampleBuffer, from: connection)
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {
        delegate?.depthDataOutput(output, didOutput: depthData, timestamp: timestamp, connection: connection)
    }
    
    func depthDataOutput(_ output: AVCaptureDepthDataOutput, didDrop depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection, reason: AVCaptureOutput.DataDroppedReason) {
        delegate?.depthDataOutput(output, didDrop: depthData, timestamp: timestamp, connection: connection, reason: reason)
    }
    
}

extension CameraIO: ImageProcessorInput {
    
    var cvPixelBufferPublisher: AnyPublisher<CVPixelBuffer?, Never> {
        return outputDepthDataPublisher.map {
            guard let depthData = $0 else { return nil }
            return depthData.depthDataMap
        }.eraseToAnyPublisher()
    }
    
}
