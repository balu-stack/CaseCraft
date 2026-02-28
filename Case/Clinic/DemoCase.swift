//
//  DemoCase.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// =======================================================
// 6) ClinicCasesView.swift  (View + Delete Cases)
// =======================================================

import SwiftUI

struct DemoCase: Identifiable, Hashable {
    let id: String
    let patientId: String
    let doctorId: String
    let status: String
    let updatedAt: String
}

struct ClinicCasesView: View {

    @State private var searchText = ""
    @State private var selectedStatus: String = "All"
    private let statuses = ["All", "Completed", "Draft", "In Progress"]

    @State private var cases: [DemoCase] = [
        .init(id: "CASE-1001", patientId: "P-10021", doctorId: "D-010", status: "Draft", updatedAt: "Today"),
        .init(id: "CASE-1002", patientId: "P-10022", doctorId: "D-011", status: "Completed", updatedAt: "Yesterday"),
        .init(id: "CASE-1003", patientId: "P-10023", doctorId: "D-012", status: "In Progress", updatedAt: "2 days ago")
    ]

    @State private var showDeleteConfirm = false
    @State private var pendingDelete: DemoCase? = nil

    private var filtered: [DemoCase] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cases.filter { c in
            let matchStatus = (selectedStatus == "All" || c.status == selectedStatus)
            let matchSearch = q.isEmpty ||
                c.id.lowercased().contains(q) ||
                c.patientId.lowercased().contains(q) ||
                c.doctorId.lowercased().contains(q)
            return matchStatus && matchSearch
        }
    }

    var body: some View {
        ZStack {
            CaseCraftBackground()

            VStack(spacing: 10) {
                searchBar
                statusChips

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if filtered.isEmpty {
                            ClinicGlassCard {
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 36))
                                        .foregroundStyle(.white.opacity(0.75))
                                    Text("No cases found")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("Try changing filters or search.")
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.75))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        } else {
                            ForEach(filtered) { c in
                                NavigationLink {
                                    ClinicCaseDetailView(caseItem: c)
                                } label: {
                                    caseCard(c)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        pendingDelete = c
                                        showDeleteConfirm = true
                                    } label: {
                                        Label("Delete Case", systemImage: "trash.fill")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 26)
                }
            }
            .padding(.top, 10)
        }
        .navigationTitle("Cases")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete case?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let del = pendingDelete {
                    cases.removeAll { $0.id == del.id }
                }
                pendingDelete = nil
            }
            Button("Cancel", role: .cancel) { pendingDelete = nil }
        } message: {
            Text("This will remove the case documentation permanently.")
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.8))

            TextField("Search Case/Patient/Doctor ID", text: $searchText)
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

    private var statusChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(statuses, id: \.self) { s in
                    Button {
                        selectedStatus = s
                    } label: {
                        Text(s)
                            .font(.footnote.weight(selectedStatus == s ? .semibold : .regular))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedStatus == s ? .white.opacity(0.22) : .white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
    }

    private func caseCard(_ c: DemoCase) -> some View {
        ClinicGlassCard {
            HStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(c.id).font(.headline).foregroundStyle(.white)
                    Text("Patient: \(c.patientId)  •  Doctor: \(c.doctorId)")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                    Text("Updated: \(c.updatedAt)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Text(c.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}