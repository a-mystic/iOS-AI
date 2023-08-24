//
//  Sketch.swift
//  QuickDraw
//
//  Created by Joshua Newnham on 04/01/2018.
//  Copyright © 2018 Method. All rights reserved.
//

import UIKit

protocol Sketch : class{
    
    var boundingBox : CGRect{ get }
    
    var center : CGPoint{ get set }
    
    func draw(context:CGContext)
    
    func exportSketch(size:CGSize?) -> CIImage?
}

class StrokeSketch: Sketch {
    var boundingBox: CGRect {
        get {
            let minPoint = self.minPoint
            let maxPoint = self.maxPoint
            let size = CGSize(width: maxPoint.x - minPoint.x, height: maxPoint.y - minPoint.y)
            let paddingSize = CGSize(width: 5, height: 5)
            return CGRect(x: minPoint.x - paddingSize.width, y: minPoint.y - paddingSize.height, width: size.width + (paddingSize.width * 2), height: size.height + (paddingSize.height * 2))
        }
    }
    var center: CGPoint {
        get {
            let bbox = self.boundingBox
            return CGPoint(x: bbox.origin.x + bbox.size.width / 2, y: bbox.origin.y + bbox.size.height / 2)
        }
        set {
            let previousCenter = self.center
            let newCenter = newValue
            let translate = CGPoint(x: newCenter.x - previousCenter.x, y: newCenter.y - previousCenter.y)
            for stroke in strokes {
                for i in 0..<stroke.points.count {
                    stroke.points[i] = CGPoint(x: stroke.points[i].x + translate.x, y: stroke.points[i].y + translate.y)
                }
            }
        }
    }
    var label: String?
    var strokes = [Stroke]()
    var currentStroke: Stroke? {
        get { return strokes.count > 0 ? strokes.last : nil }
    }
    var minPoint: CGPoint {
        get {
            guard strokes.count > 0 else { return CGPoint(x: 0, y: 0) }
            let minPoints = strokes.map { $0.minPoint }
            let minX: CGFloat = minPoints.map { cp in
                return cp.x
            }.min() ?? 0
            let minY: CGFloat = minPoints.map { cp in
                return cp.y
            }.min() ?? 0
            return CGPoint(x: minX, y: minY)
        }
    }
    var maxPoint: CGPoint {
        get {
            guard strokes.count > 0 else { return CGPoint(x: 0, y: 0) }
            let maxPoints = strokes.map { $0.maxPoint }
            let maxX: CGFloat = maxPoints.map { cp in
                return cp.x
            }.max() ?? 0
            let maxY: CGFloat = maxPoints.map { cp in
                return cp.y
            }.max() ?? 0
            return CGPoint(x: maxX, y: maxY)
        }
    }
    
    func addStroke(stroke: Stroke) {
        self.strokes.append(stroke)
    }
    
    func draw(context: CGContext) {
        self.drawStrokes(context: context)
    }
    
    func drawStrokes(context: CGContext) {
        for stroke in self.strokes {
            self.drawStroke(context: context, stroke: stroke)
        }
    }
    
    private func drawStroke(context: CGContext, stroke: Stroke) {
        context.setStrokeColor(stroke.color.cgColor)
        context.setLineWidth(stroke.width)
        context.addPath(stroke.path)
        context.drawPath(using: .stroke)
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
}
