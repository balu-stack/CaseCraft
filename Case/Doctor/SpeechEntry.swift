//
//  SpeechEntry.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//
import SwiftUI

struct SpeechCaseFlowView: View {
    
    let patientId: String
    @EnvironmentObject private var form: CaseFormData
    @StateObject private var asr = SpeechRecognizer()

    enum SpeechPage: String, CaseIterable, Identifiable {
        case caseHistory = "Case History"
        case dentalStatus = "Dental Status"
        case surgical = "Surgical"
        case pdi = "PDI / Missing Teeth"
        case ortho = "Ortho Assessment"
        case perio = "Periodontal"
        case softTissue = "Soft Tissue"
        var id: String { rawValue }
    }

    @State private var selected: SpeechPage? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {

                GlassPanel {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Speech Mode")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    Text("Patient: \(patientId)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task {
                        if asr.isRecording {
                            await asr.stop()
                        } else {
                            await asr.start()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: asr.isRecording ? "stop.circle.fill" : "waveform")
                        Text(asr.isRecording ? "Stop Recording" : "Start Recording")
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                VStack(spacing: 10) {
                    ForEach(SpeechPage.allCases) { p in
                        Button {
                            selected = p
                        } label: {
                            HStack {
                                Text(p.rawValue)
                                    .font(.headline)
                                Spacer()
                                StatusPill(text: "Pending", tint: .orange) // hook to real status later
                            }
                            .padding(14)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(16)
        }
        .navigationTitle("Speech")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selected) { page in
            // Open pages for editing
            switch page {
            case .caseHistory: CaseHistoryHabitsPage().navigationTitle(page.rawValue)
            case .dentalStatus: DentalStatusPage().navigationTitle(page.rawValue)
            case .surgical: SurgicalContraindicationsPage().navigationTitle(page.rawValue)
            case .pdi: MissingTeethPDIPage().navigationTitle(page.rawValue)
            case .ortho: OrthoAssessmentPage().navigationTitle(page.rawValue)
            case .perio: PeriodontalChartPage().navigationTitle(page.rawValue)
            case .softTissue: SoftTissueExamPage().navigationTitle(page.rawValue)
            }
        }
    }
}

// MARK: - PAGE 1 (Case History + Habits)

struct CaseHistoryHabitsPage: View {

    @EnvironmentObject private var form: CaseFormData

    var body: some View {
        VStack(spacing: 12) {

            GlassPanel {
                Text("Medical Alert / Case History")
                    .font(.headline)

                LabeledTextEditor("Chief Complaint", text: $form.chiefComplaint, height: 90)
                LabeledTextEditor("History of Presenting Illness", text: $form.presentingIllness, height: 90)
                LabeledTextEditor("Past Medical History", text: $form.pastMedicalHistory, height: 70)
                LabeledTextEditor("Medication", text: $form.medication, height: 70)
            }

            GlassPanel {
                Text("Habits")
                    .font(.headline)

                HStack {
                    Text("Diet").frame(width: 120, alignment: .leading)
                    Spacer()
                    SegmentedPicker(items: DietType.allCases.map { $0.rawValue },
                                    selected: Binding(
                                        get: { form.diet.rawValue },
                                        set: { form.diet = DietType(rawValue: $0) ?? .veg }
                                    ))
                }

                YesNoRow(title: "Smoking", value: $form.smoking)
                YesNoRow(title: "Pan chewing", value: $form.panChewing)
                YesNoRow(title: "Gutkha", value: $form.gutkha)
                YesNoRow(title: "Thumb chewing", value: $form.thumbChewing)
                YesNoRow(title: "Tongue thrusting", value: $form.tongueThrusting)
                YesNoRow(title: "Nail biting", value: $form.nailBiting)
                YesNoRow(title: "Lip biting", value: $form.lipBiting)
                YesNoRow(title: "Mouth breathing", value: $form.mouthBreathing)
            }
        }
    }
}

// MARK: - PAGE 2 (Dental Status + Treatment/Notes)

struct DentalStatusPage: View {

    @EnvironmentObject private var form: CaseFormData

    @State private var upperTeeth: [Tooth] = [
        "18","17","16","15","14","13","12","11",
        "21","22","23","24","25","26","27","28"
    ].map { Tooth(number: $0) }

    @State private var lowerTeeth: [Tooth] = [
        "48","47","46","45","44","43","42","41",
        "31","32","33","34","35","36","37","38"
    ].map { Tooth(number: $0) }

    @State private var selectedToothIndex: (arch: String, index: Int)? = nil
    @State private var showConditionPicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                // MARK: - Dental Status Panel
                GlassPanel {
                    VStack(spacing: 16) {

                        Text("Dental Status")
                            .font(.headline)

                        // ✅ Centered + Scrollable
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack(spacing: 18) {

                                ArchView(
                                    teeth: $upperTeeth,
                                    arch: "upper",
                                    selectedToothIndex: $selectedToothIndex,
                                    showConditionPicker: $showConditionPicker
                                )

                                Divider().opacity(0.3)

                                ArchView(
                                    teeth: $lowerTeeth,
                                    arch: "lower",
                                    selectedToothIndex: $selectedToothIndex,
                                    showConditionPicker: $showConditionPicker
                                )
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                }

                // MARK: - Treatment Panel
                GlassPanel {
                    Text("Treatment / Notes")
                        .font(.headline)

                    LabeledTextEditor("Treatment Suggestions",
                                      text: $form.treatmentSuggestions,
                                      height: 90)

                    LabeledTextEditor("Notes",
                                      text: $form.treatmentNotes,
                                      height: 90)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showConditionPicker) {
            ConditionPickerSheet { condition in
                if let selected = selectedToothIndex {
                    if selected.arch == "upper" {
                        upperTeeth[selected.index].condition = condition
                    } else {
                        lowerTeeth[selected.index].condition = condition
                    }
                }
                showConditionPicker = false
            }
        }
    }
}

// MARK: - PAGE 3 (Surgical Contraindications etc.)


// MARK: - PAGE 4 (Missing Teeth + PDI)

struct MissingTeethPDIPage: View {

    @EnvironmentObject private var form: CaseFormData

    var body: some View {
        VStack(spacing: 12) {

            GlassPanel {
                Text("Missing Teeth / PDI")
                    .font(.headline)

                LabeledTextField("Missing Teeth*", text: $form.missingTeeth)
                LabeledTextField("Edentulousness", text: $form.edentulousness)

                LabeledTextField("ACP PDI Classification*", text: $form.acpPdiClassification)
                LabeledTextField("Abutment Evaluation - Adjunct Therapy*", text: $form.abutmentAdjunctTherapy)
                LabeledTextField("Abutment Evaluation - Inadequate Tooth Structure*", text: $form.abutmentInadequateToothStructure)
                LabeledTextField("Occlusal Evaluation", text: $form.occlusalEvaluation)
                LabeledTextField("Class IV Variant - Guarded Prognosis", text: $form.classIVVariant)
                LabeledTextField("Sieberts Edentulous Ridge Classifications", text: $form.siebertsClassification)
                LabeledTextField("Full Mouth Rehabilitation Required", text: $form.fullMouthRehabRequired)
            }
        }
    }
}

// MARK: - PAGE 5 (Ortho Assessment fields)

struct OrthoAssessmentPage: View {

    @EnvironmentObject private var form: CaseFormData

    var body: some View {
        VStack(spacing: 12) {

            GlassPanel {
                Text("Ortho Assessment")
                    .font(.headline)

                LabeledTextField("Head Shape*", text: $form.headShape)
                LabeledTextField("Face Shape*", text: $form.faceShape)
                LabeledTextField("Arch Shape*", text: $form.archShape)
                LabeledTextField("Palatal Vault*", text: $form.palatalVault)
                LabeledTextField("Dental Malocclusion*", text: $form.dentalMalocclusion)
                LabeledTextField("Skeletal Malocclusion", text: $form.skeletalMalocclusion)
                LabeledTextField("Chin Prominence", text: $form.chinProminence)
                LabeledTextField("Nasolabial Angle", text: $form.nasolabialAngle)
                LabeledTextField("Lip Examination", text: $form.lipExamination)
                LabeledTextField("Malocclusion features - Maxilla", text: $form.maxillaFeatures)
                LabeledTextField("Malocclusion features - Mandible", text: $form.mandibleFeatures)
                LabeledTextField("Interarch Relation", text: $form.interarchRelation)
                LabeledTextField("Individual Tooth Variations", text: $form.individualToothVariations)
            }
        }
    }
}

// MARK: - PAGE 6 (Periodontal chart placeholder)

struct PeriodontalChartPage: View {

    @EnvironmentObject private var form: CaseFormData

    private let teeth = ["18","17","16","15","14","13","12","11","21","22","23","24","25","26","27","28"]

    var body: some View {
        VStack(spacing: 12) {

            GlassPanel {
                Text("Periodontal Chart")
                    .font(.headline)

                // Simple grid placeholder similar to screenshot
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 10) {
                        PerioRow(label: "FUR", teeth: teeth)
                        PerioRow(label: "MOB", teeth: teeth)
                        PerioRow(label: "BOP", teeth: teeth)
                        PerioRow(label: "CAL", teeth: teeth)
                        PerioRow(label: "PD",  teeth: teeth)

                        Divider().opacity(0.25)

                        PerioRow(label: "PD",  teeth: teeth)
                        PerioRow(label: "CAL", teeth: teeth)
                        PerioRow(label: "BOP", teeth: teeth)
                        PerioRow(label: "MOB", teeth: teeth)
                        PerioRow(label: "FUR", teeth: teeth)
                    }
                    .padding(.vertical, 8)
                }

                LabeledTextEditor("Notes", text: $form.perioNotes, height: 90)
            }
        }
    }
}

struct PerioRow: View {
    let label: String
    let teeth: [String]

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .frame(width: 44, alignment: .leading)
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(teeth, id: \.self) { t in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.gray.opacity(0.10))
                        .frame(width: 42, height: 28)
                        .overlay(
                            Text("")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        )
                }
            }
        }
    }
}

