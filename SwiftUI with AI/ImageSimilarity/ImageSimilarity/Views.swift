//
//  Views.swift
//  ImageSimilarity
//
//  Created by mystic on 2022/10/06.
//

import SwiftUI

struct OptionalResizableImage: View {
    let image: UIImage?
    let placeholder: UIImage
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(uiImage: placeholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct ButtonLabel: View {
    private let text: String
    private let background: Color
    
    init(_ text: String, background: Color) {
        self.text = text
        self.background = background
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(text).font(.title).bold().foregroundColor(.white)
            Spacer()
        }.padding().background(background).cornerRadius(20)
    }
}

struct ImagePickerView: View {
    private let completion: (UIImage?) -> ()
    private let camera: Bool
    
    init(camera: Bool = false, completion: @escaping (UIImage?) -> ()) {
        self.completion = completion
        self.camera = camera
    }
    
    var body: some View {
        ImagePickerControllerWrapper(camera: camera, completion: completion)
    }
}

struct ImagePickerControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    private(set) var selectedImage: UIImage?
    private(set) var cameraSource: Bool
    private let completion: (UIImage?) -> ()
    
    init(camera: Bool, completion: @escaping (UIImage?) -> ()) {
        self.cameraSource = camera
        self.completion = completion
    }
    
    func makeCoordinator() -> ImagePickerControllerWrapper.Coordinator {
        let coordinator = Coordinator(self)
        coordinator.completion = self.completion
        return coordinator
    }
    
    func makeUIViewController(context: Context) ->
    UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType =
        cameraSource ? .camera : .photoLibrary
        return imagePickerController
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController, context: Context) {
            //uiViewController.setViewControllers(?, animated: true)
        }
    
    class Coordinator: NSObject,
                       UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerControllerWrapper
        var completion: ((UIImage?) -> ())?
        
        init(_ imagePickerControllerWrapper:
             ImagePickerControllerWrapper) {
            self.parent = imagePickerControllerWrapper
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info:
                                   [UIImagePickerController.InfoKey: Any]) {
            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            picker.dismiss(animated: true)
            completion?(selectedImage)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            completion?(nil)
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
