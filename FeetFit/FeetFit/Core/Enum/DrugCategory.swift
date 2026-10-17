import Foundation

enum DrugCategory: String, CaseIterable, Identifiable {
    case athletesFoot = "athletes-foot"
    case bunionBand = "bunion-band"
    case woundCare = "wound-care"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .athletesFoot: return "무좀약"
        case .bunionBand: return "무지외반증 교정밴드"
        case .woundCare: return "상처·발 관리"
        }
    }
}
