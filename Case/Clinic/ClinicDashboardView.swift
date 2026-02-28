//
//  ClinicDashboardView.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


// =======================================================
// 3) ClinicDashboardView.swift  (Home)
// =======================================================

import SwiftUI

struct ClinicDashboardView: View {

    // Demo stats (replace with API later)
    private let totalPatients = 128
    private let totalCases = 256
    private let completed = 190
    private let drafts = 66

    private let grid = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            CaseCraftBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    header

                    LazyVGrid(columns: grid, spacing: 12) {
                        StatTile(title: "Patients", value: "\(totalPatients)", icon: "person.3.fill", tint: .cyan)
                        StatTile(title: "Cases", value: "\(totalCases)", icon: "doc.text.fill", tint: .blue)
                        StatTile(title: "Completed", value: "\(completed)", icon: "checkmark.seal.fill", tint: .green)
                        StatTile(title: "Drafts", value: "\(drafts)", icon: "square.and.pencil", tint: .orange)
                    }
                    .padding(.horizontal)

                    ClinicGlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .font(.headline)
                                .foregroundStyle(.white)

                            NavigationLink {
                                GeneratePatientIDView()
                            } label: {
                                ClinicActionRow(
                                    icon: "person.badge.plus",
                                    title: "Generate Patient ID",
                                    subtitle: "Create a patient profile in your clinic"
                                )
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                ClinicCasesView()
                            } label: {
                                ClinicActionRow(
                                    icon: "doc.text.magnifyingglass",
                                    title: "View Cases",
                                    subtitle: "See all cases & delete if needed"
                                )
                            }
                            .buttonStyle(.plain)
                            
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
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 14)
                .padding(.bottom, 26)
            }
        }
        .navigationTitle("Clinic Home")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome Back")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Manage patients and monitor case documentation.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal)
    }
}
