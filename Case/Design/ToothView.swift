import SwiftUI

struct ToothView: View {
    let tooth: Tooth

    var body: some View {
        ZStack {

            // Base tooth shape
            ToothShape()
                .fill(fillColor)   // ✅ fill entire shape
                .frame(width: 34, height: 55)
                .overlay(
                    ToothShape()
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )

            // Only show X for extraction
            if tooth.condition == .extraction {
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }

    private var fillColor: Color {
        switch tooth.condition {
        case .normal:
            return Color.white

        case .caries:
            return Color.red.opacity(0.6)

        case .restoration:
            return Color.blue.opacity(0.5)

        case .missing:
            return Color.gray.opacity(0.3)

        case .extraction:
            return Color.white
        }
    }
}
struct Tooth: Identifiable {
    let id = UUID()
    let number: String
    var condition: ToothCondition = .normal
}
