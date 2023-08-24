//
//  ImagePickerView.swift
//  ImageClassification
//
//  Created by mystic on 2022/10/06.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    private(set) var selectedImage: UIImage?
    private let completion: (UIImage?) -> ()
    
    init(completion: @escaping (UIImage?) -> ()) {
        self.completion = completion
    }
    
    func makeCoordinator() -> ImagePickerView.Coordinator {
        let coordinator = Coordinator(self)
        coordinator.completion = self.completion
        return coordinator
    }
    
    func makeUIViewController(context: Context) ->
    UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType = .photoLibrary
        return imagePickerController
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController, context: Context) {
            //uiViewController.setViewControllers(?, animated: true)
        }
    
    class Coordinator: NSObject,
                       UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView
        var completion: ((UIImage?) -> ())?
        
        init(_ imagePickerControllerWrapper:
             ImagePickerView) {
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
