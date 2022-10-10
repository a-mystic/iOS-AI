//
//  ContentView.swift
//  DrawingDetector
//
//  Created by mystic on 2022/10/10.
//

import SwiftUI

struct ContentView: View {
    @State private var classification: String?
    
    var body: some View {
        NavigationView {
            VStack {
                CanvasView()
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
        
    }
    
    private func Clear() {
        
    }
    
    private func classify() {
        
    }
}

struct CanvasView: View {
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    
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
    
    struct Line {
        var points = [CGPoint]()
        var color = Color.white
        var lineWidth: Double = 1.0
    }
}

