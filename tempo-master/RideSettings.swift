//
//  RideSettings.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import Foundation
import Combine

class RideSettings: ObservableObject {
    @Published var bpm: Int = 90
    @Published var rideDurationMinutes: Int = 60
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRiding: Bool = false
    @Published var isPaused: Bool = false

    private var timer: Timer?

    // Start the ride
    func startRide() {
        timeRemaining = TimeInterval(rideDurationMinutes * 60)
        isRiding = true
        isPaused = false
        startTimer()
    }

    // Pause/resume
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
        } else {
            startTimer()
        }
    }

    // End ride
    func endRide() {
        stopTimer()
        isRiding = false
        isPaused = false
        timeRemaining = 0
    }

    // Timer management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endRide()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
