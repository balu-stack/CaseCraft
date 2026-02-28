//
//  TabIcon.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


import SwiftUI

struct TabIcon: View {

    let systemName: String
    let title: String
    let isSelected: Bool
    let glow: Color

    var body: some View {
        VStack(spacing: 3) {

            ZStack {

                // Glow background when selected
                if isSelected {
                    Circle()
                        .fill(glow.opacity(0.35))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(glow.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: glow.opacity(0.6),
                                radius: 10, x: 0, y: 4)
                }

                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(
                        isSelected
                        ? .white
                        : .white.opacity(0.6)
                    )
            }

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(
                    isSelected
                    ? .white
                    : .white.opacity(0.6)
                )
        }
    }
}