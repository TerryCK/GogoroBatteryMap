//
//  Navigatorable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit

typealias MapRequestCompleted = (_ distance: String, _ expectedTravelTime: String) -> Void

protocol Navigatorable {
    func go(to destination: CustomPointAnnotation)
    func getETAData(completeHandler: @escaping MapRequestCompleted)
}


extension Navigatorable where Self: MapViewController {
    
    func go(to destination: CustomPointAnnotation) {
        let mapItem = MKMapItem(placemark: destination.placemark)
        mapItem.name = "\(destination.title!)(Gogoro \(NSLocalizedString("Battery Station", comment: "")))"
        print("mapItem.name \(String(describing: mapItem.name))")
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    func getETAData(completeHandler: @escaping MapRequestCompleted) {
        // Get current position
        let sourcePlacemark = MKPlacemark(coordinate: currentUserLocation.coordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        // Get destination position
        guard let coordinate = selectedPin?.coordinate else { return }
        
        let destinationCoordinates = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
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
                completeHandler("\(route.distance.km)", route.expectedTravelTime.convertToHMS)
            } else {
                completeHandler("無法取得資料", "無法取得資料")
                print("Error: \(error!)")
            }
        }
        
    }
}

typealias Distance = Double
extension CustomPointAnnotation {
    func getDistance(from userPosition: CLLocation) -> Distance {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: userPosition)
    }
}


extension Collection where Element: CustomPointAnnotation {
    
    func sortedByDistance(userPosition: CLLocation) -> [Element] {
        return self.sorted { $0.getDistance(from: userPosition) < $1.getDistance(from: userPosition) }
    }
}



// TODO: - Route for Travel
extension Collection where Iterator.Element: CustomPointAnnotation {
    
    ////    func getRouteStations(from start: CLLocation , to end: CustomPointAnnotation , maxDistance: Double) -> [CustomPointAnnotation] {
    ////
    ////    }
    //    
    //    func getTerminalStation(from start: CustomPointAnnotation , to end: CustomPointAnnotation , maxDistance: Double) -> [CustomPointAnnotation] {
    //        
    //        if start.toCLLocation.distance(from: end.toCLLocation) <= maxDistance {
    //            
    //        }
    //        
    //    }
    
    
    
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
