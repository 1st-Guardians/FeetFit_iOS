import SwiftUI
import Lottie

struct MeasurementGuideView: View {
    let guide: MeasurementGuide
    var isActionInFlight = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ViewThatFits(in: .vertical) {
                guideContent
                ScrollView(showsIndicators: false) {
                    guideContent
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let buttonTitle = guide.buttonTitle {
                MainButton(isActionInFlight ? "요청 중..." : buttonTitle, action: action)
                    .disabled(isActionInFlight)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 36)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .top)
        .background(.white)
    }

    private var guideContent: some View {
        VStack(spacing: 16) {
            Group {
                if let systemImage = guide.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 70))
                        .foregroundStyle(guide == .failed ? Color.red01 : Color.blue01)
                } else {
                    LottieView(animation: .named("FeetFit Loading", bundle: .main))
                        .playing(loopMode: .loop)
                        .frame(width: 100, height: 100)
                }
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(guide.title)
                    .pretendardFont(.SubTitle)
                    .accessibilityAddTraits(.isHeader)

                Text(guide.description)
                    .pretendardFont(.Description)
            }
            .foregroundStyle(.black01)
            .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }
}

#Preview {
    MeasurementGuideView(guide: .photoPreparation, action: {})
}
