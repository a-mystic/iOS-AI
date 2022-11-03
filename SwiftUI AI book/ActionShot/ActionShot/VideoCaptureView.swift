//
//  VideoCaptureView.swift
//  ActionShot
//
//  Created by mystic on 2022/11/03.
//

import SwiftUI

struct VideoCaptureView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
    
    typealias UIViewControllerType = CameraViewController
    
    
}
