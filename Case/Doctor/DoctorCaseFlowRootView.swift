import SwiftUI

struct DoctorCaseFlowRootView: View {

    enum EntryMode { case manual, speech }

    let patientId: String
    @State private var mode: EntryMode? = nil

    var body: some View {
        VStack(spacing: 20) {

            Text("Choose Entry Mode")
                .font(.title2.bold())

            Button {
                mode = .manual
            } label: {
                Text("Manual Entry")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                mode = .speech
            } label: {
                Text("Speech Entry")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Mode")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $mode) { selected in
            switch selected {
            case .manual:
                DoctorCasePagesContainerView(
                    patientId: patientId,
                    mode: .manual
                )

            case .speech:
                DoctorCasePagesContainerView(
                    patientId: patientId,
                    mode: .speech
                )
            }
        }
    }
}

extension DoctorCaseFlowRootView.EntryMode: Identifiable {
    var id: Int {
        switch self {
        case .manual: return 1
        case .speech: return 2
        }
    }
}
