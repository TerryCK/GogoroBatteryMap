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
    
    let manuContent = NSNotification.Name(rawValue: Keys.standard.manuContentObserverName)
    
    let removeAds = NSNotification.Name(rawValue: Keys.standard.removeAdsObserverName)
    
    private init() { }
}
