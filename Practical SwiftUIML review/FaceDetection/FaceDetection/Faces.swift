//
//  Faces.swift
//  FaceDetection
//
//  Created by mystic on 2022/11/06.
//

import UIKit
import Vision

extension UIImage {
    func detectFaces(completion: @escaping ([VNFaceObservation]?) -> ()) {
        guard let image = self.cgImage else { return completion(nil) }
        let request = VNDetectFaceLandmarksRequest()
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(
                cgImage: image,
                orientation: self.cgImageOrientation
            )
            try? handler.perform([request])
            guard let observation = request.results else { return completion(nil) }
            completion(observation)
        }
    }
    
    func rotateBy(degrees: CGFloat, clockwise: Bool = false) -> UIImage? {
        var radians = (degrees) * (.pi / 180)
        if !clockwise { radians = -radians }
        let transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        let newSize = CGRect(origin: .zero, size: self.size).applying(transform).size
        let roundedSize = CGSize(width: floor(newSize.width), height: floor(newSize.height))
        let centredRect = CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(roundedSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: roundedSize.width / 2, y: roundedSize.height / 2)
        context.rotate(by: radians)
        self.draw(in: centredRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension Collection where Element == VNFaceObservation {
    func drawOn(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
        guard let _ = UIGraphicsGetCurrentContext() else { return nil }
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let imageSize: (width: Int, height: Int) = (Int(image.size.width), Int(image.size.height))
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
        let padding: CGFloat = 0.3
        for observation in self {
            guard let anchor = observation.landmarks?.anchorPointInImage(image) else { continue }
            guard let center = anchor.center?.applying(transform) else { continue }
            let overlayRect = VNImageRectForNormalizedRect(observation.boundingBox, imageSize.width, imageSize.height).applying(transform).centerdOn(center)
            let insets = (x: overlayRect.size.width * padding, y: overlayRect.size.height * padding)
            let paddedOverlayRect = overlayRect.insetBy(dx: -insets.x, dy: -insets.y)
            if var overlayImage = "👻".image(of: paddedOverlayRect.size) {
                if let angle = anchor.angle, let rotatedImage = overlayImage.rotateBy(degrees: angle) {
                    overlayImage = rotatedImage
                }
                overlayImage.draw(in: paddedOverlayRect)
            }
        }
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension VNFaceLandmarks2D {
    func anchorPointInImage(_ image: UIImage) -> (center: CGPoint?, angle: CGFloat?) {
        let size = image.size
        let allpoints = self.allPoints?.pointsInImage(imageSize: size).centerPoint
        let leftPupil = self.leftPupil?.pointsInImage(imageSize: size).centerPoint
        let leftEye = self.leftEye?.pointsInImage(imageSize: size).centerPoint
        let leftEyebrow = self.leftEyebrow?.pointsInImage(imageSize: size).centerPoint
        let rightPupil = self.rightPupil?.pointsInImage(imageSize: size).centerPoint
        let rightEye = self.rightEye?.pointsInImage(imageSize: size).centerPoint
        let rightEyebrow = self.rightEyebrow?.pointsInImage(imageSize: size).centerPoint
        let outerLips = self.outerLips?.pointsInImage(imageSize: size).centerPoint
        let innerLips = self.innerLips?.pointsInImage(imageSize: size).centerPoint
        let leftEyeCenter = leftPupil ?? leftEye ?? leftEyebrow
        let rightEyeCenter = rightPupil ?? rightEye ?? rightEyebrow
        let mouthCenter = innerLips ?? outerLips
        
        if let leftEyePoint = leftEyeCenter, let rightEyePoint = rightEyeCenter, let mouthPoint = mouthCenter {
            let triadCenter = [leftEyePoint, rightEyePoint, mouthPoint].centerPoint
            let eyesCenter = [leftEyePoint, rightEyePoint].centerPoint
            return (eyesCenter, triadCenter.rotationDegreesTo(eyesCenter))
        }
        return (allpoints, 0.0)
    }
}

extension CGRect {
    func centerdOn(_ point: CGPoint) -> CGRect {
        let size = self.size
        let originX = point.x - (self.width / 2.0)
        let originY = point.y - (self.height / 2.0)
        return CGRect(x: originX, y: originY, width: size.width, height: size.height)
    }
}

extension CGPoint {
    func rotationDegreesTo(_ otherPoint: CGPoint) -> CGFloat {
        let originX = otherPoint.x - self.x
        let originY = otherPoint.y - self.y
        let degreesFromX = atan2f(Float(originY), Float(originX)) * (180 / .pi)
        let degreesFromY = degreesFromX - 90.0
        let normalizeDegrees = (degreesFromY + 360.0).truncatingRemainder(dividingBy: 360.0)
        return CGFloat(normalizeDegrees)
    }
}

extension Array where Element == CGPoint {
    var centerPoint: CGPoint {
        let elements = CGFloat(self.count)
        let totalX = self.reduce(0, { $0 + $1.x })
        let totalY = self.reduce(0, { $0 + $1.y })
        return CGPoint(x: totalX/elements, y: totalY/elements)
    }
}

extension String {
    func image(of size: CGSize, scale: CGFloat = 0.94) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: size.height*scale)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
