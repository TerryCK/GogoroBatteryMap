//
//  OberserName.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/24.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation
struct NotificationName {
    static let shared = NotificationName()
    let oberseManuLabelName = NSNotification.Name(rawValue: Keys.standard.manuLabelOberseverName)
    private init() {
        
    }
}
