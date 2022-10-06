import UIKit
import Vision

extension VNImageRequestHandler {
    convenience init?(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else { return nil }
        let orientation = uiImage.cgImageOrientation
        self.init(cgImage: cgImage, orientation: orientation)
    }
}

extension VNRequest {
    func queueFor(image: UIImage, completion: @escaping ([Any]?) -> ()) {
        DispatchQueue.global().async {
            if let handler = VNImageRequestHandler(uiImage: image) {
                try? handler.perform([self])
                completion(self.results)
            } else {
                return completion(nil)
            }
        }
    }
}

extension UIImage {
    func detectRectangles(
        completion: @escaping ([VNRectangleObservation]) -> ()) {
        let request = VNDetectRectanglesRequest()
        request.minimumConfidence = 0.8
        request.minimumAspectRatio = 0.3
        request.maximumObservations = 3
        request.queueFor(image: self) { result in
            completion(result as? [VNRectangleObservation] ?? [])
        }
    }

    func detectBarcodes(
        types symbologies: [VNBarcodeSymbology] = [.QR],
        completion: @escaping ([VNBarcodeObservation]) ->()) {
        let request = VNDetectBarcodesRequest()
        request.symbologies = symbologies
        request.queueFor(image: self) { result in
            completion(result as? [VNBarcodeObservation] ?? [])
        }
    }
    // can also detect human figures, animals, the horizon, all sorts of
    // things with inbuilt Vision functions
}

let barcodeTestImage = UIImage(named: "barcode")!

barcodeTestImage.detectBarcodes { barcodes in
    for barcode in barcodes {
        print("Barcode data: \(barcode.payloadStringValue ?? "None")")
    }
}

extension UIImage {
    enum SaliencyType {
        case objectnessBased, attenionBased
        
        var request: VNRequest {
            switch self {
            case .objectnessBased:
                return VNGenerateObjectnessBasedSaliencyImageRequest()
            case .attenionBased:
                return VNGenerateAttentionBasedSaliencyImageRequest()
            }
        }
    }
    
    func detectSalientRegions(prioritising saliencyType: SaliencyType = .attenionBased, completion: @escaping (VNSaliencyImageObservation?) -> ()) {
        let request = saliencyType.request
        request.queueFor(image: self) { results in
            completion(results?.first as? VNSaliencyImageObservation)
        }
    }
    
    func cropped(with saliencyObservation: VNSaliencyImageObservation?, to size: CGSize?) -> UIImage? {
        guard let saliencyMap = saliencyObservation, let salientObjects = saliencyMap.salientObjects else { return nil }
        let salientRect = salientObjects.reduce(into: CGRect.zero) {
            rect, object in
            rect = rect.union(object.boundingBox)
        }
        let normalzedSalientRect = VNImageRectForNormalizedRect(salientRect, Int(self.width), Int(self.height))
    }
}
