import SwiftUI

// MARK: - DATA MODEL (All form fields in one place)


final class CaseFormData: ObservableObject {

    // Page 1: Case History + Habits
    @Published var chiefComplaint = ""
    @Published var presentingIllness = ""
    @Published var pastMedicalHistory = ""
    @Published var medication = ""

    @Published var diet: DietType = .veg
    @Published var smoking: YesNo = .no
    @Published var panChewing: YesNo = .no
    @Published var gutkha: YesNo = .no
    @Published var thumbChewing: YesNo = .no
    @Published var tongueThrusting: YesNo = .no
    @Published var nailBiting: YesNo = .no
    @Published var lipBiting: YesNo = .no
    @Published var mouthBreathing: YesNo = .no

    // Page 2: Dental Status + Treatment/Notes
    @Published var treatmentSuggestions = ""
    @Published var treatmentNotes = ""

    // Page 3: Surgical / Extraction / WAR / Ortho
    @Published var surgicalContraindications = ""
    @Published var teethIndicatedForExtraction = ""
    @Published var impactedTeethWar = ""
    @Published var needForOrthognathicSurgery = ""
    @Published var typeOfOrthognathicCorrections = ""
    @Published var growthOrSwellingPresent = ""
    @Published var page3TreatmentSuggestions = ""
    @Published var page3Notes = ""

    // Page 4: Missing teeth / PDI
    @Published var missingTeeth = ""
    @Published var edentulousness = ""
    @Published var acpPdiClassification = ""
    @Published var abutmentAdjunctTherapy = ""
    @Published var abutmentInadequateToothStructure = ""
    @Published var occlusalEvaluation = ""
    @Published var classIVVariant = ""
    @Published var siebertsClassification = ""
    @Published var fullMouthRehabRequired = ""

    // Page 5: Ortho style fields (based on screenshot)
    @Published var headShape = ""
    @Published var faceShape = ""
    @Published var archShape = ""
    @Published var palatalVault = ""
    @Published var dentalMalocclusion = ""
    @Published var skeletalMalocclusion = ""
    @Published var chinProminence = ""
    @Published var nasolabialAngle = ""
    @Published var lipExamination = ""
    @Published var maxillaFeatures = ""
    @Published var mandibleFeatures = ""
    @Published var interarchRelation = ""
    @Published var individualToothVariations = ""

    // Page 6: Periodontal chart (placeholder values)
    @Published var perioNotes = ""

    // Page 7: Soft tissue exam + frenum classes
    @Published var facialForm = ""
    @Published var profileForm = ""
    @Published var salivaryGland = ""
    @Published var tmJoint = ""
    @Published var cervicalLymphNodes = ""
    @Published var others = ""

    @Published var lip = ""
    @Published var gingiva = ""
    @Published var alveolarMucosa = ""
    @Published var labialBuccalMucosa = ""
    @Published var tongue = ""
    @Published var floorOfMouth = ""
    @Published var palate = "Normal Class I"
    @Published var oroPharynx = ""

    @Published var labialFrenumUpper: FrenumClass = .classI
    @Published var labialFrenumLower: FrenumClass = .classI
    @Published var buccalFrenumUpperLeft: FrenumClass = .classI
    @Published var buccalFrenumUpperRight: FrenumClass = .classI
    @Published var buccalFrenumLowerLeft: FrenumClass = .classI
    @Published var buccalFrenumLowerRight: FrenumClass = .classI

    @Published var lingualFrenum = ""
}

// MARK: - Common Enums

enum YesNo: String, CaseIterable, Identifiable {
    case yes = "Yes"
    case no  = "No"
    var id: String { rawValue }
}

enum DietType: String, CaseIterable, Identifiable {
    case veg = "Veg"
    case nonVeg = "Non Veg"
    var id: String { rawValue }
}

enum FrenumClass: String, CaseIterable, Identifiable {
    case classI = "Class I"
    case classII = "Class II"
    case classIII = "Class III"
    var id: String { rawValue }
}

