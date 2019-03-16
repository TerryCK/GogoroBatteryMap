//
//  Response.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit

public protocol ResponseStationProtocol: Hashable {
    var status: Int { get }
    var name: Response.Station.Detail { get }
    var address: Response.Station.Detail { get }
    var latitude : Double { get  }
    var longitude: Double { get  }
    var availableTime: String? { get }
    var checkinCounter: Int? { get }
    var checkinDay: String? { get }
    
}

public extension ResponseStationProtocol {

    
    public var hashValue: Int { return (longitude * 10000 + latitude).hashValue }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
   
}

public extension Response.Station.Detail {
    func localized() -> String? {
        return NSLocale.preferredLanguages.first?.contains("en") ?? false ? list.first?.value : list.last?.value
    }
}


public struct Response: Decodable {
    public let stations: [Station]
    
    enum CodingKeys: String, CodingKey {
        case stations = "data"
    }
    
    public struct Station: Decodable, ResponseStationProtocol {
        public var checkinCounter: Int? = nil, checkinDay: String? = nil
        
        public let state: Int
        public let name, address : Detail
        public let latitude, longitude: Double
        public let availableTime: String?
        
        enum CodingKeys: String, CodingKey {
            case name          = "LocName"
            case latitude      = "Latitude"
            case longitude     = "Longitude"
            case address       = "Address"
            case state         = "State"
            case checkinDay    = "checkinDay"
            case availableTime = "AvailableTime"
            case checkinCounter = "checkinCounter"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state         = try container.decode(Int.self, forKey: .state)
            latitude      = try container.decode(Double.self, forKey: .latitude)
            longitude     = try container.decode(Double.self, forKey: .longitude)
            availableTime = try container.decode(String?.self, forKey: .availableTime)
            checkinCounter = try container.decode(Int?.self, forKey: .checkinCounter)
            checkinDay = try container.decode(String?.self, forKey: .checkinDay)
            let nameString = try container.decode(String.self, forKey: .name)
            let addressString = try container.decode(String.self, forKey: .address)
            let jsonDecoder = JSONDecoder()
            name = try jsonDecoder.decode(Detail.self, from: nameString.data(using: .utf8)!)
            address = try jsonDecoder.decode(Detail.self, from: addressString.data(using: .utf8)!)
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
