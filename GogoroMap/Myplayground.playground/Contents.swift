//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

func test() {
    
    guard
        let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
        let data = NSData(contentsOfFile: filePath) as Data?,
        let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else { return }
    
    
        let stations = jsonDic.map { Station(dictionary: $0) }
   

    var countStats: Int = 0
    var count24HR: Int = 0
        stations.forEach { (station) in
//            if station.state == 1 {
//                countStats += 1
//            } else {
//                print("stats non \(station.id)")
//            }
            
            if station.availableTime == "24HR" {
                count24HR += 1
            } else {print(station.id)}
            
    }
//    print(countStats)
    
    print(count24HR)
    
    
    }



test()

struct Station {
    let id: String?
    let locName: LocName?
    let latitude: Double?
    let longitude: Double?
    let zipcode: Int?
    let address: String?
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
        self.address = dictionary["Address"] as? String ?? ""
        self.district = dictionary["District"] as? String ?? ""
        self.state = dictionary["State"] as? Int ?? 0
        self.city = dictionary["City"] as? String ?? ""
        self.availableTime = dictionary["AvailableTime"] as? String ?? ""
        self.availableTimeByte = dictionary["AvailableTimeByte"] as? String ?? ""
        
        self.locName = Station.getLocalNameObject(jsonString: dictionary["LocName"] as? String ?? "")
        
        
        
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

let optionalnum: Int? = 40

if case .some(let x) = optionalnum {
    print(x)
}

let arrayOfOptionalInts: [Int?] = [nil, 2, 3, nil, 5]
// Match only non-nil values.
for case let number in arrayOfOptionalInts {
    print("Found a \(number)")
}

for case let number? in arrayOfOptionalInts {
    print("Found a \(number)")
}

for number in arrayOfOptionalInts {
    print("Found a \(number)")
}
