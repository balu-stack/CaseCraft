//
//  ToothCondition.swift
//  Case
//
//  Created by SAIL L1 on 23/02/26.
//

import SwiftUI
enum ToothCondition: String, CaseIterable {
    case normal
    case caries
    case missing
    case extraction
    case restoration

    var color: Color {
        switch self {
        case .normal: return Color.yellow.opacity(0.4)
        case .caries: return .red.opacity(0.6)
        case .missing: return .gray.opacity(0.4)
        case .extraction: return .black.opacity(0.7)
        case .restoration: return .blue.opacity(0.5)
        }
    }
}
