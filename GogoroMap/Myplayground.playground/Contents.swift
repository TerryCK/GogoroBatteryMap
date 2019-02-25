import Foundation
func fetchData(onCompletion: (Response) -> Void) {
    do {
        let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json")!
        let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let response = try JSONDecoder().decode(Response.self, from: data)
        onCompletion(response)
    } catch {
        print("\(error)")
    }
}


//fetchData { (response) in
//
//
//    print(response.stations.first?.checkinDay)
//
//
//
//}

 let data = Bundle.main.path(forResource: "gogoro", ofType: "json").flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
let station1 = (try? JSONDecoder().decode(Response.self, from: data!))?.stations


print(12392.hashValue)
print(12392.hashValue)

var dic = [Int: Int]()
station1?.forEach {
    if $0.hashValue == -4346921064044952089 {
        print($0)
    }
    dic[$0.hashValue, default: 0] += 1
}
dic.forEach {
    if $0.value > 1 {
        print($0.key, $0.value)
    }
}


struct Weather: Hashable {
    let id: String
    let speed: Int
    
    var hashValue: Int {  return id.hashValue  }
}

let array1 = [Weather(id: "123", speed: 10), .init(id: "234", speed: 20)]
let array2 = [Weather(id: "123", speed: 30), .init(id: "456", speed: 20)]
//let result = Set<Response.Station>(station1!).intersection(<#T##other: Set<Response.Station>##Set<Response.Station>#>)

