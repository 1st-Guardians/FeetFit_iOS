//
//  MyPageView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct MyPageView: View {
    @State private var hardwareStatus: HardwareStatus = .connected
    @State private var hasMeasurementRecord: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                TopInfoGroup
                    .padding(.bottom, 24)
                
                ProfileEditGroup
                    .padding(.bottom, 24)
                
                HardwareConnectingGroup
                    .padding(.bottom, 24)
                
                TermsButton
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray03)
    }
    
    
    var TopInfoGroup: some View {
        VStack(alignment: .leading, spacing:0) {
            Text("마이페이지")
                .pretendardFont(.Title)
                .padding(.bottom, 32)
                .padding(.leading, 12)
            
            UserInfoGroup()
            
            if !hasMeasurementRecord {
                Spacer().frame(height: 10)
                
                HStack(spacing: 0) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 15))
                        .padding(.trailing, 10)
                    
                    Text("측정 기록이 없어 온보딩 때 입력한 발 사이즈를 표시하고 있어요. \n정확한 발 사이즈 확인을 위해 측정을 진행해 보세요.")
                        .pretendardFont(.Caption)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue01.opacity(0.25))
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 26)
    }
    
    var ProfileEditGroup: some View {
        HStack {
            // TODO: 수정 화면
            Text("프로필 수정하기")
                .pretendardFont(.Placeholder)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(.gray01)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .mainBoxStyle()
        
    }
    
    var HardwareConnectingGroup: some View {
        VStack(spacing:0) {
            HStack {
                Text("하드웨어 연결 상태")
                    .pretendardFont(.Placeholder)
                
                Spacer()
                
                Text(hardwareStatus.status)
                    .pretendardFont(.Placeholder)
                    .foregroundStyle(hardwareStatus.color)
            }
            .padding(.vertical, 18)
            
            Divider()
            
            
            HStack {
                // TODO: 하드웨어 연결하러 가기
                Text("하드웨어 연결하러 가기")
                    .pretendardFont(.Placeholder)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray01)
            }
            .padding(.vertical, 18)
            
        }
        .padding(.horizontal, 20)
        .mainBoxStyle()
    }
    
    var TermsButton: some View {
        VStack(spacing: 0) {
            Link(destination: URL(string: "https://www.notion.so/FeetFit-3600ea276435808ca4e9cf9547b23f45?source=copy_link")!) {
                HStack {
                    Text("서비스 이용 약관")
                        .pretendardFont(.Placeholder)
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
                .padding(.vertical, 18)
            }
            
            Divider()
            
            Link(destination: URL(string: "https://www.notion.so/3600ea2764358018b6d0ed799bb46bd3?source=copy_link")!) {
                HStack {
                    Text("개인정보처리 방침")
                        .pretendardFont(.Placeholder)
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
                .padding(.vertical, 18)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .mainBoxStyle()
    }
}



#Preview {
    MyPageView()
}
