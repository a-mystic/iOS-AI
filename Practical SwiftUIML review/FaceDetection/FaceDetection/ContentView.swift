//
//  ContentView.swift
//  FaceDetection
//
//  Created by mystic on 2022/11/06.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var image: UIImage?
    @State private var classification: String?
    @State private var imagePickerOpen = false
    @State private var faces: [VNFaceObservation]?
    
    private var faceCount: Int { return faces?.count ?? 0 }
    private var buttonText: String {
        if image != nil {
            return "Classify"
        } else {
            return "input"
        }
    }
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                Spacer()
            }
            if let classification = classification {
                Text(classification).font(.title).bold()
                Spacer()
            }
            classifyButton
        }
        .sheet(isPresented: $imagePickerOpen) {
            imagePicker
        }
    }
    
    var classifyButton: some View {
        Button {
            if image == nil {
                imagePickerOpen = true
            } else {
                getFaces()
            }
        } label: {
            Text(buttonText).font(.title).bold().foregroundColor(.white)
        }.padding().background(Color.orange).cornerRadius(14)
    }
    var imagePicker: some View {
        ImagePicker { result in
            self.image = result
        }
    }
    
    private func getFaces() {
        self.faces = []
        self.image?.detectFaces { result in
            self.faces = result
            self.classification = "\(faceCount) face\(faceCount == 1 ? "" : "s")"
            if let image = self.image, let annotatedImage = result?.drawOn(image) {
                self.image = annotatedImage
            }
        }
    }
}

