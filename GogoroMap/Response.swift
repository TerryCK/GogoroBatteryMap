//
//  Response.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 23/02/2019.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import UIKit

protocol ResponseStationProtocol {
    var state: Int { get }
    var name: Response.Station.Detail { get }
    var address: Response.Station.Detail { get }
    var latitude : Double { get  }
    var longitude: Double { get  }
    var availableTime: String? { get }
}
protocol StationDataSorce: ResponseStationProtocol {
    var checkinDay: String  { get }
    var isOpening: Bool     { get }
    var checkinCounter: Int { get }
}

extension StationDataSorce {
    var isOpening: Bool { return state == 1 }
}
extension ResponseStationProtocol {
    var annotationImage: UIImage { return state != 1 ? #imageLiteral(resourceName: "building") : availableTime?.contains("24") ?? false ? #imageLiteral(resourceName: "pinFull") : #imageLiteral(resourceName: "shortTime") }
}

extension Response.Station.Detail {
    func localized() -> String? {
        return NSLocale.preferredLanguages.first?.contains("en") ?? false ? list.first?.value : list.last?.value 
    }
}

struct Response: Decodable {
    let stations: [Station]
    
    enum CodingKeys: String, CodingKey {
        case stations = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stations = try container.decode([Station].self, forKey: .stations)
    }
    
    struct Station: Decodable, ResponseStationProtocol {
        let state: Int
        let name, address : Detail
        let latitude, longitude: Double
        let availableTime: String?
        
        enum CodingKeys: String, CodingKey {
            case name = "LocName"
            case latitude = "Latitude"
            case longitude = "Longitude"
            case address = "Address"
            case state = "State"
            case availableTime = "AvailableTime"
        }
        
        init(from decoder: Decoder) throws {
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
        
        struct Detail: Decodable {
            let list: [Localization]
            
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
