//
//  LocationManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit
import CoreLocation

extension MapViewController: CLLocationManagerDelegate {
    
    
    func authrizationStatus() {
        initializeLocationManager()
        
        let authrizationStatus = CLLocationManager.authorizationStatus()
        switch authrizationStatus {
            
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
            
        case .denied: //提示可以在設定中打開
            
            let alartTitle = "定位權限已關閉"
            let alartMessage = "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟"
            
            let alertController = UIAlertController(title: alartTitle, message: alartMessage, preferredStyle:.alert)
            
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        case .authorizedWhenInUse:
            myLocationManager.startUpdatingLocation()
            
        default:
            print("Location authrization error")
            break
            
        }
        
            self.setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
            self.mapView.userLocation.title = "😏目前位置"
        
    }
    
    
    func initializeLocationManager() {
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func setCurrentLocation(latDelta: Double, longDelta: Double) {
        let currentLocationSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        if let current = myLocationManager.location {
            self.userLocationCoordinate = current.coordinate
            print("取得使用者GPS位置")
        } else {
            let kaohsiungStationLocation = CLLocationCoordinate2D(latitude: 22.6384542, longitude: 120.3019452)
            self.userLocationCoordinate = kaohsiungStationLocation
            print("無法取得使用者位置、改取得高雄火車站GPS位置")
        }
        print("北緯：\(self.userLocationCoordinate.latitude) 東經：\(self.userLocationCoordinate.longitude)")
        let currentRegion = MKCoordinateRegion(center: currentUserLocation.coordinate, span: currentLocationSpan)
        mapView.setRegion(currentRegion, animated: false)
    }
    
    func locationArrowPressed() {
        
        switch mapView.userTrackingMode {
            
        case .none:
            setTrackModeToFollow()
            
        case .follow:
            setTrackModeToFollowWithHeading()
            
        case .followWithHeading:
            setTrackModeNone()
        }
        
    }
    
    @objc(mapView:didChangeUserTrackingMode:animated:) func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        switch (mapView.userTrackingMode) {
        case .none:
            locationArrowView.setImage(#imageLiteral(resourceName: "locationArrowNone"), for: .normal)
            print("tracking mode has changed to none")
            
        case .followWithHeading:
            locationArrowView.setImage(#imageLiteral(resourceName: "locationArrowFollewWithHeading"), for: .normal)
            print("tracking mode has changed to followWithHeading")
            
        case .follow:
            locationArrowView.setImage(#imageLiteral(resourceName: "locationArrow"), for: .normal)
            print("tracking mode has changed to follow")
        }
        
        print("userTracking mode has been charged")
    }
    
    func setTrackModeToFollowWithHeading() {
        setCurrentLocation(latDelta: 0.01, longDelta: 0.01)
        mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true)
    }
    
    func setTrackModeNone() {
        mapView.setUserTrackingMode(MKUserTrackingMode.none, animated: false)
    }
    
    func setTrackModeToFollow() {
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.last else { return }
        self.currentUserLocation = current
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            myLocationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }
    
}
