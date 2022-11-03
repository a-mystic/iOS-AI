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
    
    let previewView = CapturePreviewView()
    let videoCapture = VideoCapture()
    let viewVisualizer = EmotionVisualizerView()
    let imageProcessor = ImageProcessor()
    let model = ExpressionRecognitionModelRaw()
    
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
        self.viewVisualizer.frame = CGRect(x: 0, y: size.height/2, width: size.width, height: size.height/2) // plus
        self.viewVisualizer.backgroundColor = .clear // plus
        videoCapture.asyncInit { success in
            if success {
                (self.previewView.layer as! AVCaptureVideoPreviewLayer).session = self.videoCapture.captureSession
                (self.previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.videoCapture.startCapturing()
                self.view.layer.addSublayer(self.previewView.layer) // plus
                self.view.addSubview(self.viewVisualizer) // plus
            } else {
                fatalError("failed to init VideoCapture")
            }
        }
        imageProcessor.delegate = self
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
        self.imageProcessor.getFaces(pixelBuffer: pixelBuffer)
    }
}

extension ViewController: ImageProcessorDelegate {
    func onImageProcessorCompleted(status: Int, faces: [MLMultiArray]?) {
        guard let faces = faces else { return }
        guard faces.count > 0 else { return }
        DispatchQueue.global(qos: .background).async {
            for faceData in faces {
                let prediction = try? self.model.prediction(image: faceData)
                if let classPredictions = prediction?.classLabelProbs {
                    DispatchQueue.main.async {
                        self.viewVisualizer.update(labelConference: classPredictions)
                    }
                }
            }
        }
    }
}
