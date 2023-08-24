//
//  ContentView.swift
//  FaceDetection
//
//  Created by a mystic on 2023/08/24.
//

import SwiftUI
import PhotosUI
import Vision

struct ContentView: View {
    @State private var faces: [VNFaceObservation]?
    
    private var faceCount: Int { faces?.count ?? 0 }
    private let placeholderImage = UIImage(systemName: "photo")!
    private var detectionEnabled: Bool { selectedImage != nil && faces == nil }
    
    var body: some View {
        NavigationStack {
            MainView(
                image: selectedImage ?? placeholderImage,
                text: "\(faceCount) face\(faceCount == 1 ? "" : "s")",
                button: TwoStateButton(text: "Detect Faces", disabled: !detectionEnabled, action: getFaces)
            )
            .padding()
            .navigationTitle("Face Detection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { photoPicker }
            }
        }
    }
    
    private func getFaces() {
        self.faces = []
        selectedImage?.detectFaces { result in
            faces = result
            if let image = self.selectedImage, let annotatedImage = result?.drawOn(image) {
                self.selectedImage = annotatedImage
            }
        }
    }
    
    @State private var selectedImageData: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var photoPicker: some View {
        PhotosPicker(selection: $selectedImageData, matching: .images) {
            Image(systemName: "photo")
        }
        .onChange(of: selectedImageData) { imageData in
            Task {
                if let data = try? await imageData?.loadTransferable(type: Data.self) {
                    selectedImage = UIImage(data: data)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
