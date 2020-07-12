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

final class CameraIO: ObservableObject {
    
    let captureSession: AVCaptureSession
    let captureDevice: AVCaptureDevice
    
    private let captureOutputReceiver: CaptureOutputReceiver
    
    @Published var outputSampleBuffer: CMSampleBuffer?
    
    enum CameraIOInitError: Error {
        case failedToFindDevice
    }
    
    init() throws {
        
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .back)
        .devices.first else {
            throw CameraIOInitError.failedToFindDevice
        }
        
        let session = AVCaptureSession()
        
        session.beginConfiguration()
        
        session.sessionPreset = .high
        
        let input = try AVCaptureDeviceInput(device: device)
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        let receiver = CaptureOutputReceiver()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: output.availableVideoPixelFormatTypes[0]] as [String: Any]
        output.setSampleBufferDelegate(receiver, queue: .init(label: "CameraIO"))
        session.addOutput(output)
        
        session.commitConfiguration()

        self.captureSession = session
        self.captureDevice = device
        self.captureOutputReceiver = receiver
        
        receiver.delegate = self
        
    }
    
}

extension CameraIO: CaptureOutputDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connections: AVCaptureConnection) {
        outputSampleBuffer = sampleBuffer
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
}

private protocol CaptureOutputDelegate: AnyObject {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connections: AVCaptureConnection)
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
}

private final class CaptureOutputReceiver: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var delegate: CaptureOutputDelegate?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(output, didOutput: sampleBuffer, from: connection)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.captureOutput(output, didDrop: sampleBuffer, from: connection)
    }
    
}
