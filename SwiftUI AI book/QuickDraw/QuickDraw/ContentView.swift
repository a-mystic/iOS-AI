//
//  ContentView.swift
//  QuickDraw
//
//  Created by mystic on 2022/11/03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DrawingPad()
        .padding()
    }
}

struct DrawingPad: View {
    @State private var points: [[CGPoint]] = []
    @State private var currentPoint: [CGPoint] = []
    
    let sketchClassifier = cnnsketchclassifier()
    let context = CIContext()
    var targetSize = CGSize(width: 256, height: 256)
    var minPoint: CGPoint {
        get {
            guard currentPoint.count > 0 else { return CGPoint(x: 0, y: 0) }
            let minX: CGFloat = currentPoint.map { cp in
                return cp.x
            }.min() ?? 0
            let minY: CGFloat = currentPoint.map { cp in
                return cp.y
            }.min() ?? 0
            return CGPoint(x: minX, y: minY)
        }
    }
    var maxPoint: CGPoint {
        get {
            guard currentPoint.count > 0 else { return CGPoint(x: 0, y: 0) }
            let maxX: CGFloat = currentPoint.map { cp in
                return cp.x
            }.max() ?? 0
            let maxY: CGFloat = currentPoint.map { cp in
                return cp.y
            }.max() ?? 0
            return CGPoint(x: maxX, y: maxY)
        }
    }
    var boundingBox: CGRect {
        get {
            let minPoint = self.minPoint
            let maxPoint = self.maxPoint
            let size = CGSize(width: maxPoint.x - minPoint.x, height: maxPoint.y - minPoint.y)
            let paddingSize = CGSize(width: 5, height: 5)
            return CGRect(x: minPoint.x - paddingSize.width, y: minPoint.y - paddingSize.height, width: size.width + (paddingSize.width * 2), height: size.height + (paddingSize.height * 2))
        }
    }
    
    var body: some View {
        VStack {
            Canvas { context, size in
                for point in points {
                    var path = Path()
                    path.addLines(point)
                    context.stroke(path, with: .color(.black), lineWidth: 1)
                }
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let newPoint = value.location
                    currentPoint.append(newPoint)
                    points.append(currentPoint)
                }
                .onEnded { value in
                    classifySketch()
                    self.currentPoint = []
                }
            )
            .background(.gray)
            .frame(minWidth: 400, minHeight: 400)
        }
    }
    
    func exportSketch(size: CGSize?) -> CIImage? {
        let boundingBox = self.boundingBox
        let targetSize = size ?? CGSize(width: max(boundingBox.width, boundingBox.height), height: max(boundingBox.width, boundingBox.height))
        var scale: CGFloat = 1.0
        if boundingBox.width > boundingBox.height {
            scale = targetSize.width / boundingBox.width
        } else {
            scale = targetSize.height / boundingBox.height
        }
        guard boundingBox.width > 0, boundingBox.height > 0 else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        UIGraphicsPushContext(context)
        UIColor.white.setFill()
        context.fill(CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        context.scaleBy(x: scale, y: scale)
        let scaleSize = CGSize(width: boundingBox.width * scale, height: boundingBox.height * scale)
        context.translateBy(x: -boundingBox.origin.x + (targetSize.width - scaleSize.width)/2, y: boundingBox.origin.y + (targetSize.height - scaleSize.height)/2)
        self.drawStrokes(context: context)
        UIGraphicsPopContext()
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return image.ciImage != nil ? image.ciImage : CIImage(cgImage: image.cgImage!)
    }
    
    func drawStrokes(context: CGContext) {
        for stroke in self.points {
            self.drawStroke(context: context, stroke: stroke)
        }
    }
    
    private func drawStroke(context: CGContext, stroke: [CGPoint]) {
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(1)
        var path = CGMutablePath()
        for point in points {
            for p in point {
                path.addLine(to: p)
            }
        }
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
    
    func classifySketch() -> [(key:String,value:Double)]?{
        // rasterize image, resize and then rescale pixels (multiplying
        // them by 1.0/255.0 as per training)
        if let img = exportSketch(size: nil)?.resize(size: self.targetSize).rescalePixels(){
            return self.classifySketch(image: img)
        }
        return nil
    }
    
    func classifySketch(image:CIImage) -> [(key:String,value:Double)]?{
        print("classify")
        if let pixelBuffer = image.toPixelBuffer(context: self.context, gray: true) {
            let prediction = try? self.sketchClassifier.prediction(image: pixelBuffer)
            if let classpredictions = prediction?.classLabelProbs {
                let sortedClassPredictions = classpredictions.sorted { (kvp1, kvp2) in
                    kvp1.value > kvp2.value
                }
                print(sortedClassPredictions)
                return sortedClassPredictions
            }
        }
        return nil
    }
}
