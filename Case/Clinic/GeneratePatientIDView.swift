//
//  GeneratePatientIDView.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// =======================================================
// 5) GeneratePatientIDView.swift  (Create Patient + Generated ID UI)
// =======================================================

import SwiftUI

struct GeneratePatientIDView: View {

    @State private var name = ""
    @State private var phone = ""

    @State private var isSaving = false
    @State private var createdId: String? = nil
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        ZStack {
            CaseCraftBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    ClinicGlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("New Patient")
                                .font(.headline)
                                .foregroundStyle(.white)

                            TextField("Patient Name", text: $name)
                                .textInputAutocapitalization(.words)
                                .padding(12)
                                .background(.white.opacity(0.14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.18), lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                            TextField("Phone Number", text: $phone)
                                .keyboardType(.phonePad)
                                .padding(12)
                                .background(.white.opacity(0.14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.18), lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    if let id = createdId {
                        ClinicGlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Generated Patient ID")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.75))

                                HStack {
                                    Text(id)
                                        .font(.title3.bold())
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = id
                                        alertMsg = "Copied!"
                                        showAlert = true
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundStyle(.white)
                                            .padding(10)
                                            .background(.white.opacity(0.14))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        createPatient()
                    } label: {
                        HStack(spacing: 10) {
                            if isSaving { ProgressView().tint(.black) }
                            else { Image(systemName: "checkmark.seal.fill") }

                            Text(isSaving ? "Saving…" : "Save & Generate ID")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 10)
                    }
                    .disabled(!canSave || isSaving)
                    .opacity(!canSave ? 0.75 : 1)

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Generate Patient ID")
        .navigationBarTitleDisplayMode(.inline)
        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMsg)
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func createPatient() {
        isSaving = true
        createdId = nil

        // TODO: call backend -> returns patient_id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSaving = false
            createdId = "P-\(Int.random(in: 10000...99999))"
        }
    }
}