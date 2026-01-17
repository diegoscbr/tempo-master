//
//  ContentView.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import SwiftUI

struct DisplayView: View {
    @State private var yOffset: CGFloat = 0
    @State private var scaleX: CGFloat = 1.0
    @State private var scaleY: CGFloat = 1.0
    @State private var isSquished: Bool = false
    private let bpm: Double = 90
    private let ballSize: CGFloat = 60
    private let floorOffset: CGFloat = 50 // Distance from bottom of screen

    // Calculate beat interval in seconds (60 seconds / BPM)
    private var beatInterval: Double {
        60.0 / bpm
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                // Bouncing white ball with squish effect
                Circle()
                    .fill(.white)
                    .frame(width: ballSize, height: ballSize)
                    .scaleEffect(x: scaleX, y: scaleY)
                    .offset(y: yOffset)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - floorOffset - ballSize / 2)
                    .onAppear {
                        startBouncing(screenHeight: geometry.size.height)
                    }
            }
        }
    }

    private func startBouncing(screenHeight: CGFloat) {
        // Calculate max bounce height (bounce to near top of screen)
        let maxBounceHeight = screenHeight - floorOffset - ballSize - 100

        // Start the bounce cycle
        bounce(maxHeight: maxBounceHeight)
    }

    private func bounce(maxHeight: CGFloat) {
        // Ball rises (decelerates as it goes up - easeOut) - 1 full beat
        withAnimation(.easeOut(duration: beatInterval)) {
            yOffset = -maxHeight
            scaleX = 1.0
            scaleY = 1.0
        }

        // Ball falls (accelerates as it goes down - easeIn) - 1 full beat
        DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval) {
            withAnimation(.easeIn(duration: beatInterval * 0.9)) {
                yOffset = 0
            }

            // Squish happens right at impact (last 10% of fall)
            DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval * 0.8) {
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
}

#Preview {
    DisplayView()
}
