//
//  CasePDFExporter.swift
//  Case
//
//  Created by SAIL L1 on 26/02/26.
//


import UIKit

enum CasePDFExporter {

    static func export(form: CaseFormData) -> URL? {

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4-ish points
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()

            var y: CGFloat = 36
            func draw(_ text: String, font: UIFont, spacing: CGFloat = 10) {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font
                ]
                let rect = CGRect(x: 36, y: y, width: pageRect.width - 72, height: 1000)
                let h = text.boundingRect(with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                                         options: [.usesLineFragmentOrigin, .usesFontLeading],
                                         attributes: attrs,
                                         context: nil).height
                text.draw(in: CGRect(x: 36, y: y, width: rect.width, height: h), withAttributes: attrs)
                y += h + spacing
            }

            draw("Case Documentation", font: .boldSystemFont(ofSize: 20), spacing: 18)

            draw("Case History", font: .boldSystemFont(ofSize: 14), spacing: 8)
            draw("Chief Complaint: \(safe(form.chiefComplaint))", font: .systemFont(ofSize: 12))
            draw("Presenting Illness: \(safe(form.presentingIllness))", font: .systemFont(ofSize: 12))
            draw("Past Medical History: \(safe(form.pastMedicalHistory))", font: .systemFont(ofSize: 12))
            draw("Medication: \(safe(form.medication))", font: .systemFont(ofSize: 12), spacing: 14)

            draw("Ortho Assessment", font: .boldSystemFont(ofSize: 14), spacing: 8)
            draw("Head Shape: \(safe(form.headShape))", font: .systemFont(ofSize: 12))
            draw("Face Shape: \(safe(form.faceShape))", font: .systemFont(ofSize: 12))
            draw("Arch Shape: \(safe(form.archShape))", font: .systemFont(ofSize: 12))
            draw("Palatal Vault: \(safe(form.palatalVault))", font: .systemFont(ofSize: 12))
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("CaseCraft-\(UUID().uuidString.prefix(6)).pdf")

        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func safe(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "-" : t
    }
}