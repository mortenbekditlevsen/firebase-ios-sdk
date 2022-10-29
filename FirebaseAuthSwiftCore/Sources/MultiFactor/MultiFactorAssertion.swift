//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 28/10/2022.
//

import Foundation

#if os(iOS)

@objc(FIRMultiFactorAssertion) public class MultiFactorAssertion: NSObject {
    /**
       @brief The second factor identifier for this opaque object asserting a second factor.
    */
    @objc public var factorID: String

    init(factorID: String) {
        self.factorID = factorID
    }
}

#endif
