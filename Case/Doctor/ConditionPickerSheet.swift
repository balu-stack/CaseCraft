//
//  ConditionPickerSheet.swift
//  Case
//
//  Created by SAIL L1 on 23/02/26.
//
import SwiftUI

struct ConditionPickerSheet: View {

    var onSelect: (ToothCondition) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(ToothCondition.allCases, id: \.self) { condition in
                    Button(condition.rawValue.capitalized) {
                        onSelect(condition)
                    }
                }
            }
            .navigationTitle("Select Condition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
