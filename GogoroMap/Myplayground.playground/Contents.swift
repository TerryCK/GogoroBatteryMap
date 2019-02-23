import Foundation


import Foundation

struct BatteryStation: Decodable {
    let data: [Datum]
    
    struct Datum: Decodable {
        let state: Int
        let locName, address : Detail
        let latitude, longitude: Double
        let availableTime: String
        
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
            availableTime = try container.decode(String.self, forKey: .availableTime)
            
            let locNameString = try container.decode(String.self, forKey: .locName)
            let addressString = try container.decode(String.self, forKey: .address)
            
            let jsonDecoder = JSONDecoder()
            locName = try jsonDecoder.decode(Detail.self, from: locNameString.data(using: .utf8)!)
            address = try jsonDecoder.decode(Detail.self, from: addressString.data(using: .utf8)!)
        }
        
        struct Detail: Decodable {
            let list: [Localization]
            var en: String  { return list.first!.value }
            var zh: String  { return list.last!.value  }
            
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








do {
     let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json")!
    
    let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
    let batteryStation = try JSONDecoder().decode(BatteryStation.self, from: data)
    print(batteryStation.data.first!.address.zh)
} catch {
    print(error.localizedDescription)
}
