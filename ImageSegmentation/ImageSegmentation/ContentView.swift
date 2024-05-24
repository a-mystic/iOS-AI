//
//  ContentView.swift
//  ImageSegmentation
//
//  Created by a mystic on 5/24/24.
//

import SwiftUI
import PhotosUI
import CoreML
import Vision

struct ContentView: View {
    @State private var selectedImageItem: PhotosPickerItem?

    var body: some View {
        VStack {
            selectedImageView
            segmentedImageView
            PhotosPicker(selection: $selectedImageItem, matching: .images) {
                Text("Select Image")
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
            }
            .onChange(of: selectedImageItem) { _ in
                Task {
                    if let data = try? await selectedImageItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        segmentImage(uiImage)
                    }
                }
            }
        }
    }
    
    @State private var selectedImage: UIImage?

    @ViewBuilder
    private var selectedImageView: some View {
        if let image = selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .padding()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 6).foregroundStyle(.gray)
                Text("No Image Selected")
            }
            .padding()
        }
    }
    
    @State private var segmentedImage: UIImage?
    
    @ViewBuilder
    private var segmentedImageView: some View {
        if let image = segmentedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 6).foregroundStyle(.gray)
                Text("No Image Segmented")
            }
            .padding()
        }
    }
    
    private func segmentImage(_ image: UIImage?) {
        guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model) else { return }
        let request = VNCoreMLRequest(model: model, completionHandler: visionRequestDidComplete)
                request.imageCropAndScaleOption = .scaleFill
                DispatchQueue.global().async {
                    if let cgimage = selectedImage?.cgImage {
                        let handler = VNImageRequestHandler(cgImage: cgimage, options: [:])
                        do {
                            try handler.perform([request])
                        } catch {
                            print(error)
                        }
                    }
                }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
                DispatchQueue.main.async {
                    if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                        let segmentationmap = observations.first?.featureValue.multiArrayValue {
                        let segmentationMask = segmentationmap.image(min: 0, max: 1)
                        self.segmentedImage = segmentationMask!.resizedImage(for: self.selectedImage!.size)!
                    }
                }
        }
}

extension UIImage {
    func resizedImage(for size: CGSize) -> UIImage? {
                let image = self.cgImage
                let context = CGContext(data: nil,
                                        width: Int(size.width),
                                        height: Int(size.height),
                                        bitsPerComponent: image!.bitsPerComponent,
                                        bytesPerRow: Int(size.width),
                                        space: image?.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                        bitmapInfo: image!.bitmapInfo.rawValue)
                context?.interpolationQuality = .high
                context?.draw(image!, in: CGRect(origin: .zero, size: size))

                guard let scaledImage = context?.makeImage() else { return nil }

                return UIImage(cgImage: scaledImage)
        }
}

#Preview {
    ContentView()
}
