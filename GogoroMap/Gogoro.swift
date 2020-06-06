//
//  Response.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit

extension NSLocale {
    
    static var isPreferredEnglish: Bool { preferredLanguages.first?.contains("en") ?? false }
}

extension Gogoro.Station {
    
    var keyPath: KeyPath<Detail, String?> {
        NSLocale.isPreferredEnglish ? \.list.first?.value : \.list.last?.value
    }
}

public struct Gogoro: Decodable {
    
    public let stations: [Station]
    
    enum CodingKeys: String, CodingKey {
        case stations = "data"
    }
    
    public struct Station: Decodable {
        
        public let state: Int
        
        var name: String {
            _name[keyPath: keyPath]?
                .replacingOccurrences(regex: "臺".regex, replacement: "台") ?? ""
        }
        
        var address: String {  _address[keyPath: keyPath] ?? "" }
        var city: String    {  _city[keyPath: keyPath] ?? "" }
        
        public let latitude, longitude: Double
        public let availableTime, id: String?
        
        
        private let _name, _address, _city: Detail
        
        enum CodingKeys: String, CodingKey {
            case name          = "LocName"
            case latitude      = "Latitude"
            case longitude     = "Longitude"
            case address       = "Address"
            case state         = "State"
            case availableTime = "AvailableTime"
            case city          = "City"
            case id            = "Id"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state         = try container.decode(Int.self, forKey: .state)
            latitude      = try container.decode(Double.self, forKey: .latitude)
            longitude     = try container.decode(Double.self, forKey: .longitude)
            availableTime = try container.decode(String?.self, forKey: .availableTime)
            let nameString = try container.decode(String.self, forKey: .name)
            let addressString = try container.decode(String.self, forKey: .address)
            let cityString = try container.decode(String.self, forKey: .city)
            let jsonDecoder = JSONDecoder()
            _name = try jsonDecoder.decode(Detail.self, from: nameString.data(using: .utf8)!)
            _city = try jsonDecoder.decode(Detail.self, from: cityString.data(using: .utf8)!)
            _address = try jsonDecoder.decode(Detail.self, from: addressString.data(using: .utf8)!)
            id = try container.decode(String?.self, forKey: .id)
        }
        
        public struct Detail: Codable {
            public let list: [Localization]
            
            enum CodingKeys: String, CodingKey {
                case list = "List"
            }
            
            public struct Localization: Codable {
                public let value, lang: String?
                
                enum CodingKeys: String, CodingKey {
                    case value = "Value"
                    case lang = "Lang"
                }
            }
        }
    }
}
