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
}

typealias MapRequestCompleted = (String, String) -> Void

extension Navigatorable where Self: MapViewController {
    
    func go(to destination: CustomPointAnnotation) {
        let mapItem = MKMapItem(placemark: destination.placemark)
        mapItem.name = "\(destination.title!)(Gogoro \(NSLocalizedString("Battery Station", comment: "")))"
        print("mapItem.name \(String(describing: mapItem.name))")
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    func getETAData(completeHandler: @escaping MapRequestCompleted) {
        // Get current position
        let sourcePlacemark = MKPlacemark(coordinate: self.currentUserLocation.coordinate, addressDictionary: nil)
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
//            defer {   print(response?.routes.count) }
            if let route = response?.routes.first {
                completeHandler(route.distance.km, route.expectedTravelTime.convertToHMS)
            } else  {
                completeHandler("無法取得資料", "無法取得資料")
                print("Error: \(error!)")
            }
            
            
            
            
            
            
            
//            guard let unwrappedResponse = response else { return }
//            var count = 0
//            for route in unwrappedResponse.routes {
//                print("第\(count)條")
//                route.steps.forEach {
//                    print(" 指示：\($0.instructions) \n 座標：\($0.polyline.coordinate) \n距離：\($0.distance.km) km  \($0.notice?.description)\n\n ")
//                    
//                }
//                    count += 1
//                
//                if route.expectedTravelTime > 3600 {
//                    print("route.expectedTravelTime:", route.expectedTravelTime.convertToHMS)
//                }
//                self.mapView.add(route.polyline)
//                if self.mapView.overlays.count == 1 {
//                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
//                                              edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
//                                              animated: false)
//                }
//                    // 3
//                else {
//                    let polylineBoundingRect =  MKMapRectUnion(self.mapView.visibleMapRect,
//                                                               route.polyline.boundingMapRect)
//                    self.mapView.setVisibleMapRect(polylineBoundingRect,
//                                              edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
//                                              animated: false)
//                }
//            }
//            
//            
        }

    }
}

