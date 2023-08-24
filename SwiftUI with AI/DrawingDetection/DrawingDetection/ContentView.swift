//
//  ContentView.swift
//  DrawingDetection
//
//  Created by mystic on 2022/10/09.
//

import SwiftUI

struct ContentView: View {
    @State private var imagePickerOpen = false
    @State private var cameraOpen = false
    @State private var image: UIImage?
    @State private var classification: String?
    
    private let placeholderImage = UIImage(systemName: "photo")!
    private let classifier = DrawingClassifierModel()
    private var cameraEnabled: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }
    private var classificationEnabled: Bool { image != nil && classification == nil }
    
    var body: some View {
        mainView()
            .sheet(isPresented: $imagePickerOpen) {
                imagePickerView
            }
            .sheet(isPresented: $cameraOpen) {
                cameraView
            }
    }
    
    private func classify() {
        classifier.classify(self.image) { result in
            self.classification = result?.icon
        }
    }
    
    private func controlReturned(image: UIImage?) {
        self.image = classifier.configure(image: image)
    }
    
    private func ImagePickerOn() {
        imagePickerOpen = true
    }
    
    private func CameraOn() {
        cameraOpen = true
    }
}

extension ContentView {
    func mainView() -> some View {
        NavigationView {
            MainView(image: image ?? placeholderImage, text: "\(classification ?? "Nothing")") {
                TwoStateButton(text: "Classify", disabled: !classificationEnabled, action: classify)
            }
            .padding()
            .navigationTitle(Text("DrawingDetection"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        ImagePickerOn()
                    } label: {
                        Image(systemName: "photo")
                    }
                }
                ToolbarItem {
                    Button {
                        CameraOn()
                    } label: {
                        Image(systemName: "camera")
                    }.disabled(!cameraEnabled)
                }
            }
        }
    }
    
    var imagePickerView: some View {
        ImagePicker { result in
            self.classification = nil
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        }
    }
    var cameraView: some View {
        ImagePicker(camera: true) { result in
            self.classification = nil
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        }
    }
}
