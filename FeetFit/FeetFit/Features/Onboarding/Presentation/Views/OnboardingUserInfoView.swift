//
//  OnboardingUserInfoPage.swift
//  FeetFit
//
//  Created by 이채은 on 5/20/26.
//

import SwiftUI


struct OnboardingUserInfoView: View {
    
    @State private var userInfo = UserInfo()
    @State private var agreementState = AgreementState()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case nickname
        case age
        case weight
        case height
        case footSize
    }
    
    private var isFormValid: Bool {
        userInfo.isOnboardingFilled && agreementState.isRequiredChecked
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                Spacer().frame(height: 24)
                
                TopIntro
                
                Spacer().frame(height: 32)
                
                TopInputField
                
                Spacer().frame(height: 32)
                
                BottomInputField
                
                
            }
            .padding(.horizontal, 16)
        }
        .background(.gray03)
        .navigationBarBackButtonHidden()
        
    }
    
    //상단 인사말
    var TopIntro: some View {
        VStack(alignment: .leading) {
            Text("안녕하세요")
                .pretendardFont(.Title)
            Text("핏핏에 오신 걸 환영해요!")
                .pretendardFont(.Title)
            
            Spacer().frame(height: 12)
            
            
            Text("발 측정에 앞서 몇 가지 정보를 알려주세요.")
                .pretendardFont(.Description)
        }
        .padding(.leading, 12)
    }
    
    //닉네임, 나이, 키, 몸무게, 평소 발 사이즈 입력 필드
    var TopInputField: some View {
        VStack {
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
            .padding(.horizontal, 20)
            .background(.white)
            .mainBoxStyle()
            
            Spacer().frame(height: 32)
            
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
                    title: "발 사이즈",
                    unit: "mm",
                    text: $userInfo.footSize,
                    field: .footSize,
                    nextField: nil,
                    focusedField: $focusedField
                )
            }
            .background(.white)
            .padding(.horizontal, 20)
            .mainBoxStyle()
        }
    }
    
    var BottomInputField: some View {
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
            
            Spacer().frame(height: 32)
            
            Text("약관 동의")
                .pretendardFont(.SectionTitle)
                .padding(.bottom, 10)
            
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    CircleCheckbox(isChecked: agreementState.isAllChecked) {
                        agreementState.toggleAll()
                    }
                    
                    Text("전체 동의")
                        .pretendardFont(.SectionTitle)
                    
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Divider()
                
                HStack {
                    CircleCheckbox(isChecked: agreementState.isServiceTermsChecked) {
                        agreementState.isServiceTermsChecked.toggle()
                        agreementState.updateAllChecked()
                    }
                    
                    Text("서비스 이용 약관")
                        .pretendardFont(.Caption)
                    
                    Text("(필수)")
                        .pretendardFont(.Caption)
                        .foregroundStyle(Color.red01)
                    
                    Spacer()
                    
                    Link(destination: URL(string: "https://leaf-isthmus-837.notion.site/FeetFit-3600ea276435808ca4e9cf9547b23f45?source=copy_link")!) {
                        Text("보기")
                            .pretendardFont(.Caption)
                            .foregroundStyle(Color.blue01)
                    }
                }
                .padding(.trailing, 8)
                .padding(.top, 10)
                
                HStack {
                    CircleCheckbox(isChecked: agreementState.isPrivacyPolicyChecked) {
                        agreementState.isPrivacyPolicyChecked.toggle()
                        agreementState.updateAllChecked()
                    }
                    
                    Text("개인정보처리 방침")
                        .pretendardFont(.Caption)
                    
                    Text("(필수)")
                        .pretendardFont(.Caption)
                        .foregroundStyle(Color.red01)
                    
                    Spacer()
                    
                    Link(destination: URL(string: "https://leaf-isthmus-837.notion.site/3600ea2764358018b6d0ed799bb46bd3?source=copy_link")!) {
                        Text("보기")
                            .pretendardFont(.Caption)
                            .foregroundStyle(Color.blue01)
                    }
                }
                .padding(.trailing, 8)
                .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(.white)
            .mainBoxStyle()
            
            
            Spacer().frame(height: 32)
            
            MainButton("하드웨어 등록하기") { }
                .buttonSize(.big)
                .disabled(!isFormValid)
        }
    }
}



#Preview{
    OnboardingUserInfoView()
}
