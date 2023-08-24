//
//  Views.swift
//  FaceDetector
//
//  Created by mystic on 2022/10/05.
//

import SwiftUI

struct TwoStateButton: View {
    private let text: String
    private let disabled: Bool
    private let background: Color
    private let action: () -> Void
    
    init(text: String, disabled: Bool, background: Color = .orange, action: @escaping () -> Void) {
        self.text = text
        self.disabled = disabled
        self.background = disabled ? .gray : background
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                Text(text).font(.title).bold().foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(background)
            .cornerRadius(10)
        }.disabled(disabled)

    }
}

struct MainView: View {
    private let image: UIImage
    private let text: String
    private let button: TwoStateButton
    
    init(image: UIImage, text: String, button: () -> TwoStateButton) {
        self.image = image
        self.text = text
        self.button = button()
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            Text(text).font(.title).bold()
            Spacer()
            button
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    private(set) var selectedImage: UIImage?
    private(set) var cameraSource: Bool
    private let completion: (UIImage?) -> ()
    
    init(camera: Bool = false, completion: @escaping (UIImage?) -> ()) {
        self.cameraSource = camera
        self.completion = completion
    }
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        let coordinator = Coordinator(self)
        coordinator.completion = self.completion
        return coordinator
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType = cameraSource ? .camera : .photoLibrary
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        var completion: ((UIImage?) -> ())?
        
        init(_ imagePickerControllerWrapper: ImagePicker) {
            self.parent = imagePickerControllerWrapper
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
    
    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
        }
    }
}
