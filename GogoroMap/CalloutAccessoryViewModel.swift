//
//  CalloutAccessoryViewModel.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/19.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import MapKit


struct CalloutAccessoryViewModel<Annotation: MKAnnotation> {
    let destination: Annotation
    
   
}


extension CalloutAccessoryViewModel where Annotation: BatteryDataModalProtocol {
    @discardableResult
    func bind(mapView: MKMapView, calloutView: DetailAnnotationView) -> DetailAnnotationView {
        
        
        calloutView.distanceLabel.text = "距離計算中..."
        calloutView.etaLabel.text = "時間計算中..."
        Navigator.travelETA(from: mapView.userLocation.coordinate, to: destination.coordinate) { (result) in
            var distance = "無法取得資料", travelTime = "無法取得資料"
            DispatchQueue.main.async {
                if case .success(let response) = result, let route = response.routes.first {
                    let (hours, minutes) = TimeInterval.travelTimeConvert(seconds: route.expectedTravelTime)
                    distance = "距離：\(String(format: "%.1f", route.distance/1000)) km "
                    travelTime = "約：" + (hours > 0 ? "\(hours) 小時 " : "") + "\(minutes) 分鐘 "
                }
                calloutView.distanceLabel.text = distance
                calloutView.etaLabel.text = travelTime
            }
        }
        
        return calloutView.configure(annotation: destination)
    }
}

