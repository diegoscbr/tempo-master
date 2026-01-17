//
//  TimedRideSetupView.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import SwiftUI

struct TimedRideSetupView: View {
    @StateObject private var settings = RideSettings()
    @State private var navigateToRide = false

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title
                Text("Timed Ride")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                // RPM Stepper
                VStack(spacing: 16) {
                    Text("Target Cadence")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 20) {
                        Button(action: {
                            if settings.bpm > 60 {
                                settings.bpm -= 5
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .disabled(settings.bpm <= 60)

                        Text("\(settings.bpm)")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(.white)
                            .frame(minWidth: 120)

                        Button(action: {
                            if settings.bpm < 140 {
                                settings.bpm += 5
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .disabled(settings.bpm >= 140)
                    }

                    Text("RPM")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                }

                // Ride Time Picker
                VStack(spacing: 16) {
                    Text("Ride Duration")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))

                    Picker("Ride Duration", selection: $settings.rideDurationMinutes) {
                        ForEach(1...180, id: \.self) { minute in
                            Text("\(minute) min")
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .colorScheme(.dark)
                }

                Spacer()

                // Start Ride Button
                Button(action: {
                    settings.startRide()
                    navigateToRide = true
                }) {
                    Text("Start Ride")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationDestination(isPresented: $navigateToRide) {
            DisplayView(settings: settings)
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    TimedRideSetupView()
}
