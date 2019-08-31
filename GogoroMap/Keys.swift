//
//  Keys.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/16.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import Foundation

struct Keys {
   
    let adUnitID: String
    let applicationID: String
    let appID: String
    let secretKet: String
    let gadiPhone: String
    let gadiPad: String
    let gogoroAPI: String
    let beenHereKey = "beenHere"
    let hasPurchesdKey = "hasPurchesd"
    let dataKey = "dataKey"
    let annotationsKey = "annotationsKey"
    let nowDateKey = "dateKey"
    let manuContentObserverName = "manuContentObserverName"
    let removeAdsObserverName = "removeAdsObserverName"
    let dataUpdata = "dataUpdata"
    let backupAdUnitID: String
    let goShareScriptID: String
    
    private init(dictionary: [String: Any] = ["": ""]) {
        adUnitID = dictionary["adUnitID"] as? String ?? ""
        applicationID = dictionary["applicationID"] as? String ?? ""
        appID = dictionary["appID"] as? String ?? ""
        secretKet = dictionary["secretKet"] as? String ?? ""
        gadiPhone = dictionary["gadiPhone"] as? String ?? ""
        gadiPad = dictionary["gadiPad"] as? String ?? ""
        gogoroAPI = dictionary["gogoroAPI"] as? String ?? ""
        backupAdUnitID = dictionary["backupAdUnitID"] as? String ?? ""
        goShareScriptID = dictionary["goShareScriptID"] as? String ?? ""
    }
    
    static let standard: Keys = {
        guard
            let url = Bundle.main.url(forResource: "Keys", withExtension: "plist"),
            let dictionary = NSDictionary(contentsOf: url) as? [String: Any] else {
                return Keys()
        }
        return Keys(dictionary: dictionary)
    }()
}

