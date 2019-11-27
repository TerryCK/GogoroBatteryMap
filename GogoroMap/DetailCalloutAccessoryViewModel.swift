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
    
    let annotationView: MKAnnotationView?
    let detailCalloutView: DetailAnnotationView?
    let batteryAnnotation: BatteryStationPointAnnotation?
    
    init(annotationView: MKAnnotationView) {
        self.annotationView    = annotationView
        self.batteryAnnotation = annotationView.annotation as? BatteryStationPointAnnotation
        self.detailCalloutView = annotationView.detailCalloutAccessoryView as? DetailAnnotationView
        guard let destination = batteryAnnotation else { return }
        
        detailCalloutView?.goAction = { Navigator.go(to: destination) }
        detailCalloutView?.configure(annotation: destination)
    }
}



extension DetailCalloutAccessoryViewModel {
    
    private func checkinCount(with calculate: @escaping (Int, Int) -> Int) {
        Answers.log(event: .MapButton, customAttributes: #function)
        guard let batteryAnnotation = batteryAnnotation else { return }
        let counterOfcheckin = calculate(batteryAnnotation.checkinCounter ?? 0, 1)
        batteryAnnotation.checkinDay = counterOfcheckin > 0 ? Date() : nil
        batteryAnnotation.checkinCounter = counterOfcheckin
        annotationView?.image = batteryAnnotation.iconImage
        detailCalloutView?.configure(annotation: batteryAnnotation)
        
        DispatchQueue(label: "com.GogoroMap.StationListQueue").async {
            DataManager.shared.unchecks.update(counterOfcheckin <= 0 ? .sync : .remove, batteryAnnotation)
            DataManager.shared.checkins.update(counterOfcheckin <= 0 ? .remove : .sync, batteryAnnotation)
            DataManager.shared.operations.update(.sync, batteryAnnotation)
            DataManager.shared.lastUpdate = Date()
        }
    }
    
    func bind() {
        guard let destination = batteryAnnotation,
            let detailCalloutView = detailCalloutView else { return }
        detailCalloutView.setupNativeAd()
        detailCalloutView.checkinAction =   { self.checkinCount(with: +) }
        detailCalloutView.uncheckinAction = { self.checkinCount(with: -) }

        guard let userLocation = LocationManager.shared.userLocation?.coordinate else {
            detailCalloutView.distanceLabel.text = "無法取得目前位置"
            detailCalloutView.etaLabel.text = .denied != LocationManager.shared.status ? "LocationPermission".localize() : ""
            return
        }
        detailCalloutView.distanceLabel.text = "距離計算中..."
        detailCalloutView.etaLabel.text = "時間計算中..."
        
        Navigator.travelETA(from: userLocation, to: destination.coordinate) { (result) in
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
                    detailCalloutView.distanceLabel.text = "無法取得路線"
                    detailCalloutView.etaLabel.text = "無法估算時間"
                }
            }
        }
    }
}

