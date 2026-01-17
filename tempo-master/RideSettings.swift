//
//  RideSettings.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import Foundation
import Combine

enum WorkoutMode {
    case justRide      // Count up, no time limit
    case timed         // Count down from set duration
    case interval      // Alternating work/rest intervals
}

class RideSettings: ObservableObject {
    @Published var bpm: Int = 90
    @Published var rideDurationMinutes: Int = 60
    @Published var timeRemaining: TimeInterval = 0
    @Published var timeElapsed: TimeInterval = 0
    @Published var isRiding: Bool = false
    @Published var isPaused: Bool = false
    @Published var workoutMode: WorkoutMode = .timed

    // Interval-specific properties
    @Published var isWorkPhase: Bool = true
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 5
    private var workBpm: Int = 90
    private var restBpm: Int = 70
    private var workDuration: TimeInterval = 300
    private var restDuration: TimeInterval = 120

    private var timer: Timer?

    // Start timed ride (countdown)
    func startRide() {
        workoutMode = .timed
        timeRemaining = TimeInterval(rideDurationMinutes * 60)
        timeElapsed = 0
        isRiding = true
        isPaused = false
        startTimer()
    }

    // Start just ride (count up)
    func startJustRide() {
        workoutMode = .justRide
        timeElapsed = 0
        timeRemaining = 0
        isRiding = true
        isPaused = false
        startTimer()
    }

    // Start interval workout
    func startInterval(workBpm: Int, workDuration: TimeInterval, restBpm: Int, restDuration: TimeInterval, totalRounds: Int) {
        self.workoutMode = .interval
        self.workBpm = workBpm
        self.restBpm = restBpm
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.totalRounds = totalRounds

        self.currentRound = 1
        self.isWorkPhase = true
        self.bpm = workBpm
        self.timeRemaining = workDuration
        self.timeElapsed = 0
        self.isRiding = true
        self.isPaused = false
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
        timeElapsed = 0
    }

    // Timer management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            switch self.workoutMode {
            case .justRide:
                // Count up indefinitely
                self.timeElapsed += 1

            case .timed:
                // Count down
                self.timeElapsed += 1
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endRide()
                }

            case .interval:
                // Handle intervals
                self.timeElapsed += 1
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    // Switch phases
                    if self.isWorkPhase {
                        // Switch to rest
                        self.isWorkPhase = false
                        self.bpm = self.restBpm
                        self.timeRemaining = self.restDuration
                    } else {
                        // End of rest, check if more rounds
                        if self.currentRound < self.totalRounds {
                            // Start next round
                            self.currentRound += 1
                            self.isWorkPhase = true
                            self.bpm = self.workBpm
                            self.timeRemaining = self.workDuration
                        } else {
                            // Workout complete
                            self.endRide()
                        }
                    }
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
