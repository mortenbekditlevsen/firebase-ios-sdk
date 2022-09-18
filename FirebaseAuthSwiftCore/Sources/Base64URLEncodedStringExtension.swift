//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 13/06/2022.
//

import Foundation

// XXX TODO: Make into extension on Data rather than free floating
//extension Data {
@objc public class TemporaryThing: NSObject {
    @objc public class func fir_base64URLEncodedString(data: Data, options: Data.Base64EncodingOptions) -> String {
        var string = data.base64EncodedString(options: options)
        string = string.replacingOccurrences(of: "/", with: "_")
        string = string.replacingOccurrences(of: "+", with: "-")
        string = string.replacingOccurrences(of: "=", with: "")
        return string
    }
}
//}
