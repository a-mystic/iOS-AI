//
//  Tracking.swift
//  ActivityRecognition
//
//  Created by mystic on 2022/10/10.
//

import SwiftUI
import Combine
import CoreMotion

final class ActivityTracker: ObservableObject {
    @Published private(set) var currentAcivity: String = "None" {
        willSet {
            activityDidChange = (newValue != currentAcivity)
        }
    }
    
    private let tracker = CMMotionActivityManager()
    private(set) var activityDidChange = true
    
    init() {}
    
    func startTracking() {
        do {
            try tracker.startTracking { result in
                self.currentAcivity = result?.name ?? "None"
            }
        } catch {
            print(error)
            stopTracking()
        }
    }
            
    func stopTracking() {
        self.currentAcivity = "Not Tracking"
        tracker.stopTracking()
    }
}
