//
//  ContentView.swift
//  DrawingDetector
//
//  Created by mystic on 2022/10/10.
//

import SwiftUI

struct Line {
    var points = [CGPoint]()
    var color = Color.white
    var lineWidth: Double = 1.0
}

struct ContentView: View {
    @State private var classification: String?
    @State private var currentLine = Line()
    @State private var lines = [Line]()
    
    private let classifier = DrawingClassifierModel()
    
    var body: some View {
        NavigationView {
            VStack {
                CanvasView(currentLine: $currentLine, lines: $lines).frame(width:400, height: 400)
                Text(classification ?? "")
                Button {
                    classify()
                } label: {
                    Text("Classify").padding(.horizontal, 40).foregroundColor(.white).font(.title).background(.orange)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("DrawingDetector"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        Clear()
                    } label: {
                        Text("Clear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Undo()
                    } label: {
                        Text("Undo")
                    }
                }
            }
        }
    }
    
    private func Undo() {
        lines.removeLast()
    }
    
    private func Clear() {
        lines = []
        classification = nil
    }
    
    private func makeImage(from lines: [Line]) -> UIImage? {
        let image = CGContext.create(size: CGSize(width: 400, height: 400)) { context in
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(0.8)
            context.setLineJoin(.round)
            context.setLineCap(.round)
            for line in lines {
                context.beginPath()
                context.addPath(line.points as! CGPath)
                context.strokePath()
            }
        }
        return image
    }
    
    private func classify() {
        guard let grayscaleImage = makeImage(from: self.lines)?.applying(filter: .noir) else {
            return
        }
        classifier.classify(grayscaleImage) { result in
            self.classification = result?.icon
        }
    }
}

struct CanvasView: View {
    @Binding var currentLine: Line
    @Binding var lines: [Line]
    
    var body: some View {
        Canvas { context, size in
            for line in lines {
                var path = Path()
                path.addLines(line.points)
                context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
            }
        }.gesture(
            DragGesture()
                .onChanged { value in
                    let newPoint = value.location
                    currentLine.points.append(newPoint)
                    self.lines.append(currentLine)
                }
                .onEnded({ value in
                    self.lines.append(currentLine)
                    self.currentLine = Line(points: [])
                })
        )
    }
}

