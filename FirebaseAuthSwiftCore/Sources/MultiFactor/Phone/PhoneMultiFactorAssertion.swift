//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 28/10/2022.
//

import Foundation

@objc public protocol PhoneAuthCredentialWrapper: NSObjectProtocol {}

@objc(FIRPhoneMultiFactorAssertion) public class PhoneMultiFactorAssertion: MultiFactorAssertion {
    @objc public var authCredential: PhoneAuthCredentialWrapper?

    @objc public init() {
        super.init(factorID: FIRPhoneMultiFactorID)
    }
}
