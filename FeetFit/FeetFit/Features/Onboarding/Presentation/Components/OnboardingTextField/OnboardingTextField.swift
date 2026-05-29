//
//  OnboardingTextField.swift
//  FeetFit
//
//  Created by 이채은 on 5/21/26.
//
import SwiftUI

struct OnboardingTextField<Field: Hashable>: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let field: Field
    let nextField: Field?

    @FocusState.Binding var focusedField: Field?

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundStyle(.gray02)
        )
        .keyboardType(keyboardType)
        .pretendardFont(.Placeholder)
        .textInputAutocapitalization(.never)
        .focused($focusedField, equals: field)
        .submitLabel(nextField == nil ? .done : .next)
        .onSubmit {
            focusedField = nextField
        }
        .autocorrectionDisabled(true)
        .padding(.vertical, 15)
    }
}
