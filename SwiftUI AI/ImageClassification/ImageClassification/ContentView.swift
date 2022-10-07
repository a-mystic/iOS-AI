//
//  ContentView.swift
//  ImageClassification
//
//  Created by mystic on 2022/10/06.
//

import SwiftUI

struct ContentView: View {
    @State private var imagePickerOn = false
    @State private var selectedImage: UIImage?
    @State private var ClassifyResult: String?
    
    private let blankImage = Image(systemName: "photo")
    private var ClassifyEnable: Bool { selectedImage != nil }
    private var classifier = VisionClassifier(mlmodel: BananaOrApple().model)

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if selectedImage != nil {
                    Image(uiImage: selectedImage!).resizable().aspectRatio(contentMode: .fit)
                } else {
                    blankImage.font(.largeTitle).aspectRatio(contentMode: .fit)
                }
                Spacer()
                Text(ClassifyResult ?? "please input image")
                Spacer()
                Button {
                    ImageClassify()
                } label: {
                    Text("Classify").padding(.horizontal,50).font(.title).foregroundColor(.black).background(.white).cornerRadius(20)
                }.disabled(!ClassifyEnable)
                Spacer()
            }
            .sheet(isPresented: $imagePickerOn) {
                ImagePickerView { image in
                    if let image = image {
                        selectedImage = image
                    }
                }
            }
            .padding()
            .navigationTitle(Text("ImageClassification"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        imagePickerOn = true
                    } label: {
                        Image(systemName: "photo")
                    }
                }
            }
        }
    }
    
    private func ImageClassify() {
        if let classifier = self.classifier, let image = selectedImage {
            classifier.classify(image) { str in
                ClassifyResult = str
            }
        }
    }
}
