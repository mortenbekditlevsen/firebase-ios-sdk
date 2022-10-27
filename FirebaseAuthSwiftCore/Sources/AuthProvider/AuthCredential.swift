//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 26/06/2022.
//

import Foundation

@objc(FIRAuthCredentialX) public class AuthCredential: NSObject {
    @objc public let provider: String
    @objc public init(provider: String) {
        self.provider = provider
    }

    @objc public override init() {
        fatalError("This class is an abstract base class. It's init method should not be called directly.")
    }


    @objc public func prepareVerifyAssertionRequest(_ request: VerifyAssertionRequest) {
        fatalError("Attempt to call virtual method.")
    }
}
