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

final class CameraIO {
    
    let captureSession: AVCaptureSession
    let captureDevice: AVCaptureDevice
    
    private let videoDataOutput: AVCaptureVideoDataOutput
    private let depthDataOutput: AVCaptureDepthDataOutput
    private let faceOutput: AVCaptureMetadataOutput
    private let captureOutputReceiver: CaptureOutputReceiver
    private let synchronizer: AVCaptureDataOutputSynchronizer
    private let outputProcessQueue = DispatchQueue(label: "CameraIO")
    
    typealias SynchronizedData = (sampleBuffer: CMSampleBuffer, depthData: AVDepthData, facesBounds: [CGRect])
    let synchronizedDataPublisher: CurrentValueSubject<SynchronizedData?, Never> = .init(nil)
    
    enum CameraIOInitError: Error {
        case failedToFindDevice
    }
    
    init() throws {
        
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTripleCamera],
                                                            mediaType: .depthData,
                                                            position: .back)
        .devices.first else {
            throw CameraIOInitError.failedToFindDevice
        }
        
        let session = AVCaptureSession()
        
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        
        session.sessionPreset = .photo
        
        let input = try AVCaptureDeviceInput(device: device)
        session.addInput(input)
        
        let receiver = CaptureOutputReceiver()
                
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: videoDataOutput.availableVideoPixelFormatTypes[0]] as [String: Any]
        session.addOutput(videoDataOutput)
        
        let depthDataOutput = AVCaptureDepthDataOutput()
        depthDataOutput.isFilteringEnabled = true
        session.addOutput(depthDataOutput)
        
        let faceOutput = AVCaptureMetadataOutput()
        session.addOutput(faceOutput)
        faceOutput.metadataObjectTypes = [.face]
        
        let synchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [videoDataOutput, depthDataOutput, faceOutput])
        synchronizer.setDelegate(receiver, queue: outputProcessQueue)
        
        try device.setupBestActiveDepthFormat()
                
        self.videoDataOutput = videoDataOutput
        self.depthDataOutput = depthDataOutput
        self.faceOutput = faceOutput
        self.captureSession = session
        self.captureDevice = device
        self.captureOutputReceiver = receiver
        self.synchronizer = synchronizer
        
        receiver.delegate = self
                
    }
    
}

extension CameraIO: CaptureOutputDelegate {
    
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        
        guard let sampleBuffer = synchronizedDataCollection.synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData else { return }
        guard let depthData = synchronizedDataCollection.synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData else { return }
        let faces = synchronizedDataCollection.synchronizedData(for: faceOutput) as! AVCaptureSynchronizedMetadataObjectData?
        
        self.synchronizedDataPublisher.send((sampleBuffer.sampleBuffer, depthData.depthData, faces?.metadataObjects.map { $0.bounds } ?? []))
        
    }
    
}

private protocol CaptureOutputDelegate: AnyObject {
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection)
}

private final class CaptureOutputReceiver: NSObject, AVCaptureDataOutputSynchronizerDelegate {
    
    weak var delegate: CaptureOutputDelegate?
    
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        delegate?.dataOutputSynchronizer(synchronizer, didOutput: synchronizedDataCollection)
    }
    
}

extension CameraIO: ImageProcessorInput {
    
    var running: Bool {
        get {
            captureSession.isRunning
        }
        set {
            if newValue {
                captureSession.startRunning()
            } else {
                captureSession.stopRunning()
            }
        }
    }
    
    var dataPublisher: AnyPublisher<ImageProcessorInput.Data?, Never> {
        synchronizedDataPublisher.map {
            guard let data = $0 else { return nil }
            let sampleBuffer = CMSampleBufferGetImageBuffer(data.sampleBuffer)!
            let depthData = data.depthData.depthDataMap
            let facesBounds = data.facesBounds
            return (sampleBuffer, depthData, facesBounds)
        }.eraseToAnyPublisher()
    }
    
}

private extension AVCaptureDevice {
    
    func setupBestActiveDepthFormat() throws {
        
        let depthFormats = activeFormat.supportedDepthDataFormats
        let filtered = depthFormats.filter({
            CMFormatDescriptionGetMediaSubType($0.formatDescription) == kCVPixelFormatType_DepthFloat32
        })
        let selectedFormat = filtered.max(by: {
            first, second in CMVideoFormatDescriptionGetDimensions(first.formatDescription).width < CMVideoFormatDescriptionGetDimensions(second.formatDescription).width
        })
        
        try lockForConfiguration()
        defer { unlockForConfiguration() }
        
        activeDepthDataFormat = selectedFormat
        
    }
    
}
