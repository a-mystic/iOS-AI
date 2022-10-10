//
//  ActivityRecognitionApp.swift
//  ActivityRecognition
//
//  Created by mystic on 2022/10/10.
//

import SwiftUI

@main
struct ActivityRecognitionApp: App {
    let tracker = ActivityTracker()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(tracker)
        }
    }
}
