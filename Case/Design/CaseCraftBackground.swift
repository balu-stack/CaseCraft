//
//  CaseCraftBackground.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// =======================================================
// 9) CaseCraftBackground.swift  (Use same background everywhere)
// =======================================================

import SwiftUI

struct CaseCraftBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 24/255, green: 28/255, blue: 66/255),
                Color(red: 45/255, green: 88/255, blue: 166/255),
                Color(red: 80/255, green: 180/255, blue: 200/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Circle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 260, height: 260)
            .blur(radius: 60)
            .offset(x: -120, y: -220)

        Circle()
            .fill(Color.cyan.opacity(0.12))
            .frame(width: 220, height: 220)
            .blur(radius: 70)
            .offset(x: 140, y: 260)
    }
}
//struct CaseCraftBackground: View {
//    var body: some View {
//        LinearGradient(
//            colors: [
//                Color(.systemBackground),
//                Color(.systemBackground).opacity(0.92),
//                Color.accentColor.opacity(0.10),
//                Color(.systemBackground)
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea()
//        .overlay(
//            ZStack {
//                Circle()
//                    .fill(Color.accentColor.opacity(0.10))
//                    .frame(width: 260, height: 260)
//                    .blur(radius: 30)
//                    .offset(x: -120, y: -220)
//
//                Circle()
//                    .fill(Color.purple.opacity(0.10))
//                    .frame(width: 260, height: 260)
//                    .blur(radius: 30)
//                    .offset(x: 140, y: 260)
//            }
//        )
//    }
//}
