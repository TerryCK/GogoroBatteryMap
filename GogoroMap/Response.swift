//
//  Response.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit

public protocol ResponseStationProtocol {
    var state: Int { get }
    var name: Response.Station.Detail { get }
    var address: Response.Station.Detail { get }
    var latitude : Double { get  }
    var longitude: Double { get  }
    var availableTime: String? { get }
    var isOpening: Bool     { get }
}

public extension ResponseStationProtocol {
    var isOpening: Bool { return state == 1 }
    var annotationImage: UIImage { return isOpening ? Self.makePoiontAnnotationImage(with: name.list.last?.value) : #imageLiteral(resourceName: "building") }
    
    static func makePoiontAnnotationImage(with name: String?) -> UIImage {
        guard let name = name else { return  #imageLiteral(resourceName: "pinFull") }
        if name.contains("加油")                                { return #imageLiteral(resourceName: "gasStation") }
        if name.contains("Gogoro")                                { return #imageLiteral(resourceName: "goStore") }
        if ["家樂福", "大潤發", "Mall", "百貨"].reduce(false, { $0 || name.contains($1) })     { return #imageLiteral(resourceName: "mallStore") }
        if ["HiLife", "全聯", "7-ELEVEN", "全家"].reduce(false, { $0 || name.contains($1) })  { return #imageLiteral(resourceName: "convenientStore") }
        return #imageLiteral(resourceName: "pinFull")
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
    
    public struct Station: Decodable, ResponseStationProtocol, Hashable {
        public var hashValue: Int { return (longitude * 10000 + latitude).hashValue }
        
        public static func == (lhs: Response.Station, rhs: Response.Station) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
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
            case availableTime = "AvailableTime"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            state         = try container.decode(Int.self, forKey: .state)
            latitude      = try container.decode(Double.self, forKey: .latitude)
            longitude     = try container.decode(Double.self, forKey: .longitude)
            availableTime = try container.decode(String?.self, forKey: .availableTime)
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
