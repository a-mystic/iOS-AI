import UIKit

public extension CGSize {
    func scaleFactor(to size: CGSize) -> CGFloat {
        let horizontalScale = self.width / size.width
        let verticalScale = self.height / size.height
        return max(horizontalScale, verticalScale)
    }
}

public extension CGRect {
    func scaled(by scaleFactor: CGFloat) -> CGRect {
        let horizontalInsets = (self.width - (self.width * scaleFactor)) / 2.0
        let verticalInsets = (self.height - (self.height * scaleFactor)) / 2.0
        let edgeInsets = UIEdgeInsets(
            top: verticalInsets,
            left: horizontalInsets,
            bottom: verticalInsets,
            right: horizontalInsets
        )
        let leftOffset = min(self.origin.x + horizontalInsets, 0)
        let upOffset = min(self.origin.y + verticalInsets, 0)
        return self
            .inset(by: edgeInsets)
            .offsetBy(dx: -leftOffset, dy: -upOffset)
    }
    
    func cropped(to size: CGSize, centering: Bool = true) -> CGRect {
        if centering {
            let horizontalDifference = self.width - size.width
            let verticalDifference = self.height - size.height
            let newOrigin = CGPoint(
                x: self.origin.x + (horizontalDifference / 2.0),
                y: self.origin.y + (verticalDifference / 2.0)
            )
            return CGRect(x: newOrigin.x, y: newOrigin.y, width: size.width, height: size.height)
        }
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}

public extension UIImage {
    var width: CGFloat { self.size.width }
    var height: CGFloat { self.size.height }
    var rect: CGRect { CGRect(x: 0, y: 0, width: self.width, height: self.height) }
    var invertTransform: CGAffineTransform { CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.height) }
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
    
    func cropped(to size: CGSize, centering: Bool = true) -> UIImage? {
        let newRect = self.rect.cropped(to: size, centering: centering)
        return self.cropped(to: newRect, centering: centering)
    }
    
    func cropped(to rect: CGRect, centering: Bool = true) -> UIImage? {
        let newRect = rect.applying(self.invertTransform)
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        guard let cgImage = self.cgImage, let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 0.0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: -newRect.origin.x, y: newRect.origin.y, width: self.width, height: self.height), byTiling: false)
        context.clip(to: [newRect])
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    func scaled(by scaleFactor: CGFloat) -> UIImage? {
        if scaleFactor.isZero { return self }
        let newRect = self.rect.scaled(by: scaleFactor).applying(self.invertTransform)
        UIGraphicsBeginImageContextWithOptions(newRect.size, false, 0)
        guard let cgImage = self.cgImage, let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 0.0, y: newRect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newRect.width, height: newRect.height), byTiling: false)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
}
