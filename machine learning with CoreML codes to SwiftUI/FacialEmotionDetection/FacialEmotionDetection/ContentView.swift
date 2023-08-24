//
//  ContentView.swift
//  FacialEmotionDetection
//
//  Created by mystic on 2022/10/30.
//

import SwiftUI

struct ContentView: View {
    @State var text = ""
    var body: some View {
        VideoCaptureView(text: $text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
