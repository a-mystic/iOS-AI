//
//  ContentView.swift
//  FaceDetector
//
//  Created by mystic on 2022/10/05.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var imagePickerOpen: Bool = false
    @State private var cameraOpen: Bool = false
    @State private var image: UIImage? = nil
    @State private var faces: [VNFaceObservation]?
    
    private var faceCount: Int { return faces?.count ?? 0 }
    private let placeholderImage = UIImage(systemName: "photo.fill")!
    private var cameraEnabled: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }
    private var detectionEnabled: Bool { image != nil && faces == nil }
    
    var body: some View {
        mainView()
            .sheet(isPresented: $imagePickerOpen) {
                imagePickerView()
            }
            .sheet(isPresented: $cameraOpen) {
                CameraView()
            }
    }
    
    private func getFaces() {
        self.faces = []
        self.image?.detectFaces { result in
            self.faces = result
            if let image = self.image, let annotatedImage = result?.drawOn(image) {
                self.image = annotatedImage
            }
        }
    }
    
    private func controlReturned(image: UIImage?) {
        self.image = image?.fixOrientation()
        self.faces = nil
    }
    
    private func summonImagePicker() {
        imagePickerOpen = true
    }
    
    private func summonCamera() {
        cameraOpen = true
    }
    
    private func mainView() -> some View {
        var leadingNavigationItem: some View {
            Button(action: summonImagePicker) {
                Image(systemName: "photo.circle")
            }
        }
        var trailingNavigationItem: some View {
            Button(action: summonCamera) {
                Image(systemName: "camera")
            }
        }
        return NavigationView {
            MainView(
                image: image ?? placeholderImage,
                text: "\(faceCount) face\(faceCount == 1 ? "" : "s")"
            ) {
                TwoStateButton(text: "Detect Faces", disabled: !detectionEnabled, action: getFaces)
            }
            .padding()
            .navigationBarTitle(Text("FD"), displayMode: .inline)
            .navigationBarItems(leading: leadingNavigationItem, trailing: trailingNavigationItem)
        }.disabled(!cameraEnabled)
    }
    
    private func imagePickerView() -> some View {
        ImagePicker { result in
            self.controlReturned(image: result)
            self.cameraOpen = false
        }
    }
    private func CameraView() -> some View {
        ImagePicker(camera: true) { result in
            self.controlReturned(image: result)
            self.cameraOpen = false
        }
    }
}
