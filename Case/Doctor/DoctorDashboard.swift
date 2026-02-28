import SwiftUI

// MARK: - MODEL

struct CaseItem: Identifiable, Hashable {
    let id = UUID()
    var patientId: String
    var title: String
    var date: String
    var status: CaseStatus
}

enum CaseStatus: String, CaseIterable, Identifiable {
    case completed = "Completed"
    case pending = "Pending"
    case inDraft = "In Draft"
    case inProgress = "In Progress"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .completed: return "checkmark.seal.fill"
        case .pending: return "clock.fill"
        case .inDraft: return "square.and.pencil"
        case .inProgress: return "bolt.fill"
        }
    }

    var tint: Color {
        switch self {
        case .completed: return .green
        case .pending: return .orange
        case .inDraft: return .blue
        case .inProgress: return .purple
        }
    }
}

// MARK: - ROOT: SIMPLE OLD TAB DESIGN
// ✅ Tabs: Home + Profile
// ✅ Cases page opens ONLY via "See all" inside Home
// ✅ Floating Plus button opens StartDocumentationView (same as old Start tab)
// ✅ Manual/Speech should navigate to respective flows

struct DoctorDashboardRootView: View {

    @State private var showStart = false

    var body: some View {
        NavigationStack {   // ✅ one main NavigationStack
            ZStack {
                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }

                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                }

                // ✅ Floating Plus Button
                VStack {
                    Spacer()
                    Button {
                        showStart = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 66, height: 66)
                                .shadow(color: .black.opacity(0.25),
                                        radius: 12, x: 0, y: 8)

                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -18)
                }
            }
            // ✅ Page navigation (NOT overlay)
            .navigationDestination(isPresented: $showStart) {
                StartDocumentationView()
            }
        }
    }
}

// MARK: - HOME (Recent cases + See all -> AllCasesView)

struct HomeView: View {

    @State private var recent: [CaseItem] = [
        .init(patientId: "P-1021", title: "Ortho Follow-up", date: "Today", status: .inProgress),
        .init(patientId: "P-0988", title: "Root Canal", date: "Yesterday", status: .completed),
        .init(patientId: "P-1104", title: "New Consultation", date: "20 Feb", status: .pending),
        .init(patientId: "P-0912", title: "Case Documentation", date: "19 Feb", status: .inDraft)
    ]

