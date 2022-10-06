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
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                } else {
                    blankImage.font(.largeTitle)
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
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
