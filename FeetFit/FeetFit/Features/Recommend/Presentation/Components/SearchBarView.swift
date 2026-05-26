//
//  SearchBarView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    
    let onTap: () -> Void
    let onClear: () -> Void
    let onSubmit: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            searchField
            if !text.isEmpty {
                clearButton
            }
        }
        .onChange(of: isFocused) { _, newValue in
            if newValue {
                onTap()
            }
        }
    }
    
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(.black)
            
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundStyle(.gray02)
            )
            .pretendardFont(.SectionTitle)
            .foregroundStyle(.black)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.search)
            .focused($isFocused)
            .onSubmit {
                onSubmit()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 16.5)
        .contentShape(Capsule())
        .onTapGesture {
            isFocused = true
            onTap()
        }
        .background {
            Capsule()
                .fill(.white.opacity(0.6))
                .background(.ultraThinMaterial, in: Capsule())
        }
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.7), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    private var clearButton: some View {
        Button {
            text = ""
            isFocused = false
            onClear()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 18))
                .foregroundStyle(.black)
                .frame(width: 48, height: 48)
                .background {
                    Circle()
                        .fill(.white.opacity(0.6))
                        .background(.ultraThinMaterial, in: Circle())
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchBarView(
        text: .constant("나이키"),
        placeholder: "신발을 검색해 보세요",
        onTap: {},
        onClear: {},
        onSubmit: {}
    )
    .padding()
    .background(.gray03)
}
