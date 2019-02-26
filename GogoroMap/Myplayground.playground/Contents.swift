import Foundation
import Myplayground_Sources
import MapKit
import PlaygroundSupport

let oldData = """
[{
"Id": "8b8c3a4f-89a6-4544-9f69-116fab246164",
"LocName": "{\"List\": [{\"Value\": \"7-ELEVEN Sanjing Store\",\"Lang\": \"en-US\"},{\"Value\": \"7-ELEVEN 三井店站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.788893,
"Longitude": 120.471164,
"ZipCode": "64881",
"Address": "{\"List\": [{\"Value\": \"No.118, Zhenxing Rd., Xiluo Township, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣西螺鎮振興路118號(近西螺OPEN小將公車)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Xiluo Township\",\"Lang\": \"en-US\"},{\"Value\": \"西螺鎮\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
},
{
"Id": "41c44a19-d494-4845-a659-19d5cba5b29a",
"LocName": "{\"List\": [{\"Value\": \"CPC Tuku GS\",\"Lang\": \"en-US\"},{\"Value\": \"中油土庫加油站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.678779,
"Longitude": 120.393428,
"ZipCode": "63345",
"Address": "{\"List\": [{\"Value\": \"No.131, Jianguo Rd., Tuku Township, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣土庫鎮建國路131號(近建國路/光明路口)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Tuku Township\",\"Lang\": \"en-US\"},{\"Value\": \"土庫鎮\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
},
{
"Id": "5dfa7fd8-2148-4fb2-b3b3-2d98949c0227",
"LocName": "{\"List\": [{\"Value\": \"Pxmart HW Zhongzhen Store\",\"Lang\": \"en-US\"},{\"Value\": \"全聯虎尾中正店站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.707607,
"Longitude": 120.431245,
"ZipCode": "63246",
"Address": "{\"List\": [{\"Value\": \"No.23, Sec. 2, Linsen Rd., Huwei Township, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣虎尾鎮林森路二段23號(近虎尾天后宮商店街)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Huwei Township\",\"Lang\": \"en-US\"},{\"Value\": \"虎尾鎮\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
},
{
"Id": "72448e88-d147-4640-8e72-2f5f85240484",
"LocName": "{\"List\": [{\"Value\": \"Pxmart MLo Qiaotou Store\",\"Lang\": \"en-US\"},{\"Value\": \"全聯麥寮橋頭店站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.794078,
"Longitude": 120.273057,
"ZipCode": "63864",
"Address": "{\"List\": [{\"Value\": \"No.160, Qiaotou, Mailiao Township, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣麥寮鄉橋頭村160號(近橋頭路/新民街口)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Mailiao Township\",\"Lang\": \"en-US\"},{\"Value\": \"麥寮鄉\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
},
{
"Id": "911d709e-a0c6-4f07-ad76-364cfa8091e6",
"LocName": "{\"List\": [{\"Value\": \"Gogoro DL MingdeNorth RS Center\",\"Lang\": \"en-US\"},{\"Value\": \"Gogoro 斗六明德北門市站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.715078,
"Longitude": 120.535096,
"ZipCode": "64049",
"Address": "{\"List\": [{\"Value\": \"No.350, Sec. 2, Mingde N. Rd., Douliu City, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣斗六市明德北路二段350號(近斗六棒球場)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Douliu City\",\"Lang\": \"en-US\"},{\"Value\": \"斗六市\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
},
{
"Id": "7d5915e0-c312-4c5d-98f0-49448f23c7cd",
"LocName": "{\"List\": [{\"Value\": \"CPC Taixi GS\",\"Lang\": \"en-US\"},{\"Value\": \"中油台西加油站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.698962,
"Longitude": 120.202715,
"ZipCode": "63654",
"Address": "{\"List\": [{\"Value\": \"No.36, Zhongshan Rd., Taixi Township, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣台西鄉中山路36號(近中山路/文化路口)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Taixi Township\",\"Lang\": \"en-US\"},{\"Value\": \"臺西鄉\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
},
{
"Id": "cc7c84a5-f7ce-412e-8ca8-52c2fa4277e6",
"LocName": "{\"List\": [{\"Value\": \"Carrefour Douliu Store\",\"Lang\": \"en-US\"},{\"Value\": \"家樂福斗六店站\",\"Lang\": \"zh-TW\"}]}",
"Latitude": 23.702237,
"Longitude": 120.530646,
"ZipCode": "64041",
"Address": "{\"List\": [{\"Value\": \"No.297, Sec. 2, Yunlin Rd., Douliu City, Yunlin County\",\"Lang\": \"en-US\"},{\"Value\": \"雲林縣斗六市雲林路二段297號(近雲林縣政府)\",\"Lang\": \"zh-TW\"}]}",
"District": "{\"List\": [{\"Value\": \"Douliu City\",\"Lang\": \"en-US\"},{\"Value\": \"斗六市\",\"Lang\": \"zh-TW\"}]}",
"State": 1,
"City": "{\"List\":[{\"Value\":\"Yunlin County\",\"Lang\":\"en-US\"},{\"Value\":\"雲林縣\",\"Lang\":\"zh-TW\"}]}",
"AvailableTime": "24HR",
"AvailableTimeByte": null
}
]
""".data(using: .utf8)!


let data = Bundle.main.path(forResource: "gogoro", ofType: "json").flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
let station1 = (try! JSONDecoder().decode(Response.self, from: data!)).stations
//var oldStations = (try! JSONDecoder().decode([Response.Station].self, from: oldData))

//(0..<oldStations.count).forEach {
//    oldStations[$0].checkinCounter = 10
//}

//let oldAnnotation = oldStations.map(BatteryStationPointAnnotation.init(station: ))
let newAnnotation = station1.map(BatteryStationPointAnnotation.init(station: ))


//let result = Set<BatteryStationPointAnnotation>(oldAnnotation).intersection(newAnnotation).union(newAnnotation)
//let intersection = result.intersection(oldAnnotation)
//intersection.forEach { print($0.checkinCounter as Any )}
//
//result.forEach {
//    print($0)
//}

PlaygroundPage.current.needsIndefiniteExecution = false
//
//struct Weather: Hashable {
//    let id: String
//    let speed: Int?
//    static func ==(lhs: Weather, rhs: Weather) -> Bool {
//        return lhs.hashValue == rhs.hashValue
//    }
//    var hashValue: Int {  return id.hashValue  }
//}
//
//let old = [Weather(id: "123", speed: 10), .init(id: "234", speed: 20)]
//let new = [Weather(id: "123", speed: 30), .init(id: "456", speed: 20)]
//
//
