//
//  ToolBarCollection.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct ToolBarCollection {
    
    // MARK: - 뒤로가기 버튼
    
    struct BackBtn: ToolbarContent {
        @Environment(\.dismiss) private var dismiss
        var action: () -> Void = { }
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    action()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    
    // MARK: - 좌측 상단 메뉴
    
    struct ReportMenu: ToolbarContent {
        @Binding var selection: ReportMenuType
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button {
                        selection = .resultReport
                    } label: {
                        Text("결과 리포트")
                    }
                    
                    Button {
                        selection = .summary
                    } label: {
                        Text("요약")
                    }
                } label: {
                    Text(selection.rawValue)
                        .font(.callout)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - 전송 버튼
    
    struct SendBtn: ToolbarContent {
        let action: () -> Void
        let disable: Bool
        let isLoading: Bool
        let tintColor: Color
        
        init(
            action: @escaping () -> Void,
            disable: Bool = false,
            isLoading: Bool = false,
            tintColor: Color = .blue
        ) {
            self.action = action
            self.disable = disable
            self.isLoading = isLoading
            self.tintColor = tintColor
        }
        
        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard !disable, !isLoading else { return }
                    action()
                } label: {
                    ZStack {
                        Image(systemName: "paperplane.fill")
                            .opacity(isLoading ? 0 : 1)
                        
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                        }
                    }
                }
                .tint((disable || isLoading) ? .gray : tintColor)
                .disabled(disable || isLoading)
            }
        }
    }
    
    // MARK: - 달력 버튼

    struct CalendarBtn: ToolbarContent {
        @Binding var selectedDate: Date

        let measuredDates: [Date]
        var onMonthChange: ((Date) -> Void)? = nil

        @State private var isPresented: Bool = false

        var body: some ToolbarContent {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresented = true
                } label: {
                    Image(systemName: "calendar")
                }
                .popover(isPresented: $isPresented) {
                    CustomCalendarPickerView(
                        selectedDate: $selectedDate,
                        measuredDates: measuredDates,
                        onSelect: {
                            isPresented = false
                        },
                        onMonthChange: onMonthChange
                    )
                    .frame(width: 340)
                    .presentationCompactAdaptation(.popover)
                }
            }
        }
    }
}
