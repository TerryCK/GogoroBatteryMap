//
//  Environment.swift
//  SupplyMap
//
//  Created by CHEN GUAN-JHEN on 2019/8/10.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

enum Environment {
    case debug, release
    static var environment: Environment {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }
}
