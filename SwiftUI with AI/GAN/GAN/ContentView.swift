//
//  ContentView.swift
//  GAN
//
//  Created by mystic on 2022/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var images: [UIImage] = []
    private var ganModels: [ImageGenerator] = [
        MnistGan(modelName: "MnistGan"),
        MnistGan(modelName: "MnistGan1"),
        MnistGan(modelName: "MnistGan2"),
        MnistGan(modelName: "MnistGan3"),
        MnistGan(modelName: "MnistGan4"),
        MnistGan(modelName: "MnistGan5"),
        MnistGan(modelName: "MnistGan6"),
        MnistGan(modelName: "MnistGan7"),
        MnistGan(modelName: "MnistGan8"),
        MnistGan(modelName: "MnistGan9"),
        ]
    
    var body: some View {
        VStack {
            imageGridView
            Spacer()
            generateButton
        }
    }
    
    var imageGridView: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(images.indices) { index in
                Image(uiImage: images[index])
            }
        }
    }
    var generateButton: some View {
        Button {
            generateNewImages()
        } label: {
            Text("Generate").foregroundColor(.black).background(Color.white)
        }
    }
    
    private func generateNewImages() {
        for index in 0..<10 {
            let ganModel = ganModels[index]
            DispatchQueue.main.async {
                let generatedImage = ganModel.prediction()
                self.images.append(generatedImage!)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
