//
//  PreDefinedWorkoutsView.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import SwiftUI

struct PreDefinedWorkoutsView: View {
    @State private var navigateToRide = false
    @State private var selectedSettings: RideSettings?

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Title
                    Text("Pre-Defined Workouts")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    Text("Structured training plans")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))

                    VStack(spacing: 20) {
                        // Tempo Blocks
                        WorkoutCard(
                            title: "Tempo Blocks",
                            description: "3x10 min at 85-90 RPM\n5 min easy between",
                            duration: "40 minutes",
                            difficulty: "Moderate"
                        ) {
                            let settings = RideSettings()
                            settings.startInterval(
                                workBpm: 88,
                                workDuration: 600, // 10 min
                                restBpm: 70,
                                restDuration: 300, // 5 min
                                totalRounds: 3
                            )
                            selectedSettings = settings
                            navigateToRide = true
                        }

                        // Sweet Spot
                        WorkoutCard(
                            title: "Sweet Spot",
                            description: "2x20 min at 88-93 RPM\n10 min recovery between",
                            duration: "50 minutes",
                            difficulty: "Hard"
                        ) {
                            let settings = RideSettings()
                            settings.startInterval(
                                workBpm: 90,
                                workDuration: 1200, // 20 min
                                restBpm: 65,
                                restDuration: 600, // 10 min
                                totalRounds: 2
                            )
                            selectedSettings = settings
                            navigateToRide = true
                        }

                        // Steady State
                        WorkoutCard(
                            title: "Steady State",
                            description: "3x15 min at 80-85 RPM\n5 min easy between",
                            duration: "55 minutes",
                            difficulty: "Moderate"
                        ) {
                            let settings = RideSettings()
                            settings.startInterval(
                                workBpm: 83,
                                workDuration: 900, // 15 min
                                restBpm: 68,
                                restDuration: 300, // 5 min
                                totalRounds: 3
                            )
                            selectedSettings = settings
                            navigateToRide = true
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToRide) {
            if let settings = selectedSettings {
                DisplayView(settings: settings)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct WorkoutCard: View {
    let title: String
    let description: String
    let duration: String
    let difficulty: String
    let action: () -> Void

    var difficultyColor: Color {
        switch difficulty {
        case "Easy": return .green
        case "Moderate": return .orange
        case "Hard": return .red
        default: return .white
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // Difficulty badge
                    Text(difficulty)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(difficultyColor.opacity(0.3))
                        )
                        .overlay(
                            Capsule()
                                .stroke(difficultyColor, lineWidth: 1)
                        )
                }

                // Description
                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)

                // Footer
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))

                    Text(duration)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PreDefinedWorkoutsView()
}
