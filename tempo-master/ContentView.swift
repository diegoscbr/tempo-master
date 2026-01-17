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

    @State private var yOffset: CGFloat = 0
    @State private var scaleX: CGFloat = 1.0
    @State private var scaleY: CGFloat = 1.0
    @State private var ballScale: CGFloat = 1.0
    @State private var shouldBounce: Bool = true
    @State private var screenHeight: CGFloat = 0
    @State private var showPauseMenu: Bool = false
    @State private var rippleScale: CGFloat = 0.1
    @State private var rippleOpacity: Double = 0.8
    @State private var ceilingRippleScale: CGFloat = 0.1
    @State private var ceilingRippleOpacity: Double = 0.8
    @State private var maxBounceHeight: CGFloat = 0

    private let ballSize: CGFloat = 60
    private let floorOffset: CGFloat = 50
    private let neonBlue = Color(red: 0.0, green: 0.7, blue: 1.0)
    private let neonMagenta = Color(red: 1.0, green: 0.0, blue: 0.8)

    // Calculate beat interval in seconds (60 seconds / BPM)
    private var beatInterval: Double {
        60.0 / Double(settings.bpm)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                // Floor ripple effect (blue - at floor position)
                Circle()
                    .stroke(neonBlue, lineWidth: 4)
                    .frame(width: ballSize, height: ballSize)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - floorOffset - ballSize / 2)

                // Ceiling ripple effect (magenta - at floor position)
                Circle()
                    .stroke(neonMagenta, lineWidth: 4)
                    .frame(width: ballSize, height: ballSize)
                    .scaleEffect(ceilingRippleScale)
                    .opacity(ceilingRippleOpacity)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - floorOffset - ballSize / 2)

                // Bouncing white ball with squish effect
                Circle()
                    .fill(.white)
                    .frame(width: ballSize, height: ballSize)
                    .scaleEffect(x: scaleX * ballScale, y: scaleY * ballScale)
                    .offset(y: yOffset)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - floorOffset - ballSize / 2)
                    .onAppear {
                        screenHeight = geometry.size.height
                        startBouncing()
                    }
                    .onChange(of: settings.isRiding) { oldValue, newValue in
                        if !newValue {
                            endRideAnimation(geometry: geometry)
                        }
                    }
                    .onChange(of: settings.isPaused) { oldValue, newValue in
                        if newValue {
                            shouldBounce = false
                        } else {
                            shouldBounce = true
                            startBouncing()
                        }
                    }

                // Top bar with timer and pause button
                VStack {
                    HStack {
                        // Countdown Timer (top left)
                        Text(timeString(from: settings.timeRemaining))
                            .font(.system(size: 36, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
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

    private func startBouncing() {
        guard shouldBounce && settings.isRiding else { return }

        maxBounceHeight = screenHeight - floorOffset - ballSize - 100
        bounce(maxHeight: maxBounceHeight)
    }

    private func bounce(maxHeight: CGFloat) {
        guard shouldBounce && settings.isRiding else { return }

        // Trigger floor ripple at the start of bounce (when ball hits floor)
        triggerFloorRipple()

        // Ball rises (decelerates as it goes up - easeOut) - 1 full beat
        withAnimation(.easeOut(duration: beatInterval)) {
            yOffset = -maxHeight
            scaleX = 1.0
            scaleY = 1.0
        }

        // Trigger ceiling ripple when ball reaches the top
        DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval) {
            guard self.shouldBounce && self.settings.isRiding else { return }
            self.triggerCeilingRipple()
        }

        // Ball falls (accelerates as it goes down - easeIn) - 1 full beat
        DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval) {
            guard self.shouldBounce && self.settings.isRiding else { return }

            withAnimation(.easeIn(duration: beatInterval * 0.9)) {
                yOffset = 0
            }

            // Squish happens right at impact (last 10% of fall)
            DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval * 0.8) {
                guard self.shouldBounce && self.settings.isRiding else { return }

                withAnimation(.easeOut(duration: beatInterval * 0.2)) {
                    scaleX = 1.3
                    scaleY = 0.7
                }

                // Repeat the cycle
                DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval * 0.2) {
                    bounce(maxHeight: maxHeight)
                }
            }
        }
    }

    private func triggerFloorRipple() {
        // Reset floor ripple
        rippleScale = 1.0
        rippleOpacity = 0.8

        // Animate ripple expansion and fade
        withAnimation(.easeOut(duration: beatInterval * 2)) {
            rippleScale = 8.0
            rippleOpacity = 0.0
        }
    }

    private func triggerCeilingRipple() {
        // Reset ceiling ripple
        ceilingRippleScale = 1.0
        ceilingRippleOpacity = 0.8

        // Animate ripple expansion and fade
        withAnimation(.easeOut(duration: beatInterval * 2)) {
            ceilingRippleScale = 8.0
            ceilingRippleOpacity = 0.0
        }
    }

    private func endRideAnimation(geometry: GeometryProxy) {
        shouldBounce = false

        // Calculate offset to center the ball
        // Current position Y: geometry.size.height - floorOffset - ballSize / 2
        // Target position Y: geometry.size.height / 2
        // Offset needed: target - current
        let centerY = geometry.size.height / 2
        let currentY = geometry.size.height - floorOffset - ballSize / 2
        let centerOffset = centerY - currentY

        // Stop ball at center of screen
        withAnimation(.easeOut(duration: 0.5)) {
            yOffset = centerOffset
            scaleX = 1.0
            scaleY = 1.0
        }

        // Expand ball to fill screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                ballScale = max(geometry.size.width, geometry.size.height) / ballSize * 2
            }

            // Dismiss back to home
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                dismiss()
            }
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    DisplayView(settings: RideSettings())
}
