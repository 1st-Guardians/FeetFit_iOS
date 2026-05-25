//
//  UserInfoGroup.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct UserInfoGroup: View {
    
    @State private var userInfo = UserInfo(
        nickname: "황먼지",
        age: "24",
        weight: "55",
        height: "165",
        footSize: "230",
        gender: .female
    )
    
    var body: some View {
        VStack(spacing: 0) {
            UserInfoRow(title: "이름", value: userInfo.nickname, showsDivider: true)
            UserInfoRow(title: "나이", value: "\(userInfo.age)세", showsDivider: true)
            UserInfoRow(title: "키", value: "\(userInfo.height)cm", showsDivider: true)
            UserInfoRow(title: "몸무게", value: "\(userInfo.weight)kg", showsDivider: true)
            UserInfoRow(title: "발 사이즈", value: "\(userInfo.footSize)mm")
        }
        .padding(.horizontal, 20)
        .mainBoxStyle()
    }
    
    
    private struct UserInfoRow: View {
        let title: String
        let value: String
        var showsDivider: Bool = false
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .pretendardFont(.Placeholder)
                    
                    Spacer()
                    
                    Text(value)
                        .pretendardFont(.Placeholder)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 18)
                
                if showsDivider {
                    Divider()
                }
            }
        }
    }
}


#Preview {
    UserInfoGroup()
}
