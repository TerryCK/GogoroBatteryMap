//
//  Navigatorable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit
import Crashlytics

protocol Navigable {
    
    static var option: Navigator.Option { get }
    static func go<T: BatteryStationPointAnnotation>(to destination: T)
    static func travelETA(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completionHandler: @escaping (Result<MKDirections.Response, Error>)-> Void)
}

struct Navigator: Navigable {
    
    enum Option: Int, CaseIterable, CustomStringConvertible {
        var description: String {
            switch self {
            case .apple:  return  "Apple Map"
            case .google: return "Google Map"
            }
        }
        
        case apple = 0, google
        
    }
    
    static var option: Option {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: #function)
        }
        get {
            return Option(rawValue: UserDefaults.standard.integer(forKey: #function))!
        }
    }
    
    static func go<T: BatteryStationPointAnnotation>(to destination: T) {
        Answers.log(event: .Navigator, customAttributes: option.description)
        switch option {
        case .google:
            guard let address = destination.address.matches(with: #"^[^\(\)]*"#.regex).first?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    fallthrough
            }
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(address)&directionsmode=motorcycle") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url) { isFinish in
                        if !isFinish {
                            goWithAppleMap(to: destination)
                        }
                    }
                } else {
                    UIApplication.shared.openURL(url)
                }
                return
            }
            fallthrough
        case .apple: goWithAppleMap(to: destination)
        }
    }
    
    
    static func goWithAppleMap<T: BatteryStationPointAnnotation>(to destination: T) {
        guard let name = destination.title else { return }
        let placemark = MKPlacemark(coordinate: destination.coordinate, addressDictionary: [name: ""])
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(name)(Gogoro \("Battery Station".localize()))"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    static func travelETA(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completionHandler: @escaping (Result<MKDirections.Response, Error>)-> Void) {
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        let request = MKDirections.Request {
            $0.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
            $0.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
            $0.transportType = .automobile
            $0.requestsAlternateRoutes = true
        }

        MKDirections(request: request).calculate { response, error in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            if let response = response {
                completionHandler(.success(response))
            } else if let error = error{
                completionHandler(.failure(error))
            }
        }
    }
}


/*
// TODO: - Route for Travel
extension Collection where Iterator.Element: CustomPointAnnotation {    
    
    typealias Distance = Double
    func getDistance(userPosition: CLLocation) -> [CustomPointAnnotation] {
        
        // MARK: - put the task to thread-pool and get the callback Bool
        
        let groupQueue = DispatchGroup()
        func calculateRoute(station: CustomPointAnnotation , complete: @escaping (Bool) -> () ) {
            
            var isPredicated: Bool = false
            groupQueue.enter()
            DispatchQueue.global().async {
                let sourcePlacemark = MKPlacemark(coordinate: userPosition.coordinate, addressDictionary: nil)
                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                
                // Get destination position
                let destinationCoordinates = CLLocationCoordinate2DMake(station.coordinate.latitude, station.coordinate.longitude)
                let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
                // Create request
                let request = MKDirectionsRequest()
                request.source = sourceMapItem
                request.destination = destinationMapItem
                request.transportType = MKDirectionsTransportType.automobile
                request.requestsAlternateRoutes = true
                let directions = MKDirections(request: request)
                
                directions.calculate { response, error in
                    
                    if let route = response?.routes.first {
                        isPredicated = 40...50 ~= route.distance.km ? true : false
                        
                    } else  {
                        print("Error: \(error!)")
                    }
                    groupQueue.leave()
                }
            }
            
            groupQueue.notify(queue: DispatchQueue.main) {
                complete(isPredicated)
            }
        }
        
        return self.filter { (station) -> Bool in
            
            let distance: Distance = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude).distance(from: userPosition).km
            
            return 40...50 ~= distance && !(station.title?.contains("建置中") ?? false)
            
            // TODO: Filter conditions
            }.filter { (station) -> Bool in
             var isPrediction = false
                calculateRoute(station: station) { isPrediction = $0 }
                let requestResult = groupQueue.wait(timeout: DispatchTime.now() + 5.0)
                
                switch requestResult {
                
                case .success:
                    return isPrediction
              
                case .timedOut:
                    return false
                }
                
        }
        
    }
}
*/
