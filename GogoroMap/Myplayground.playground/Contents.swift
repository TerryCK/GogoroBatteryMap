//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport



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


func getDataLocoal() -> [Station]? {
    
    guard
        let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
        let data = NSData(contentsOfFile: filePath) as Data?,
        let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else { return nil }
    
    
    return jsonDic.map { Station(dictionary: $0) }
    
}

class Obj: NSObject {
    let name: String?
    let age: Int?
    var counter: Int? = 0
    init (name:String, age: Int, counter:Int = 0) {
        self.name = name
        self.age = age
        self.counter = counter
    }
   override var hashValue: Int {
        get { return 1 }
    }
    
    
    static func ==(lhs: Obj, rhs: Obj) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}

//func getHashValue(_ element: String) -> Int {
//    
//}

let localArray = [
    Obj(name: "Terry", age: 10, counter: 10),   // merage counter
    Obj(name: "Rock", age: 23, counter: 12)     // prepare to remove
]

let severArray = [
    Obj(name: "Terry", age: 10), // merage counter
    Obj(name: "Bob", age: 12)    // prepare to add
]

func merge<T: Obj>(to origin: [T], from new: [T]) -> (result: [T], discard: [T]) {
    var dic = [String: T]()
    var result = [T]()
    var discard = [T]()
    let newElements = new.map { $0.name ?? "" }
    
    new.forEach { dic[$0.name ?? ""] = $0 }
    origin.forEach { dic[$0.name ?? ""] = $0 }
    
    
    for (key, value) in dic {
        if newElements.contains(key) {
        result.append(value)
        } else {
        discard.append(value)
        }
    }
    
    return (result: result, discard: discard)
}


// merge 2 array if element if same, reseve origin one
// 合併伺服器與本地兩個陣列，本地陣列會帶有counter參數，伺服器過來的則沒有，要讓陣列元素與伺服器相同，但陣列的counter參數要保留本地自己的。

let (merged, discard) = merge(to: localArray, from: severArray)
print("Meraged:")
merged.forEach { print($0.name!) }

print("\nDiscard:")
discard.forEach { print($0.name!) }
let setLocal = Set(localArray)








//
//
//let setMerged = Set(merged)
//let setRemote = Set(severArray)
//setMerged.isSubset(of: setLocal)
//setLocal.isSubset(of: setMerged)
//
//setRemote.isDisjoint(with: localArray)
//
//setLocal.count
//
//
//let array = Array(Set(localArray + severArray))
//
//
////let array3 = array1.filter { array2.contains(where: $0) }
////print(array3)
//
//












let x = (1.0 / 10)
let seconds = 3660.0

seconds.truncatingRemainder(dividingBy: 3600) / 60





//let array1 = [1,2,3,4,5]
//let array2 = [2,3,4,5,6,8]
//
//let set1 = Set(array1)
//let set2 = Set(array2)
//
//let ina = set1.union(set2)
//print(ina)


let fruitsArray = ["apple", "mango", "blueberry", "orange"]
let vegArray = ["tomato", "potato", "mango", "blueberry"]

let answer = fruitsArray.filter{ item in !vegArray.contains(item) }

print("\(answer)") //  ["apple", "orange"]


let keywords = ["全聯", "全國"]

let name = "全國電子揪甘心欸"

let closure = { (result: Bool, element: String) -> Bool in
    return result || name.contains(element)
}
keywords.reduce(false) { (result, element) -> Bool in
    return  result || name.contains(element)
}





