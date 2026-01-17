//
//  MainMenuView.swift
//  tempo-master
//
//  Created by Diego Escobar on 1/16/26.
//

import SwiftUI

struct MainMenuView: View {
    @State private var navigateToJustRide = false
    @State private var navigateToTimed = false
    @State private var navigateToIntervals = false
    @State private var navigateToPredefined = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // App Title
                    Text("Tempo Master")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    Text("Choose Your Workout")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    VStack(spacing: 20) {
                        // Just Ride Button
                        NavigationLink(destination: JustRideSetupView()) {
                            MenuButton(
                                title: "Just Ride",
                                subtitle: "Free ride with cadence guide",
                                icon: "bicycle"
                            )
                        }

                        // Timed Ride Button (old HomeView functionality)
                        NavigationLink(destination: TimedRideSetupView()) {
                            MenuButton(
                                title: "Timed Ride",
                                subtitle: "Set duration and cadence",
                                icon: "timer"
                            )
                        }

                        // Intervals Button
                        NavigationLink(destination: IntervalSetupView()) {
                            MenuButton(
                                title: "Intervals",
                                subtitle: "Work/rest intervals",
                                icon: "chart.line.uptrend.xyaxis"
                            )
                        }

                        // Pre-Defined Workouts Button
                        NavigationLink(destination: PreDefinedWorkoutsView()) {
                            MenuButton(
                                title: "Pre-Defined Workouts",
                                subtitle: "Structured training plans",
                                icon: "list.bullet.clipboard"
                            )
                        }

                        // Custom Workout Button (disabled for now)
                        MenuButton(
                            title: "Custom Workout",
                            subtitle: "Coming soon",
                            icon: "slider.horizontal.3",
                            disabled: true
                        )
                    }
                    .padding(.horizontal, 30)

                    Spacer()
                }
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let icon: String
    var disabled: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(disabled ? .white.opacity(0.3) : .white)
                .frame(width: 50)

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(disabled ? .white.opacity(0.3) : .white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(disabled ? .white.opacity(0.2) : .white.opacity(0.6))
            }

            Spacer()

            // Arrow
            if !disabled {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(disabled ? 0.1 : 0.2), lineWidth: 1)
        )
        .opacity(disabled ? 0.5 : 1.0)
    }
}

#Preview {
    MainMenuView()
}
