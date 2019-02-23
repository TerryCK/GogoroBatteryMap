//
//  BatteryStation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

// To parse the JSON, add this file to your project and do:
//
// let batteryStation = try JSONDecoder().decode(BatteryStation.self, from: data)

import Foundation

struct BatteryStation: Decodable {
    let result: Int
    let message: String
    let data: [Datum]
    
    struct Datum: Decodable {
        let state: Int
        var locName, address : LocName
        let latitude, longitude: Double
        let id, zipCode, district, city, availableTime: String
        
        
        enum CodingKeys: String, CodingKey {
            case id = "Id"
            case locName = "LocName"
            case latitude = "Latitude"
            case longitude = "Longitude"
            case zipCode = "ZipCode"
            case address = "Address"
            case district = "District"
            case state = "State"
            case city = "City"
            case availableTime = "AvailableTime"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state = try container.decode(Int.self, forKey: .state)
            latitude = try container.decode(Double.self, forKey: .latitude)
            longitude = try container.decode(Double.self, forKey: .longitude)
            id = try container.decode(String.self, forKey: .id)
            zipCode = try container.decode(String.self, forKey: .zipCode)
            district = try container.decode(String.self, forKey: .district)
            city = try container.decode(String.self, forKey: .city)
            availableTime = try container.decode(String.self, forKey: .availableTime)
            
            let locNameString = try container.decode(String.self, forKey: .locName)
            let addressString = try container.decode(String.self, forKey: .address)
            
            let jsonDecoder = JSONDecoder()
            locName = try jsonDecoder.decode(LocName.self, from: locNameString.data(using: .utf8)!)
            address = try jsonDecoder.decode(LocName.self, from: addressString.data(using: .utf8)!)
        }
        
        struct LocName: Decodable {
            let list: [Localization]
            var en: String  { return list.first!.value }
            var zh: String { return list.last!.value  }
            
            enum CodingKeys: String, CodingKey {
                case list = "List"
            }
            
            struct Localization: Decodable {
                let value, lang: String
                
                enum CodingKeys: String, CodingKey {
                    case value = "Value"
                    case lang = "Lang"
                }
            }
        }
    }
}






