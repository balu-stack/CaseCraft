import SwiftUI

struct ArchView: View {

    @Binding var teeth: [Tooth]
    let arch: String

    @Binding var selectedToothIndex: (arch: String, index: Int)?
    @Binding var showConditionPicker: Bool

    var body: some View {
        VStack(spacing: 8) {

            HStack(spacing: 4) {
                ForEach(teeth.indices, id: \.self) { index in
                    ToothView(tooth: teeth[index])
                        .onTapGesture {
                            selectedToothIndex = (arch: arch, index: index)
                            showConditionPicker = true
                        }
                }
            }

            HStack(spacing: 4) {
                ForEach(teeth) { tooth in
                    Text(tooth.number)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 32)
                }
            }
        }
    }
}
