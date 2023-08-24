//
//  VideoCapture.swift
//  ObjectRecognition
//
//  Created by mystic on 2022/10/29.
//

import UIKit
import AVFoundation

public protocol VideoCaptureDelegate: AnyObject {
    func onFrameCaptured(videoCapture: VideoCapture, pixelBuffer: CVPixelBuffer?, timestamp: CMTime)
}

public class VideoCapture: NSObject {
    public weak var delegate: VideoCaptureDelegate?
    public var fps = 15
    var lastTimestamp = CMTime()
    let captureSession = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue")
    
    override init() {
        super.init()
    }
    
    func initCamera() -> Bool {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return false }
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else { return false }
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        let settings: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA)]
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        captureSession.commitConfiguration()
        return true
    }
    
    public func asyncStartCapturing(completion: (() -> Void)? = nil) {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    public func asyncStopCapturing(completion: (() -> Void)? = nil) {
        if self.captureSession.isRunning {
            self.captureSession.stopRunning()
        }
        if let completion = completion {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let delegate = self.delegate else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let elapsedTime = timestamp - lastTimestamp
        if elapsedTime >= CMTimeMake(value: 1, timescale: Int32(fps)) {
            lastTimestamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            delegate.onFrameCaptured(videoCapture: self, pixelBuffer: imageBuffer, timestamp: timestamp)
        }
    }
}
