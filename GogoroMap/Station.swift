//
//  Station.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit



struct Station {
    
    let id: String?
    let locName: LocName?
    let latitude: Double?
    let longitude: Double?
    let zipcode: Int?
    let address: LocName?
    let district: String?
    let state: Int?
    let city: String?
    let availableTime: String?
    let availableTimeByte: String?
    
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["Id"] as? String ?? ""
        self.latitude = dictionary["Latitude"] as? Double ?? 0
        self.longitude = dictionary["Longitude"] as? Double ?? 0
        self.zipcode = dictionary["ZipCode"] as? Int ?? 0
        self.district = dictionary["District"] as? String ?? ""
        self.state = dictionary["State"] as? Int ?? 0
        self.city = dictionary["City"] as? String ?? ""
        self.availableTime = dictionary["AvailableTime"] as? String ?? ""
        self.availableTimeByte = dictionary["AvailableTimeByte"] as? String ?? ""
        self.locName = Station.getLocalNameObject(jsonString: dictionary["LocName"] as? String ?? "")
        self.address = Station.getLocalNameObject(jsonString: dictionary["Address"] as? String ?? "")
    }
    
    struct LocName {
        let engName: String?
        let twName: String?
        
        init?(arr: [[String: Any]]) {
            self.engName = arr[0]["Value"] as? String ?? ""
            self.twName = arr[1]["Value"] as? String ?? ""
        }
    }
    
    private static func getLocalNameObject(jsonString: String) -> LocName? {
        
        guard
            let jsonData = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
            let parsedLocoName = json?["List"] as? [[String: Any]] else { return nil }
        
        return LocName(arr: parsedLocoName)
        
    }
    
}

