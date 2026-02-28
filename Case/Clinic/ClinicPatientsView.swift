//
//  ClinicPatientsView.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// =======================================================
// 4) ClinicPatientsView.swift  (Patients Tab)
// =======================================================

import SwiftUI

struct ClinicPatientsView: View {

    // Demo patient list (replace with API later)
    @State private var searchText = ""
    @State private var patients: [DemoPatient] = [
        .init(id: "P-10021", name: "Arun Kumar", phone: "9876543210"),
        .init(id: "P-10022", name: "Meena", phone: "9123456780"),
        .init(id: "P-10023", name: "Rahul", phone: "9988776655")
    ]

    var filtered: [DemoPatient] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return patients }
        return patients.filter {
            $0.id.lowercased().contains(q) ||
            $0.name.lowercased().contains(q) ||
            $0.phone.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            CaseCraftBackground()

            VStack(spacing: 12) {
                searchBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {

                        NavigationLink {
                            GeneratePatientIDView()
                        } label: {
                            ClinicActionRow(
                                icon: "person.badge.plus",
                                title: "Generate Patient ID",
                                subtitle: "Add new patient to your clinic"
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        ClinicGlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Patients")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                if filtered.isEmpty {
                                    Text("No patients found.")
                                        .foregroundStyle(.white.opacity(0.75))
                                        .font(.footnote)
                                } else {
                                    ForEach(filtered) { p in
                                        NavigationLink {
                                            ClinicPatientDetailView(patient: p)
                                        } label: {
                                            patientRow(p)
                                        }
                                        .buttonStyle(.plain)

                                        if p.id != filtered.last?.id {
                                            Divider().opacity(0.25)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 26)
                }
            }
            .padding(.top, 10)
        }
        .navigationTitle("Patients")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.8))

            TextField("Search by ID / name / phone", text: $searchText)
                .foregroundStyle(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(12)
        .background(.white.opacity(0.14))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private func patientRow(_ p: DemoPatient) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(p.name).font(.headline).foregroundStyle(.white)
                Text("ID: \(p.id)  •  \(p.phone)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.vertical, 8)
    }
}

struct DemoPatient: Identifiable, Hashable {
    let id: String
    let name: String
    let phone: String
}

struct ClinicPatientDetailView: View {
    let patient: DemoPatient
    @State private var showDelete = false

    var body: some View {
        ZStack {
            CaseCraftBackground()
            VStack(spacing: 14) {
                ClinicGlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(patient.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Patient ID: \(patient.id)")
                            .foregroundStyle(.white.opacity(0.75))

                        Text("Phone: \(patient.phone)")
                            .foregroundStyle(.white.opacity(0.75))

                        Button {
                            UIPasteboard.general.string = patient.id
                        } label: {
                            Label("Copy Patient ID", systemImage: "doc.on.doc")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.black)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                }

                Button(role: .destructive) {
                    showDelete = true
                } label: {
                    Text("Delete Patient")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.22))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Patient")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete patient?", isPresented: $showDelete) {
            Button("Delete", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the patient from your clinic database.")
        }
    }
}