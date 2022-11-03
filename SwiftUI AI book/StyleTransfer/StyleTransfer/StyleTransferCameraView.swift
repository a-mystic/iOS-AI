//
//  StyleTransferCameraView.swift
//  StyleTransfer
//
//  Created by mystic on 2022/11/02.
//

import SwiftUI

struct StyleTransferCameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}