// MARK: - PAGE 7 (Soft tissue + frenum)

struct SoftTissueExamPage: View {

    @EnvironmentObject private var form: CaseFormData

    private let palateOptions = ["Normal Class I", "High Arched", "Shallow", "Other"]

    var body: some View {
        VStack(spacing: 12) {

            GlassPanel {
                Text("Extra Oral Examination")
                    .font(.headline)

                TwoColFields(
                    leftTitle: "Facial Form", leftText: $form.facialForm,
                    rightTitle: "Profile Form", rightText: $form.profileForm
                )
                TwoColFields(
                    leftTitle: "Salivary Gland", leftText: $form.salivaryGland,
                    rightTitle: "Temporomandibular Joint", rightText: $form.tmJoint
                )
                TwoColFields(
                    leftTitle: "Cervical Lymph Nodes", leftText: $form.cervicalLymphNodes,
                    rightTitle: "Others", rightText: $form.others
                )
            }

            GlassPanel {
                Text("Intra Oral Soft Tissue Examination")
                    .font(.headline)

                TwoColFields(
                    leftTitle: "Lip", leftText: $form.lip,
                    rightTitle: "Gingiva", rightText: $form.gingiva
                )
                TwoColFields(
                    leftTitle: "Alveolar Mucosa", leftText: $form.alveolarMucosa,
                    rightTitle: "Labial / Buccal Mucosa", rightText: $form.labialBuccalMucosa
                )
                TwoColFields(
                    leftTitle: "Tongue", leftText: $form.tongue,
                    rightTitle: "Floor of the mouth", rightText: $form.floorOfMouth
                )

                // Palate dropdown like screenshot
                VStack(alignment: .leading, spacing: 6) {
                    Text("Palate")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Picker("Palate", selection: $form.palate) {
                        ForEach(palateOptions, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                LabeledTextField("Oro Pharynx", text: $form.oroPharynx)

                Divider().opacity(0.25)

                Text("Frenum Classification")
                    .font(.headline)

                FrenumRow(title: "Labial Frenum Upper", value: $form.labialFrenumUpper)
                FrenumRow(title: "Labial Frenum Lower", value: $form.labialFrenumLower)
                FrenumRow(title: "Buccal Frenum Upper Left", value: $form.buccalFrenumUpperLeft)
                FrenumRow(title: "Buccal Frenum Upper Right", value: $form.buccalFrenumUpperRight)
                FrenumRow(title: "Buccal Frenum Lower Left", value: $form.buccalFrenumLowerLeft)
                FrenumRow(title: "Buccal Frenum Lower Right", value: $form.buccalFrenumLowerRight)

                LabeledTextField("Lingual Frenum", text: $form.lingualFrenum)
            }
        }
    }
}

// MARK: - Reusable UI components



struct LabeledTextField: View {
    let title: String
    @Binding var text: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: $text)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled(false)
                .padding()
                .background(Color.gray.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

struct LabeledTextEditor: View {
    let title: String
    @Binding var text: String
    let height: CGFloat

    init(_ title: String, text: Binding<String>, height: CGFloat) {
        self.title = title
        self._text = text
        self.height = height
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            TextEditor(text: $text)
                .frame(height: height)
                .padding(10)
                .background(Color.gray.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

struct YesNoRow: View {
    let title: String
    @Binding var value: YesNo

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 140, alignment: .leading)
                .foregroundStyle(.secondary)

            Spacer()

            RadioPill(label: "Yes", isOn: value == .yes) { value = .yes }
            RadioPill(label: "No", isOn: value == .no) { value = .no }
        }
    }
}

struct FrenumRow: View {
    let title: String
    @Binding var value: FrenumClass

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 190, alignment: .leading)
                .foregroundStyle(.secondary)

            Spacer()

            ForEach(FrenumClass.allCases) { c in
                RadioPill(label: c.rawValue, isOn: value == c) { value = c }
            }
        }
        .font(.subheadline)
    }
}

struct RadioPill: View {
    let label: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isOn ? "largecircle.fill.circle" : "circle")
                Text(label)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isOn ? Color.accentColor : Color.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isOn ? Color.accentColor.opacity(0.12) : Color.gray.opacity(0.10))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct SegmentedPicker: View {
    let items: [String]
    @Binding var selected: String

    init(items: [String], selected: Binding<String>) {
        self.items = items
        self._selected = selected
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { it in
                Button {
                    selected = it
                } label: {
                    Text(it)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selected == it ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.10))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TwoColFields: View {
    let leftTitle: String
    @Binding var leftText: String
    let rightTitle: String
    @Binding var rightText: String

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(leftTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(leftTitle, text: $leftText)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(rightTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField(rightTitle, text: $rightText)
                    .padding()
                    .background(Color.gray.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}
