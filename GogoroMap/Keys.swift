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
    
    let manuLabelOberseverName = "manuLabelOberseverName"
    
    private init(dictionary: [String: Any] = ["": ""]) {
        adUnitID = dictionary["adUnitID"] as? String ?? ""
        applicationID = dictionary["applicationID"] as? String ?? ""
        appID = dictionary["appID"] as? String ?? ""
        secretKet = dictionary["secretKet"] as? String ?? ""
        gadiPhone = dictionary["gadiPhone"] as? String ?? ""
        gadiPad = dictionary["gadiPad"] as? String ?? ""
        gogoroAPI = dictionary["gogoroAPI"] as? String ?? ""
        
    }
    
    static let standard: Keys = {
        guard
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            var dictionary = NSDictionary(contentsOfFile: path) as? [String: Any] else {
                return Keys()
        }
        return Keys(dictionary: dictionary)
    }()
    
    
}

