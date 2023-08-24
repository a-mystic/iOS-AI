//
//  ContentView.swift
//  ImageSimilarity
//
//  Created by mystic on 2022/10/06.
//

import SwiftUI

struct ContentView: View {
    @State private var imagePickerOpen = false
    @State private var cameraOpen = false
    @State private var firstImage: UIImage?
    @State private var seconImage: UIImage?
    @State private var similarity = -1
    
    private let placeholderImage = UIImage(systemName: "photo")!
    private var cameraEnabled: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }
    private var selectEnabled: Bool { seconImage == nil }
    private var comparisonEnabled: Bool { seconImage != nil && similarity < 0 }
    
    private func clearImages() {
        firstImage = nil
        seconImage = nil
        similarity = -1
    }
    
    private func getSimilarity() {
        if let firstImage = firstImage, let seconImage = seconImage, let similarityMeasure = firstImage.similarity(to: seconImage) {
            similarity = Int(similarityMeasure)
        } else {
            similarity = 0
        }
    }
    
    private func controlReturned(image: UIImage?) {
        if firstImage == nil {
            firstImage = image?.fixOrientation()
        } else {
            seconImage = image?.fixOrientation()
        }
    }
    
    private func ImagePickerOn() {
        imagePickerOpen = true
    }
    
    private func CameraOn() {
        cameraOpen = true
    }
    
    var body: some View {
            NavigationView {
                VStack {
                    HStack {
                        OptionalResizableImage(image: firstImage, placeholder: placeholderImage)
                        OptionalResizableImage(image: seconImage, placeholder: placeholderImage)
                    }
                    Button(action: clearImages) { Text("Clear Images") }
                    Spacer()
                    Text("Similarity: " + "\(similarity > 0 ? String(similarity) : " ...")%").font(.title).bold()
                    Spacer()
                    if comparisonEnabled {
                        Button(action: getSimilarity) {
                            ButtonLabel("Compare", background: .orange)
                        }.disabled(!comparisonEnabled)
                    } else {
                        Button(action: getSimilarity) {
                            ButtonLabel("Compare", background: .gray)
                        }.disabled(!comparisonEnabled)
                    }
                }
                .sheet(isPresented: $imagePickerOpen) {
                    ImagePickerView { result in
                        self.controlReturned(image: result)
                        self.imagePickerOpen = false
                    }
                }
                .sheet(isPresented: $cameraOpen) {
                    ImagePickerView(camera: cameraOpen) { result in
                        self.controlReturned(image: result)
                        self.cameraOpen = false
                    }
                }
                .padding()
                .navigationTitle(Text("ImageSimilarity"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            ImagePickerOn()
                        } label: {
                            Text("Select")
                        }.disabled(!selectEnabled)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            CameraOn()
                        } label: {
                            Image(systemName: "camera")
                        }.disabled(!cameraEnabled)
                    }
                }
            }
        }
    }