// MARK: - FLOW ROOT (This is what you push after selecting Manual/Speech)

enum EntryMode { case manual, speech }



// MARK: - MANUAL FLOW (Next/Back)

struct ManualCaseFlowView: View {
    
    @EnvironmentObject private var form: CaseFormData
    @State private var showMissingAlert = false
    @State private var missingFields: [String] = []
    @State private var goToReview = false
    let patientId: String
    
    enum Page: Int, CaseIterable, Identifiable {
        case caseHistoryHabits
        case dentalStatus
        case surgical
        case missingTeethPdi
        case orthoAssessment
        case periodontal
        case softTissue
        
        var id: Int { rawValue }
        
        var title: String {
            switch self {
            case .caseHistoryHabits: return "Case History"
            case .dentalStatus:      return "Dental Status"
            case .surgical:          return "Surgical"
            case .missingTeethPdi:   return "PDI / Missing Teeth"
            case .orthoAssessment:   return "Ortho Assessment"
            case .periodontal:       return "Periodontal"
            case .softTissue:        return "Soft Tissue"
            }
        }
    }
    
    @State private var page: Page = .caseHistoryHabits
    
    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    switch page {
                    case .caseHistoryHabits:
                        CaseHistoryHabitsPage()
                        
                    case .dentalStatus:
                        DentalStatusPage()
                        
                    case .surgical:
                        SurgicalContraindicationsPage()
                        
                    case .missingTeethPdi:
                        MissingTeethPDIPage()
                        
                    case .orthoAssessment:
                        OrthoAssessmentPage()
                        
                    case .periodontal:
                        PeriodontalChartPage()
                        
                    case .softTissue:
                        SoftTissueExamPage()
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(16)
                .padding(.bottom, 20)
            }
            
            navBar
        }
        .navigationTitle("Manual • \(page.title)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var progressHeader: some View {
        let idx = page.rawValue + 1
        let total = Page.allCases.count
        return VStack(spacing: 8) {
            HStack {
                Text("Patient: \(patientId)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(idx)/\(total)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            
            ProgressView(value: Double(idx), total: Double(total))
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.thinMaterial)
    }
    
    private var navBar: some View {
        HStack(spacing: 12) {
            
            // BACK BUTTON
            Button {
                goBack()
            } label: {
                Text("Back")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(page == .caseHistoryHabits)
            .opacity(page == .caseHistoryHabits ? 0.5 : 1)
            
            
            // NEXT / FINISH BUTTON
            Button {
                nextOrFinish()
            } label: {
                Text(page == .softTissue ? "Finish" : "Next")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(16)
        .background(.thinMaterial)
        
        // Missing fields alert
        .alert("Missing Required Fields",
               isPresented: $showMissingAlert) {
            
            Button("OK", role: .cancel) {}
            
        } message: {
            
            Text(
                missingFields.isEmpty
                ? "Please fill required fields"
                : missingFields.joined(separator: "\n")
            )
        }
        
        // Navigate to Review Page
        .navigationDestination(isPresented: $goToReview) {
            
            ReviewDocumentView()
                .environmentObject(form)
        }
    }
    
    
    // MARK: - BACK
    
    private func goBack() {
        
        guard let prev = Page(rawValue: page.rawValue - 1) else { return }
        
        page = prev
    }
    
    
    // MARK: - NEXT OR FINISH
    
    private func nextOrFinish() {
        
        // If last page → finish
        if page == .softTissue {
            
            missingFields = form.missingRequiredFields
            
            if missingFields.isEmpty {
                
                // All fields filled → go to review page
                goToReview = true
                
            } else {
                
                // Show missing alert
                showMissingAlert = true
            }
            
        } else {
            
            // Normal next page
            goNext()
        }
    }
    
    
    // MARK: - NEXT
    
    private func goNext() {
        
        guard let next = Page(rawValue: page.rawValue + 1) else { return }
        
        page = next
    }
}
// MARK: - SPEECH FLOW (Status list + open any page)

