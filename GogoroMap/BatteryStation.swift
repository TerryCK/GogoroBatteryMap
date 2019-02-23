//
//  BatteryStation.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import Foundation

struct BatteryStation: Decodable {
    let data: [Datum]
    
    struct Datum: Decodable {
        let state: Int
        let locName, address : Detail
        let latitude, longitude: Double
        let availableTime: String?
        
        enum CodingKeys: String, CodingKey {
            case locName = "LocName"
            case latitude = "Latitude"
            case longitude = "Longitude"
            case address = "Address"
            case state = "State"
            case availableTime = "AvailableTime"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state          = try container.decode(Int.self, forKey: .state)
            latitude      = try container.decode(Double.self, forKey: .latitude)
            longitude     = try container.decode(Double.self, forKey: .longitude)
            availableTime = try container.decode(String?.self, forKey: .availableTime)
            
            let locNameString = try container.decode(String.self, forKey: .locName)
            let addressString = try container.decode(String.self, forKey: .address)
            
            let jsonDecoder = JSONDecoder()
            locName = try jsonDecoder.decode(Detail.self, from: locNameString.data(using: .utf8)!)
            address = try jsonDecoder.decode(Detail.self, from: addressString.data(using: .utf8)!)
        }

        struct Detail: Decodable {
            let list: [Localization]
            var en: String?  { return list.first?.value }
            var zh: String?  { return list.last?.value  }
            
            enum CodingKeys: String, CodingKey {
                case list = "List"
            }
            
            struct Localization: Decodable {
                let value, lang: String?
                
                enum CodingKeys: String, CodingKey {
                    case value = "Value"
                    case lang = "Lang"
                }
            }
        }
    }
}
