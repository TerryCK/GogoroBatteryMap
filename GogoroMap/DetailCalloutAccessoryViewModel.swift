//
//  CalloutAccessoryViewModel.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/19.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import MapKit
import Crashlytics
import GoogleMobileAds

struct DetailCalloutAccessoryViewModel {
    
    let annotationView: MKAnnotationView
    let controller: MapViewController
}

extension DetailCalloutAccessoryViewModel {
    
    private func checkinCount(with calculate: (Int, Int) -> Int, nativeAd: GADUnifiedNativeAd?) {
        Answers.log(event: .MapButton, customAttributes: #function)
        guard let batteryAnnotation = annotationView.annotation as? BatteryStationPointAnnotation else { return }
        let counterOfcheckin = calculate(batteryAnnotation.checkinCounter ?? 0, 1)
        batteryAnnotation.checkinDay = counterOfcheckin > 0 ? Date() : nil
        batteryAnnotation.checkinCounter = counterOfcheckin
        annotationView.image = batteryAnnotation.iconImage
        _ = (annotationView.detailCalloutAccessoryView as? DetailAnnotationView)?.configure(annotation: batteryAnnotation, nativeAd: nativeAd)
        (controller.selectedTabItem.tabContantController as? TableViewController)?.tableView.reloadData()
        DispatchQueue.global().async {
            if let index = DataManager.shared.originalStations.firstIndex(where: { $0.coordinate.hashValue == batteryAnnotation.coordinate.hashValue}) {
                DataManager.shared.originalStations[index] = batteryAnnotation
            }
        }
    }
    
    func bind(mapView: MKMapView, nativeAd: GADUnifiedNativeAd?) {
        guard let destination = annotationView.annotation as? BatteryStationPointAnnotation,
            let detailCalloutView = annotationView.detailCalloutAccessoryView as? DetailAnnotationView else {
                return
        }
        
        detailCalloutView.distanceLabel.text = "距離計算中..."
        detailCalloutView.etaLabel.text = "時間計算中..."
        Navigator.travelETA(from: mapView.userLocation.coordinate, to: destination.coordinate) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let  route = response.routes.first else { fallthrough }
                    let (hours, minutes) = TimeInterval.travelTimeConvert(seconds: route.expectedTravelTime)
                    let distance = "距離：\(String(format: "%.1f", route.distance/1000)) 公里 "
                    let travelTime = "約：" + (hours > 0 ? "\(hours) 小時 " : "") + "\(minutes) 分鐘 "
                    detailCalloutView.distanceLabel.text = distance
                    detailCalloutView.etaLabel.text = travelTime
                case .failure:
                    detailCalloutView.distanceLabel.text = nil
                    detailCalloutView.etaLabel.text = nil
                }
            }
        }
        detailCalloutView.checkinAction = { self.checkinCount(with: +, nativeAd: nativeAd) }
        detailCalloutView.uncheckinAction = { self.checkinCount(with: -, nativeAd: nativeAd) }
        detailCalloutView.goAction = { Navigator.go(to: destination) }
        detailCalloutView.configure(annotation: destination, nativeAd: nativeAd)
    }
}

