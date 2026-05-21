//
//  UnitInputRow.swift
//  FeetFit
//
//  Created by 이채은 on 5/21/26.
//

import SwiftUI
struct UnitInputRow<Field: Hashable>: View {
    let title: String
    let unit: String
    @Binding var text: String
    let field: Field
    let nextField: Field?

    @FocusState.Binding var focusedField: Field?

    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .padding(.leading, 8)
                .pretendardFont(.Placeholder)

            Spacer()

            TextField("", text: $text)
                .keyboardType(.numberPad)
                .pretendardFont(.Placeholder)
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: field)
                .autocorrectionDisabled(true)
                .submitLabel(nextField == nil ? .done : .next)
                .onSubmit {
                    focusedField = nextField
                }
                .padding(.vertical, 15)

            Text(unit)
                .pretendardFont(.Placeholder)
                .foregroundStyle(.black)
                .padding(.trailing, 8)
        }
    }
}
