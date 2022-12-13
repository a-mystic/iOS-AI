//
//  ImagePicker.swift
//  FaceDetection
//
//  Created by mystic on 2022/11/06.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    private let completion: (UIImage?) -> ()
    
    init(completion: @escaping (UIImage?) -> ()) {
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self, completion: self.completion)
        return coordinator
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        var completion: ((UIImage?) -> ())?
        
        init(_ parent: ImagePicker, completion: ((UIImage?) -> Void)? = nil) {
            self.parent = parent
            self.completion = completion
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            completion?(nil)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            picker.dismiss(animated: true)
            completion?(selectedImage)
        }
    }
}
