//
//  ClinicCaseDetailView.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// =======================================================
// 7) ClinicCaseDetailView.swift  (Read-only + Delete button)
// =======================================================

import SwiftUI

struct ClinicCaseDetailView: View {
    let caseItem: DemoCase
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            CaseCraftBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    ClinicGlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(caseItem.id)
                                .font(.title2.bold())
                                .foregroundStyle(.white)

                            Text("Patient ID: \(caseItem.patientId)")
                                .foregroundStyle(.white.opacity(0.75))

                            Text("Doctor ID: \(caseItem.doctorId)")
                                .foregroundStyle(.white.opacity(0.75))

                            Text("Status: \(caseItem.status)")
                                .foregroundStyle(.white.opacity(0.75))

                            Text("Last Updated: \(caseItem.updatedAt)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.top, 4)
                        }
                    }

                    ClinicGlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pages Overview")
                                .font(.headline)
                                .foregroundStyle(.white)

                            pageRow("Page 1", filled: true)
                            Divider().opacity(0.25)
                            pageRow("Page 2", filled: false)
                            Divider().opacity(0.25)
                            pageRow("Page 3", filled: true)
                        }
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Text("Delete Case")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(.red.opacity(0.22))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationTitle("Case Detail")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete case?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the case documentation permanently.")
        }
    }

    private func pageRow(_ title: String, filled: Bool) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white)
            Spacer()
            Label(filled ? "Filled" : "Missing",
                  systemImage: filled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            .foregroundStyle(filled ? .green : .orange)
        }
        .font(.subheadline)
    }
}