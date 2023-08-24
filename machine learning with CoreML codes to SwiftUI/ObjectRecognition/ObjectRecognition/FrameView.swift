//
//  FrameView.swift
//  ObjectRecognition
//
//  Created by mystic on 2022/10/29.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("frame")
    
    var body: some View {
        if let image = image {
            Image(image, scale: 1.0, orientation: .up, label: label)
                .onAppear { print("imageTrue") }
        } else {
            Color.orange
                .overlay(Text("nil"))
        }
    }
}
