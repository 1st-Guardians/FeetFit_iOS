//
//  ProfileEditView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: MyPageViewModel
    @State private var userInfo: UserInfo
    
    @FocusState private var focusedField: Field?
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        _userInfo = State(initialValue: viewModel.userInfo)
    }
    
    enum Field {
        case nickname
        case age
        case height
        case weight
        case footSize
    }
    
    var body: some View {
        VStack {
            HeaderGroup
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    TopInputField
                        .padding(.top, 30)
                        .padding(.bottom, 32)
                    
                    BottomInputField
                        .padding(.bottom, 32)
                    
                    GenderGroup
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray03)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            userInfo = viewModel.userInfo
        }
    }
    
    var HeaderGroup: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(.white)
                    .clipShape(Circle())
                    .mainBoxStyle()
            }
            
            Spacer()
            
            Text("프로필 수정")
                .pretendardFont(.BlockTitle)
            
            Spacer()
            
            Button {
                submitProfile()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.blue01)
                    .clipShape(Circle())
                    .mainBoxStyle()
            }
        }
    }
    
    var TopInputField: some View {
        VStack(spacing: 0) {
            OnboardingTextField(
                placeholder: "닉네임을 입력해주세요.",
                text: $userInfo.nickname,
                keyboardType: .default,
                field: .nickname,
                nextField: .age,
                focusedField: $focusedField
            )
            
            Divider()
            
            OnboardingTextField(
                placeholder: "나이를 입력해주세요.",
                text: $userInfo.age,
                keyboardType: .numberPad,
                field: .age,
                nextField: .height,
                focusedField: $focusedField
            )
        }
        .padding(.horizontal, 20
        )
        .background(.white)
        .mainBoxStyle()
    }
    
    var BottomInputField: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                UnitInputRow(
                    title: "키",
                    unit: "cm",
                    text: $userInfo.height,
                    field: .height,
                    nextField: .weight,
                    focusedField: $focusedField
                )
                
                Divider()
                
                UnitInputRow(
                    title: "몸무게",
                    unit: "kg",
                    text: $userInfo.weight,
                    field: .weight,
                    nextField: .footSize,
                    focusedField: $focusedField
                )
                
                Divider()
                
                UnitInputRow(
                    title: "평소 발 사이즈",
                    unit: "mm",
                    text: $userInfo.footSize,
                    field: .footSize,
                    nextField: nil,
                    focusedField: $focusedField
                )
            }
            .padding(.horizontal, 20)
            .background(.white)
            .mainBoxStyle()
            
        }
    }
    
    var GenderGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("성별")
                .pretendardFont(.SectionTitle)
                .padding(.bottom, 10)
            
            HStack(spacing: 14) {
                SelectButton(
                    title: "여자",
                    isSelected: userInfo.gender == .female
                ) {
                    userInfo.gender = .female
                }
                
                SelectButton(
                    title: "남자",
                    isSelected: userInfo.gender == .male
                ) {
                    userInfo.gender = .male
                }
            }
        }
    }
    
    private func submitProfile() {
        guard userInfo.isOnboardingFilled else {
            ToastManager.shared.show("입력되지 않은 값이 있습니다.")
            return
        }
        
        viewModel.updateProfile(
            nickname: userInfo.nickname,
            age: userInfo.age,
            height: userInfo.height,
            weight: userInfo.weight,
            footSize: userInfo.footSize,
            gender: userInfo.gender
        ) {
            dismiss()
        }
    }
}
