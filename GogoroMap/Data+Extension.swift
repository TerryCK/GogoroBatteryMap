//
//  Data+Extension.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2020/6/6.
//  Copyright © 2020 陳 冠禎. All rights reserved.
//

import Foundation

extension Data {
    static func size(count: Int) ->  String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(count))
    }
}
