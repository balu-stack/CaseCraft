//
//  DemoDoctor.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


import SwiftUI

struct DemoDoctor: Identifiable, Hashable {
    let id: String
    let name: String
    let phone: String
    let specialization: String
    let active: Bool
}

struct ClinicDoctorsView: View {
    @State private var searchText = ""

    // Demo list (replace with API later)
    @State private var doctors: [DemoDoctor] = [
        .init(id: "D-1001", name: "Dr. Karthik", phone: "9000011111", specialization: "Orthodontist", active: true),
        .init(id: "D-1002", name: "Dr. Priya", phone: "9000022222", specialization: "General Dentist", active: true),
        .init(id: "D-1003", name: "Dr. Naveen", phone: "9000033333", specialization: "Oral Surgeon", active: false)
    ]

    var filtered: [DemoDoctor] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return doctors }
        return doctors.filter {
            $0.id.lowercased().contains(q) ||
            $0.name.lowercased().contains(q) ||
            $0.phone.lowercased().contains(q) ||
            $0.specialization.lowercased().contains(q)
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
                            AddDoctorView()
                        } label: {
                            ClinicActionRow(
                                icon: "stethoscope",
                                title: "Add Doctor",
                                subtitle: "Generate Doctor ID & Password"
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        ClinicGlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Doctors")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                if filtered.isEmpty {
                                    Text("No doctors found.")
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.75))
                                } else {
                                    ForEach(filtered) { d in
                                        NavigationLink {
                                            DoctorDetailView(doctor: d)
                                        } label: {
                                            doctorRow(d)
                                        }
                                        .buttonStyle(.plain)

                                        if d.id != filtered.last?.id { Divider().opacity(0.25) }
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
        .navigationTitle("Doctors")
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
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.18), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func doctorRow(_ d: DemoDoctor) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "stethoscope")
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(d.name).font(.headline).foregroundStyle(.white)
                Text("ID: \(d.id) • \(d.specialization)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
                Text("Phone: \(d.phone)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.70))
            }

            Spacer()

            Text(d.active ? "Active" : "Inactive")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((d.active ? Color.green : Color.orange).opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.vertical, 8)
    }
}

struct DoctorDetailView: View {
    let doctor: DemoDoctor
    @State private var showDelete = false

    var body: some View {
        ZStack {
            CaseCraftBackground()
            VStack(spacing: 14) {
                ClinicGlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(doctor.name)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("Doctor ID: \(doctor.id)")
                            .foregroundStyle(.white.opacity(0.75))
                        Text("Specialization: \(doctor.specialization)")
                            .foregroundStyle(.white.opacity(0.75))
                        Text("Phone: \(doctor.phone)")
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                Button(role: .destructive) { showDelete = true } label: {
                    Text("Delete Doctor")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red.opacity(0.22))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Doctor")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete doctor?", isPresented: $showDelete) {
            Button("Delete", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the doctor from your clinic database.")
        }
    }
}