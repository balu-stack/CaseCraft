//
//  ToothShape.swift
//  Case
//
//  Created by SAIL L1 on 24/02/26.
//
import SwiftUI 

struct ToothShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.3, y: height * 0.1))

        path.addQuadCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.1),
            control: CGPoint(x: width * 0.5, y: 0)
        )

        path.addLine(to: CGPoint(x: width * 0.85, y: height * 0.6))

        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control: CGPoint(x: width * 0.85, y: height * 0.9)
        )

        path.addQuadCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.6),
            control: CGPoint(x: width * 0.15, y: height * 0.9)
        )

        path.closeSubpath()

        return path
    }
}
