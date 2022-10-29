//
//  ViewController.swift
//  ObjectRecognition
//
//  Created by mystic on 2022/10/29.
//

import UIKit
import SwiftUI
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Binding var text: String
    
    var previewView = CapturePreviewView()
    let videoCapture = VideoCapture()
    let context = CIContext()
    let model = Inceptionv3()
    
    init(text: Binding<String>) {
        self._text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setup()
        self.videoCapture.delegate = self
    }
    
    private func setup() {
        let size = UIScreen.main.bounds
        self.previewView.layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height) // plus
        if self.videoCapture.initCamera() {
            (self.previewView.layer as! AVCaptureVideoPreviewLayer).session = self.videoCapture.captureSession
            (self.previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoCapture.asyncStartCapturing()
            self.view.layer.addSublayer(previewView.layer) // plus
        } else {
            fatalError("Failed")
        }
    }
}

struct VideoCaptureView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    @Binding var text: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController(text: $text)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

class CapturePreviewView: UIView {
    override class var layerClass: AnyClass { return AVCaptureVideoPreviewLayer.self }
}

extension ViewController: VideoCaptureDelegate {
    func onFrameCaptured(videoCapture: VideoCapture, pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        guard let pixelBuffer = pixelBuffer else { return }
        guard let scaledPixelBuffer = CIImage(cvImageBuffer: pixelBuffer)
            .resize(size: CGSize(width: 299, height: 299))
            .topixelBuffer(context: context) else { return }
        let prediction = try? self.model.prediction(image: scaledPixelBuffer)
        DispatchQueue.main.async {
            self.text = prediction?.classLabel ?? "nil"
        }
    }
}
