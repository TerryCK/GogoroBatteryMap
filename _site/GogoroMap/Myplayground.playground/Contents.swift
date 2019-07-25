import Foundation
import Myplayground_Sources
import MapKit
import PlaygroundSupport

//
//let data = Bundle.main.path(forResource: "gogoro", ofType: "json").flatMap { try? Data(contentsOf: URL(fileURLWithPath: $0)) }
//let station1 = (try! JSONDecoder().decode(Response.self, from: data!)).stations





var weather = Weather(speed: 10)

weather.speed = 20
print(weather.speed)

