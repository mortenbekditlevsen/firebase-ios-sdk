//
//  File.swift
//  
//
//  Created by Morten Bek Ditlevsen on 11/10/2021.
//

import Foundation

public class FParsedUrl {
    public var repoInfo: FRepoInfo
    public var path: FPath
    public init(repoInfo: FRepoInfo, path: FPath) {
        self.repoInfo = repoInfo
        self.path = path
    }
}
