//
//  ClusterStatue.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 17/03/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation

enum ClusterStatus {
    case on, off
    
    init(_ bool: Bool = UserDefaults.standard.value(forKey: "cluster") as? Bool ?? true) {
        self = bool ? .on : .off
    }
    
    mutating func change() {
        let willBe: ClusterStatus = self == .on ? .off : .on
        UserDefaults.standard.set(willBe == .on, forKey: "cluster")
        self = willBe
    }
    
}
