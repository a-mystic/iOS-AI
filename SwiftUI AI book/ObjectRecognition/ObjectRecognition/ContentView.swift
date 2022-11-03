//
//  ContentView.swift
//  ObjectRecognition
//
//  Created by mystic on 2022/10/29.
//

import SwiftUI

struct ContentView: View {
    @State var text = "nil"
    var body: some View {
        ZStack(alignment: .bottom) {
            VideoCaptureView(text: $text)
                .ignoresSafeArea()
            Text(text)
        }
    }
}
