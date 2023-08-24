//
//  ContentView.swift
//  SpeechRecognize
//
//  Created by mystic on 2022/10/09.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @State private var recording = false
    @State private var speech = ""
    @State private var recordingState = "Start"
    
    private let recognizer: SpeechRecognizer
    
    init() {
        if let recognizer = SpeechRecognizer() {
            self.recognizer = recognizer
        } else {
            fatalError("Something wrong")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(speech).font(.title).bold()
                Spacer()
                Button {
                    if recording {
                        stopRecording()
                        recordingState = "Start"
                    } else {
                        startRecording()
                        recordingState = "Stop"
                    }
                } label: {
                    ButtonLabel(recordingState + "Recording", background: .orange)
                }
            }
            .navigationTitle(Text("SpeechRecognizer"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func startRecording() {
        self.recording = true
        self.speech = ""
        recognizer.startRecording { result in
            if let text = result {
                self.speech = text
            } else {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        self.recording = false
        recognizer.stopRecording()
    }
}

struct ButtonLabel: View {
    private let title: String
    private let background: Color
    
    init(_ title: String, background: Color) {
        self.title = title
        self.background = background
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(title).font(.title).bold().foregroundColor(.white)
            Spacer()
        }.padding().background(background).cornerRadius(20)
    }
}
