//
//  DoctorCaseStartEntryView.swift
//  Case
//
//  Created by SAIL L1 on 23/02/26.
//


import SwiftUI

struct DoctorCaseStartEntryView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var patientId = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                Text("Start Documentation")
                    .font(.title2.bold())

                TextField("Enter Patient ID", text: $patientId)
                    .textInputAutocapitalization(.characters)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                NavigationLink {
                    DoctorCaseFlowRootView(patientId: patientId)
                } label: {
                    Text("Verify & Continue")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(patientId.isEmpty)

                Spacer()
            }
            .padding()
            .navigationTitle("New Case")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}