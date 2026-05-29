//
//  HardwareRegisterView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//
import SwiftUI
import Lottie

struct HardwareRegisterView: View {
    var body: some View {
        VStack(spacing: 0){
            
            LoadingMessageView(
                message: "하드웨어를\n등록해주세요."
            )
            .padding(.bottom, 277)
            
            
            
            MainButton("하드웨어 등록하기", action: {
                print("하드웨어 등록 버튼 클릭")
            })
            .padding(.bottom, 20)
            .padding(.horizontal, 18)
            
            
            Text("다음에 등록할래요")
                .underline()
                .pretendardFont(.Placeholder)
                .foregroundStyle(.gray01)
            
            
            
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    HardwareRegisterView()
}
