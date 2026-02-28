//
//  ReviewDocumentView.swift
//  Case
//
//  Created by SAIL L1 on 26/02/26.
//


import SwiftUI

struct ReviewDocumentView: View {

    @EnvironmentObject private var form: CaseFormData
    @Environment(\.dismiss) private var dismiss

    @State private var pdfURL: URL? = nil
    @State private var showShare = false
    @State private var showPdfError = false
    @State private var pdfErrorMsg = ""

    var body: some View {
        ZStack {
            CaseCraftBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    // Document card (aligned)
                    documentCard

                    // Actions
                    // Actions
                    HStack(spacing: 12) {

                        // EDIT BUTTON
                        Button {
                            dismiss()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white.opacity(0.14))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }


                        // DOWNLOAD PDF BUTTON
                        Button {

                            if let url = CasePDFExporter.export(form: form) {

                                pdfURL = url
                                showShare = true

                            } else {

                                pdfErrorMsg = "PDF generation failed. Please try again."
                                showPdfError = true
                            }

                        } label: {
                            Label("Download PDF", systemImage: "arrow.down.doc")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                .padding(.bottom, 26)
            }
        }
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShare) {

            if let url = pdfURL {
                ShareSheet(items: [url])
            }

        }
        .alert("PDF Error", isPresented: $showPdfError) {

            Button("OK", role: .cancel) {}

        } message: {

            Text(pdfErrorMsg)

        }
    }

    private var documentCard: some View {
        ClinicGlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Case Documentation")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Divider().opacity(0.25)

                docSection("Case History") {
                    docRow("Chief Complaint", form.chiefComplaint)
                    docRow("Presenting Illness", form.presentingIllness)
                    docRow("Past Medical History", form.pastMedicalHistory)
                    docRow("Medication", form.medication)
                }

                docSection("Dental / Treatment") {
                    docRow("Treatment Suggestions", form.treatmentSuggestions)
                    docRow("Notes", form.treatmentNotes)
                }

                docSection("Ortho Assessment") {
                    docRow("Head Shape", form.headShape)
                    docRow("Face Shape", form.faceShape)
                    docRow("Arch Shape", form.archShape)
                    docRow("Palatal Vault", form.palatalVault)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func docSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.top, 6)
            content()
        }
    }

    private func docRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.75))
            Text(value.isEmpty ? "-" : value)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider().opacity(0.15)
        }
    }
}