    private var totalCompleted: Int { recent.filter { $0.status == .completed }.count }
    private var totalPending: Int { recent.filter { $0.status == .pending || $0.status == .inProgress || $0.status == .inDraft }.count }
    private var totalCases: Int { recent.count }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    header
                    statsGrid
                    recentCasesSection

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome, Doctor")
                    .font(.title2.bold())
                Text("Quick look at your cases")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "stethoscope")
                .font(.title2)
                .foregroundStyle(.secondary)
                .padding(10)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
        .padding(.top, 6)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Total Cases", value: "\(totalCases)", icon: "doc.plaintext", tint: .cyan)
            StatCard(title: "Completed", value: "\(totalCompleted)", icon: "checkmark.seal.fill", tint: .green)
            StatCard(title: "Pending", value: "\(totalPending)", icon: "clock.fill", tint: .orange)
            StatCard(title: "In Draft",
                     value: "\(recent.filter { $0.status == .inDraft }.count)",
                     icon: "square.and.pencil",
                     tint: .blue)
        }
    }

    private var recentCasesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Cases")
                    .font(.headline)

                Spacer()

                NavigationLink {
                    AllCasesView()
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.semibold))
                }
            }

            VStack(spacing: 10) {
                ForEach(recent) { item in
                    NavigationLink {
                        CaseDetailView(item: item)
                    } label: {
                        CaseRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - ALL CASES PAGE (Open only via See all)

struct AllCasesView: View {

    @State private var allCases: [CaseItem] = [
        .init(patientId: "P-1021", title: "Ortho Follow-up", date: "Today", status: .inProgress),
        .init(patientId: "P-0988", title: "Root Canal", date: "Yesterday", status: .completed),
        .init(patientId: "P-1104", title: "New Consultation", date: "20 Feb", status: .pending),
        .init(patientId: "P-0912", title: "Case Documentation", date: "19 Feb", status: .inDraft),
        .init(patientId: "P-0777", title: "Braces Review", date: "18 Feb", status: .completed),
        .init(patientId: "P-0660", title: "Extraction Follow-up", date: "16 Feb", status: .completed),
        .init(patientId: "P-1200", title: "Pain Complaint", date: "15 Feb", status: .pending)
    ]

    @State private var query = ""
    @State private var filter: CaseStatus? = nil

    private var filtered: [CaseItem] {
        allCases.filter { item in
            let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesQuery = q.isEmpty ||
            item.patientId.lowercased().contains(q.lowercased()) ||
            item.title.lowercased().contains(q.lowercased())

            let matchesFilter = (filter == nil) || item.status == filter
            return matchesQuery && matchesFilter
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                searchBar
                filterChips

                VStack(spacing: 10) {
                    ForEach(filtered) { item in
                        NavigationLink {
                            CaseDetailView(item: item)
                        } label: {
                            CaseRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .navigationTitle("All Cases")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchBar: some View {
        GlassPanel {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search by Patient ID / Title", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: "All", isSelected: filter == nil) { filter = nil }
                ForEach(CaseStatus.allCases) { st in
                    chip(title: st.rawValue, isSelected: filter == st) { filter = st }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - START DOCUMENTATION (Opened by floating +)
// ✅ Modified: "Continue" now navigates to Manual/Speech flows (like old Start tab)

// MARK: - START DOCUMENTATION (Old flow)
// ✅ Step 1: Verify Patient ID screen
// ✅ Step 2: Bottom sheet popup -> choose Manual/Speech
// ✅ Step 3: Navigate to pages

import SwiftUI

import SwiftUI

struct StartDocumentationView: View {

    enum EntryMode: String, CaseIterable, Identifiable {
        case manual = "Manual"
        case speech = "Speech"
        var id: String { rawValue }
    }

    @State private var patientId = ""
    @State private var isChecking = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    @State private var patientVerified = false

    // bottom popup
    @State private var showModePicker = false
    @State private var selectedMode: EntryMode = .manual

    // navigation
    @State private var goNext = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Verify Patient ID")
                        .font(.title2.bold())
                    Text("Enter Patient ID to start documentation")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

                GlassPanel {
                    HStack(spacing: 10) {
                        Image(systemName: "person.text.rectangle")
                            .foregroundStyle(.secondary)

                        TextField("Patient ID (e.g., P-1021)", text: $patientId)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                    }
                }

                Button {
                    verifyPatient()
                } label: {
                    HStack(spacing: 10) {
                        if isChecking {
                            ProgressView()
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                        }

                        Text(isChecking ? "Verifying..." : "Verify")
                            .fontWeight(.bold)

                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding()
                    .background(patientId.isEmpty ? Color.gray.opacity(0.15) : Color.accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(patientId.isEmpty || isChecking)

                if patientVerified {
                    GlassPanel {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Text("Patient Verified")
                                .fontWeight(.semibold)
                            Spacer()
                            Text(patientId)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Start")
        .navigationBarTitleDisplayMode(.inline)

        // Bottom popup sheet after verify
        .sheet(isPresented: $showModePicker) {
            ModePickerSheet(selectedMode: $selectedMode) {
                showModePicker = false
                goNext = true
            }
        }

        // Navigate to Manual/Speech
        .navigationDestination(isPresented: $goNext) {
            DoctorCasePagesContainerView(
                patientId: patientId,
                mode: selectedMode == .manual ? .manual : .speech
            )
        }

        .alert("CaseCraft", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
    }

    private func verifyPatient() {
        guard !patientId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isChecking = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isChecking = false

            if patientId.uppercased().hasPrefix("P-") || patientId.uppercased().hasPrefix("P_") {
                patientVerified = true
                showModePicker = true
            } else {
                alertMsg = "Patient ID not found. Please check and try again."
                showAlert = true
            }
        }
    }
}

struct SpeechCaseStatusView: View {
    let patientId: String
    var body: some View {
        VStack(spacing: 12) {
            Text("Speech Flow")
                .font(.title2.bold())
            Text("Patient ID: \(patientId)")
                .foregroundStyle(.secondary)
            Text("Add your status list + speech recording here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .navigationTitle("Speech")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - PROFILE

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject private var appState: AppState   // ✅ use AppState

    var body: some View {

        // ❌ Remove NavigationStack here (RootView controls screens)
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {

                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.secondary)

                    Text("Doctor Profile")
                        .font(.title2.bold())

                    Text("Manage details & settings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 18)

                GlassPanel {
                    ProfileRow(icon: "person.fill", title: "Name", value: "Dr. Balaji")
                    Divider().opacity(0.3)
                    ProfileRow(icon: "phone.fill", title: "Phone", value: "+91 XXXXX XXXXX")
                    Divider().opacity(0.3)
                    ProfileRow(icon: "stethoscope", title: "Specialization", value: "Dentistry")
                }

                // Logout panel
                GlassPanel {
                    Button(role: .destructive) {
                        appState.screen = .landing   // ✅ go to Landing (no back)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 90)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .navigationTitle("Profile")
    }
}// MARK: - REUSABLE UI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Spacer()
            }

            Text(value)
                .font(.title2.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct CaseRow: View {
    let item: CaseItem

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(item.status.tint.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: item.status.icon)
                    .foregroundStyle(item.status.tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.headline)
                Text("\(item.patientId) • \(item.date)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusPill(text: item.status.rawValue, tint: item.status.tint)
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}



struct GlassPanel<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .padding(14)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 26)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                Text(value).font(.headline)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct CaseDetailView: View {
    let item: CaseItem

    var body: some View {
        VStack(spacing: 14) {
            CaseRow(item: item)
                .padding(.top, 14)

            GlassPanel {
                Text("Case Summary")
                    .font(.headline)
                Text("This is a placeholder details screen. Connect this to your documentation pages or backend.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .navigationTitle(item.patientId)
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct ModePickerSheet: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMode: StartDocumentationView.EntryMode
    var onContinue: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {

                Text("Choose Entry Mode")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 10) {
                    ForEach(StartDocumentationView.EntryMode.allCases) { m in
                        Button {
                            selectedMode = m
                        } label: {
                            HStack {
                                Image(systemName: m == .speech ? "mic.fill" : "square.and.pencil")
                                Text(m.rawValue)
                                    .fontWeight(.semibold)
                                Spacer()
                                if selectedMode == m {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
struct DoctorCasePagesContainerView: View {

    let patientId: String
    let mode: EntryMode

    @StateObject private var form = CaseFormData()

    var body: some View {
        Group {
            if mode == .manual {
                ManualCaseFlowView(patientId: patientId)
            } else {
                SpeechCaseFlowView(patientId: patientId)
            }
        }
        .environmentObject(form) // ✅ apply to both flows and all descendants
    }
}
struct StatusPill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(tint.opacity(0.16))
            .foregroundStyle(tint)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(tint.opacity(0.22), lineWidth: 1)
            )
    }
}


#Preview {
    DoctorDashboardRootView()
}
