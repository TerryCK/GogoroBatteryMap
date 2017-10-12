//
//  Navigatorable.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/12.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit

protocol Navigatorable {
    func go(to destination: CustomPointAnnotation)
    func getETAData(completeHandler: @escaping MapRequestCompleted)
    typealias MapRequestCompleted = (String, String) -> Void
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
            } else  {
                completeHandler("無法取得資料", "無法取得資料")
                print("Error: \(error!)")
            }
        }

    }
}


// new feature

extension Collection where Iterator.Element: CustomPointAnnotation {
    func getDistance(userPosition: CLLocation) -> [CustomPointAnnotation] {
        return self.filter { (station) -> Bool in
            let distance: Double = CLLocation(latitude: station.coordinate.latitude, longitude: station.coordinate.longitude).distance(from: userPosition).km
            
            return 40...50 ~= distance && !(station.title?.contains("建置中") ?? false)
            
            }.filter { (station) -> Bool in
                var isPredicated: Bool = false
                
                let groupQueue = DispatchGroup()
                groupQueue.enter()
                DispatchQueue.global(qos: .default).async {
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
                 groupQueue.wait()
                return isPredicated
        }
    }
}

