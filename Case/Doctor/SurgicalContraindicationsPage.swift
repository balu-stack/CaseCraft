//
//  SurgicalContraindicationsPage.swift
//  Case
//
//  Created by SAIL L1 on 23/02/26.
//


import SwiftUI

struct SurgicalContraindicationsPage: View {

    @EnvironmentObject private var form: CaseFormData

    var body: some View {
        VStack(spacing: 12) {

            GlassPanel {
                Text("Surgical / Extraction / Ortho")
                    .font(.headline)

                LabeledTextField("Surgical Contraindications*", text: $form.surgicalContraindications)
                LabeledTextField("Teeth Indicated for Extraction", text: $form.teethIndicatedForExtraction)
                LabeledTextField("Impacted Teeth + WAR Assessment*", text: $form.impactedTeethWar)
                LabeledTextField("Need for Orthognathic Surgery", text: $form.needForOrthognathicSurgery)
                LabeledTextField("Type of Orthognathic Correction(s) Required*", text: $form.typeOfOrthognathicCorrections)
                LabeledTextField("Growth or Swelling present", text: $form.growthOrSwellingPresent)

                Divider().opacity(0.25)

                LabeledTextField("Treatment Suggestions", text: $form.page3TreatmentSuggestions)
                LabeledTextField("Notes", text: $form.page3Notes)
            }
        }
    }
}