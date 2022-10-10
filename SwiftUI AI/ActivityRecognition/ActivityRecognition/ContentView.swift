//
//  ContentView.swift
//  ActivityRecognition
//
//  Created by mystic on 2022/10/10.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var tracker: ActivityTracker
    private let speechSynthesiser = AVSpeechSynthesizer()
    
    var body: some View {
        tracker.startTracking()
        let newActivity = tracker.currentAcivity
        if tracker.activityDidChange {
            speechSynthesiser.say(newActivity)
        }
        return Text(newActivity).font(.largeTitle)
    }
}

extension AVSpeechSynthesizer {
    func say(_ text: String) {
        self.speak(AVSpeechUtterance(string: text))
    }
}
