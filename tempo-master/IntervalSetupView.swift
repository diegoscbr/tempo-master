//
//  IntervalSetupView.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import SwiftUI

struct IntervalSetupView: View {
    @StateObject private var settings = RideSettings()
    @State private var navigateToRide = false

    @State private var workBpm: Int = 100
    @State private var workMinutes: Int = 5
    @State private var restBpm: Int = 70
    @State private var restMinutes: Int = 2
    @State private var rounds: Int = 5

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("Intervals")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    Text("Alternating work/rest intervals")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))

                    // Work Interval Section
                    VStack(spacing: 20) {
                        Text("Work Interval")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)

                        // Work BPM
                        VStack(spacing: 12) {
                            Text("Cadence")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))

                            HStack(spacing: 15) {
                                Button(action: {
                                    if workBpm > 60 { workBpm -= 5 }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                }

                                Text("\(workBpm)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 100)

                                Button(action: {
                                    if workBpm < 140 { workBpm += 5 }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                }
                            }

                            Text("RPM")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                        }

                        // Work Duration
                        VStack(spacing: 12) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))

                            Picker("Work Duration", selection: $workMinutes) {
                                ForEach(1...20, id: \.self) { minute in
                                    Text("\(minute) min")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            .colorScheme(.dark)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Rest Interval Section
                    VStack(spacing: 20) {
                        Text("Rest Interval")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)

                        // Rest BPM
                        VStack(spacing: 12) {
                            Text("Cadence")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))

                            HStack(spacing: 15) {
                                Button(action: {
                                    if restBpm > 60 { restBpm -= 5 }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                }

                                Text("\(restBpm)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 100)

                                Button(action: {
                                    if restBpm < 140 { restBpm += 5 }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white)
                                }
                            }

                            Text("RPM")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                        }

                        // Rest Duration
                        VStack(spacing: 12) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))

                            Picker("Rest Duration", selection: $restMinutes) {
                                ForEach(1...10, id: \.self) { minute in
                                    Text("\(minute) min")
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            .colorScheme(.dark)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Rounds Section
                    VStack(spacing: 12) {
                        Text("Total Rounds")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))

                        Picker("Rounds", selection: $rounds) {
                            ForEach(1...20, id: \.self) { round in
                                Text("\(round)")
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        .colorScheme(.dark)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)

                    // Total Time Summary
                    Text(totalTimeString())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)

                    // Start Button
                    Button(action: {
                        settings.startInterval(
                            workBpm: workBpm,
                            workDuration: TimeInterval(workMinutes * 60),
                            restBpm: restBpm,
                            restDuration: TimeInterval(restMinutes * 60),
                            totalRounds: rounds
                        )
                        navigateToRide = true
                    }) {
                        Text("Start Workout")
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
                    .padding(.top, 20)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToRide) {
            DisplayView(settings: settings)
                .navigationBarBackButtonHidden(true)
        }
    }

    private func totalTimeString() -> String {
        let totalMinutes = (workMinutes + restMinutes) * rounds
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "Total: \(hours)h \(minutes)m"
        } else {
            return "Total: \(minutes) minutes"
        }
    }
}

#Preview {
    IntervalSetupView()
}
