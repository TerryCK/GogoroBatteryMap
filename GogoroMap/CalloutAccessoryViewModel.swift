//
//  CalloutAccessoryViewModel.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/19.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import MapKit
import Crashlytics

struct CalloutAccessoryViewModel {
    let destinationView: MKAnnotationView
}


extension CalloutAccessoryViewModel {
    private func checkinCount(with calculate: (Int, Int) -> Int) {
        Answers.log(event: .MapButtons, customAttributes: #function)
        guard let batteryAnnotation = destinationView.annotation as? BatteryStationPointAnnotation else { return }
        let counterOfcheckin = calculate(batteryAnnotation.checkinCounter ?? 0, 1)
        batteryAnnotation.checkinDay = counterOfcheckin > 0 ? Date() : nil
        batteryAnnotation.checkinCounter = counterOfcheckin
        destinationView.image = batteryAnnotation.iconImage
        _ = (destinationView.detailCalloutAccessoryView as? DetailAnnotationView)?.configure(annotation: batteryAnnotation)
        
    }

    func bind(mapView: MKMapView) {
        guard let destination = mapView.selectedAnnotations.first as? BatteryStationPointAnnotation,
            let detailCalloutView = destinationView.detailCalloutAccessoryView as? DetailAnnotationView else {
                return
        }
        detailCalloutView.distanceLabel.text = "距離計算中..."
        detailCalloutView.etaLabel.text = "時間計算中..."
        Navigator.travelETA(from: mapView.userLocation.coordinate, to: destination.coordinate) { (result) in
            var distance = "無法取得資料", travelTime = "無法取得資料"
            DispatchQueue.main.async {
                if case .success(let response) = result, let route = response.routes.first {
                    let (hours, minutes) = TimeInterval.travelTimeConvert(seconds: route.expectedTravelTime)
                    distance = "距離：\(String(format: "%.1f", route.distance/1000)) km "
                    travelTime = "約：" + (hours > 0 ? "\(hours) 小時 " : "") + "\(minutes) 分鐘 "
                }
                detailCalloutView.distanceLabel.text = distance
                detailCalloutView.etaLabel.text = travelTime
            }
        }
        detailCalloutView.checkinAction = { self.checkinCount(with: +) }
        detailCalloutView.uncheckinAction = { self.checkinCount(with: -) }
        detailCalloutView.goAction = { Navigator.go(to: destination) }
        detailCalloutView.configure(annotation: destination)
    }
}

