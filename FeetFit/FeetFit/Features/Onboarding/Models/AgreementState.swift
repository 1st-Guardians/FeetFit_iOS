//
//  AgreementState.swift
//  FeetFit
//
//  Created by 이채은 on 5/22/26.
//
import Foundation

struct AgreementState {
    var isAllChecked: Bool = false
    var isServiceTermsChecked: Bool = false
    var isPrivacyPolicyChecked: Bool = false
    
    var isRequiredChecked: Bool {
        isServiceTermsChecked && isPrivacyPolicyChecked
    }
    
    mutating func toggleAll() {
        let newValue = !isAllChecked
        
        isAllChecked = newValue
        isServiceTermsChecked = newValue
        isPrivacyPolicyChecked = newValue
    }
    
    mutating func updateAllChecked() {
        isAllChecked = isServiceTermsChecked && isPrivacyPolicyChecked
    }
}
