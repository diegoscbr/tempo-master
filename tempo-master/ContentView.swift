//
//  DisplayView.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import SwiftUI

struct DisplayView: View {
    @ObservedObject var settings: RideSettings
    @Environment(\.dismiss) private var dismiss

    @State private var showPauseMenu: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var isAnimating: Bool = false
    @State private var rotationTimer: Timer?

    // Pulse/ripple state for circles
    @State private var blueRippleScale: CGFloat = 1.0
    @State private var blueRippleOpacity: Double = 0.0
    @State private var magentaRippleScale: CGFloat = 1.0
    @State private var magentaRippleOpacity: Double = 0.0

    // 12 o'clock indicator
    @State private var topIndicatorColor: Color = Color(red: 0.0, green: 0.7, blue: 1.0)

    private let neonBlue = Color(red: 0.0, green: 0.7, blue: 1.0)
    private let neonMagenta = Color(red: 1.0, green: 0.0, blue: 0.8)
    private let circleSize: CGFloat = 200

    // Calculate beat interval in seconds (60 seconds / BPM)
    private var beatInterval: Double {
        60.0 / Double(settings.bpm)
    }

    // Full rotation takes 2 beats (each rod hits top once per 2 beats, but they alternate)
    private var fullRotationDuration: Double {
        beatInterval * 2
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                // Blue ripple effect (expands outward)
                Circle()
                    .stroke(neonBlue, lineWidth: 4)
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(blueRippleScale)
                    .opacity(blueRippleOpacity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Magenta ripple effect (expands outward)
                Circle()
                    .stroke(neonMagenta, lineWidth: 4)
                    .frame(width: circleSize * 0.6, height: circleSize * 0.6)
                    .scaleEffect(magentaRippleScale)
                    .opacity(magentaRippleOpacity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Left pedal rod (blue) - rotates clockwise, starts at top
                RodView(color: neonBlue, length: circleSize * 0.8, thickness: 12)
                    .rotationEffect(.degrees(rotationAngle))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Right pedal rod (magenta) - rotates clockwise, starts at bottom (180° offset)
                RodView(color: neonMagenta, length: circleSize * 0.8, thickness: 12)
                    .rotationEffect(.degrees(rotationAngle + 180))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Small center dot
                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // 12 o'clock indicator - alternates color when rods hit
                Image(systemName: "triangle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(topIndicatorColor)
                    .rotationEffect(.degrees(180))
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - circleSize * 0.8 - 20)

                // Cadence adjuster for Just Ride and Timed modes
                if settings.workoutMode == .justRide || settings.workoutMode == .timed {
                    VStack {
                        Spacer()

                        // Cadence control
                        HStack(spacing: 40) {
                            // Decrease BPM button
                            Button(action: {
                                if settings.bpm > 40 {
                                    settings.bpm -= 5
                                    restartRotationForNewBpm()
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(neonMagenta.opacity(0.5), lineWidth: 2)
                                    )
                            }

                            // BPM display
                            VStack(spacing: 4) {
                                Text("\(settings.bpm)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("BPM")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(width: 100)

                            // Increase BPM button
                            Button(action: {
                                if settings.bpm < 200 {
                                    settings.bpm += 5
                                    restartRotationForNewBpm()
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(neonBlue.opacity(0.5), lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.bottom, 80)
                    }
                }

                if #available(iOS 17.0, *) {
                    Color.clear
                        .onAppear {
                            startRotation()
                        }
                        .onChange(of: settings.isRiding) { oldValue, newValue in
                            if !newValue {
                                endRideAnimation()
                            }
                        }
                        .onChange(of: settings.isPaused) { oldValue, newValue in
                            if newValue {
                                pauseRotation()
                            } else {
                                resumeRotation()
                            }
                        }
                } else {
                    // Fallback on earlier versions
                }

                // Top bar with timer and pause button
                VStack {
                    HStack {
                        // Timer and interval info (top left)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(timerString())
                                .font(.system(size: 36, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)

                            // Show interval info if in interval mode
                            if settings.workoutMode == .interval {
                                HStack(spacing: 8) {
                                    Text("Round \(settings.currentRound)/\(getTotalRounds())")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))

                                    Text("•")
                                        .foregroundColor(.white.opacity(0.5))

                                    Text(settings.isWorkPhase ? "WORK" : "REST")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(settings.isWorkPhase ? neonBlue : neonMagenta)
                                }
                            }
                        }
                        .padding(.leading, 24)

                        Spacer()

                        // Pause Button (top right)
                        Button(action: {
                            settings.togglePause()
                            showPauseMenu = true
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.3), lineWidth: 2)
                                )
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.top, 24)

                    Spacer()
                }

                // Pause Menu Overlay
                if showPauseMenu {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Dismiss on background tap
                            settings.togglePause()
                            showPauseMenu = false
                        }

                    VStack(spacing: 20) {
                        // Resume Button
                        Button(action: {
                            settings.togglePause()
                            showPauseMenu = false
                        }) {
                            Text("Resume")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: 280)
                                .frame(height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.3), lineWidth: 2)
                                )
                        }

                        // Quit Button
                        Button(action: {
                            settings.endRide()
                            showPauseMenu = false
                            dismiss()
                        }) {
                            Text("Quit")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: 280)
                                .frame(height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.3), lineWidth: 2)
                                )
                        }
                    }
                }
            }
        }
    }

    private func startRotation() {
        guard settings.isRiding else { return }
        isAnimating = true

        // Calculate degrees per frame for 60fps
        let degreesPerSecond = 360.0 / fullRotationDuration
        let frameRate: Double = 60.0
        let degreesPerFrame = degreesPerSecond / frameRate

        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { _ in
            guard self.isAnimating && self.settings.isRiding && !self.settings.isPaused else { return }
            self.rotationAngle += degreesPerFrame
        }

        // Start pulse loop (separate from rotation)
        startPulseLoop()
    }

    private func startPulseLoop() {
        guard isAnimating && settings.isRiding && !settings.isPaused else { return }

        // Blue pulse now (blue rod at top)
        triggerBluePulse()

        // Magenta pulse after 1 beat (magenta rod reaches top)
        DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval) {
            guard self.isAnimating && self.settings.isRiding && !self.settings.isPaused else { return }
            self.triggerMagentaPulse()
        }

        // Repeat cycle after 2 beats (full rotation)
        DispatchQueue.main.asyncAfter(deadline: .now() + fullRotationDuration) {
            guard self.isAnimating && self.settings.isRiding && !self.settings.isPaused else { return }
            self.startPulseLoop()
        }
    }

    private func triggerBluePulse() {
        // Reset blue ripple
        blueRippleScale = 1.0
        blueRippleOpacity = 0.8

        // Change indicator to blue
        withAnimation(.easeOut(duration: 0.15)) {
            topIndicatorColor = neonBlue
        }

        // Animate ripple expansion and fade
        withAnimation(.easeOut(duration: beatInterval * 1.5)) {
            blueRippleScale = 2.5
            blueRippleOpacity = 0.0
        }
    }

    private func triggerMagentaPulse() {
        // Reset magenta ripple
        magentaRippleScale = 1.0
        magentaRippleOpacity = 0.8

        // Change indicator to magenta
        withAnimation(.easeOut(duration: 0.15)) {
            topIndicatorColor = neonMagenta
        }

        // Animate ripple expansion and fade
        withAnimation(.easeOut(duration: beatInterval * 1.5)) {
            magentaRippleScale = 3.0
            magentaRippleOpacity = 0.0
        }
    }

    private func pauseRotation() {
        isAnimating = false
        rotationTimer?.invalidate()
        rotationTimer = nil
    }

    private func resumeRotation() {
        isAnimating = true
        startRotation()
    }

    private func restartRotationForNewBpm() {
        // Stop current rotation and pulse loop
        rotationTimer?.invalidate()
        rotationTimer = nil

        // Restart with new BPM (keep current angle for smooth transition)
        let degreesPerSecond = 360.0 / fullRotationDuration
        let frameRate: Double = 60.0
        let degreesPerFrame = degreesPerSecond / frameRate

        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { _ in
            guard self.isAnimating && self.settings.isRiding && !self.settings.isPaused else { return }
            self.rotationAngle += degreesPerFrame
        }
    }

    private func endRideAnimation() {
        isAnimating = false
        rotationTimer?.invalidate()
        rotationTimer = nil
        dismiss()
    }

    private func timerString() -> String {
        switch settings.workoutMode {
        case .justRide:
            // Show elapsed time counting up
            return timeString(from: settings.timeElapsed)
        case .timed, .interval:
            // Show remaining time counting down
            return timeString(from: settings.timeRemaining)
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func getTotalRounds() -> Int {
        return settings.totalRounds
    }
}

// Rod/clock hand view that extends upward from center
struct RodView: View {
    let color: Color
    let length: CGFloat
    let thickness: CGFloat

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: thickness, height: length)
            .offset(y: -length / 2) // Anchor at bottom (center of clock), extend upward
    }
}

#Preview {
    DisplayView(settings: RideSettings())
}
