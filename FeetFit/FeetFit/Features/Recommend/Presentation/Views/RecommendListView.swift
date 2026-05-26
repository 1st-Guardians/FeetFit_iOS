//
//  RecommendListView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct RecommendListView: View {
    @State private var selectedSortType: ShoeSortType = .fit
    
    private let recommendation = ShoeRecommendation(
        userName: "황먼지",
        footDescription: "발의 아치가 낮아 발바닥이 넓게 닿는 편이에요. 오래 걷거나 서 있으면 피로가 커질 수 있어 아치를 잘 받쳐주는 신발이 더 편안할 수 있어요.",
        shoes: [
            ShoeInfo(id: 1, brand: "Converse", name: "척테일러 올스타 클래식 블랙", price: 75000, rating: 4.3, fitScore: 92, interestCount: 128, imageURL: ""),
            ShoeInfo(id: 2, brand: "Nike", name: "나이키 에어포스 1 07 화이트", price: 139000, rating: 4.7, fitScore: 85, interestCount: 320, imageURL: ""),
            ShoeInfo(id: 3, brand: "Adidas", name: "아디다스 삼바 OG 클라우드 화이트", price: 129000, rating: 4.5, fitScore: 88, interestCount: 260, imageURL: ""),
            ShoeInfo(id: 4, brand: "New Balance", name: "뉴발란스 530 클래식 실버 크림 화이트 발볼 편한 데일리 러닝 스니커즈 어쩌구 저쩌구 엄청 긴 상품명 테스트용", price: 119000, rating: 4.6, fitScore: 96, interestCount: 410, imageURL: ""),
            ShoeInfo(id: 5, brand: "Asics", name: "아식스 젤 카야노 14 크림 블랙", price: 169000, rating: 4.8, fitScore: 91, interestCount: 390, imageURL: ""),
            ShoeInfo(id: 6, brand: "Puma", name: "푸마 스피드캣 OG 블랙 화이트", price: 109000, rating: 4.2, fitScore: 79, interestCount: 180, imageURL: ""),
            ShoeInfo(id: 7, brand: "Vans", name: "반스 올드스쿨 클래식 블랙", price: 79000, rating: 4.4, fitScore: 82, interestCount: 230, imageURL: ""),
            ShoeInfo(id: 8, brand: "Reebok", name: "리복 클럽 C 85 빈티지", price: 99000, rating: 4.1, fitScore: 76, interestCount: 145, imageURL: ""),
            ShoeInfo(id: 9, brand: "Fila", name: "휠라 레이플라이드 화이트", price: 69000, rating: 4.0, fitScore: 73, interestCount: 98, imageURL: ""),
            ShoeInfo(id: 10, brand: "Onitsuka Tiger", name: "오니츠카타이거 멕시코 66 옐로우 블랙", price: 150000, rating: 4.6, fitScore: 87, interestCount: 275, imageURL: "")
        ]
    )
    
    private var sortedShoes: [ShoeInfo] {
        selectedSortType.sort(recommendation.shoes)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            background
            
            
            VStack(alignment: .leading, spacing: 0) {
                topGroup
                    .padding([.bottom, .horizontal], 16)
                ScrollView {
                    Spacer()
                    
                    midGroup
                    
                    Spacer()
                }
            }
        }
    }
    
    var background: some View {
        VStack {
            Rectangle()
                .foregroundColor(.clear)
                .blueLinear()
                .padding(.bottom, 502)
            
            Spacer()
        }
    }
    
    var topGroup: some View {
        VStack(alignment: .leading) {
            Text("신발 추천")
                .pretendardFont(.Title)
                .padding(.top, 26)
                .padding(.leading, 12)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(recommendation.userName)님의 발 타입은요..")
                    .pretendardFont(.BlockTitle)
                    .padding(.bottom, 10)
                
                Text(recommendation.footDescription)
                    .pretendardFont(.BlockText)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.35))
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue02)
                    .shadow(color: .blue02, radius: 4, x: 0, y: 0)
                    .mask {
                        Rectangle()
                            .padding(-8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                    }
            }
            .padding(.bottom, 18)
            
            HStack {
                Text("\(sortedShoes.count)개")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                
                Spacer()
                
                sortMenu
            }
        }
    }
    
    var sortMenu: some View {
        Menu {
            ForEach(ShoeSortType.allCases, id: \.self) { type in
                Button {
                    selectedSortType = type
                } label: {
                    HStack {
                        Text(type.rawValue)
                        
                        if selectedSortType == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedSortType.rawValue)
                    .pretendardFont(.Description)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 11))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .glassEffect(in: .capsule)
        }
        .buttonStyle(.plain)
    }
    
    var midGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sortedShoes) { shoe in
                ShoeInfoView(shoe: shoe)
            }
        }
    }
}

#Preview {
    RecommendListView()
}
