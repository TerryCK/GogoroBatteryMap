//
//  LocationManager.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import MapKit
import CoreLocation
import Crashlytics

protocol LocationManageable: MKMapViewDelegate {
    func authrizationStatus()
    func setCurrentLocation(latDelta: Double, longDelta: Double)
    func locationArrowTapped()
    func setTracking(mode: MKUserTrackingMode)
}

extension MapViewController: LocationManageable  {
    
    func authrizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        case .denied:
            let alertController = UIAlertController(title: "定位權限已關閉",
                                                    message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "確認", style: .default))
            present(alertController, animated: true, completion: nil)
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            
        default: break
        }
        
        setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        mapView.userLocation.title = "😏 \("here".localize())"
    }

    
    func setCurrentLocation(latDelta: Double, longDelta: Double) {
        currentUserLocation = locationManager.location ?? CLLocation(latitude: 25.047908, longitude: 121.517315)
        mapView.setRegion(MKCoordinateRegion(center: currentUserLocation.coordinate,
                                             span: MKCoordinateSpanMake(latDelta, longDelta)), animated: false)
    }
    
    func locationArrowTapped() {
        setTracking(mode: mapView.userTrackingMode.nextMode)
    }
    
    func setTracking(mode: MKUserTrackingMode) {
        if case .followWithHeading = mode { setCurrentLocation(latDelta: 0.01, longDelta: 0.01) }
        Answers.logCustomEvent(withName: "TrackingMode", customAttributes: ["TrackingMode" : "\(mode)"])
        mapView.setUserTrackingMode(mode, animated: mode == .followWithHeading)
        locationArrowView.setImage(mapView.userTrackingMode.arrowImage, for: .normal)
    }
}

extension MapViewController {
    
    @objc(mapView:didChangeUserTrackingMode:animated:) func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        locationArrowView.setImage(mapView.userTrackingMode.arrowImage, for: .normal)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let current = locations.last else { return }
        currentUserLocation = current
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MKUserTrackingMode: CustomStringConvertible {
    var arrowImage: UIImage {
        switch self {
        case .none:              return #imageLiteral(resourceName: "locationArrowNone")
        case .follow:            return #imageLiteral(resourceName: "locationArrow")
        case .followWithHeading: return #imageLiteral(resourceName: "locationArrowFollewWithHeading")
        }
    }
    
    public var description: String {
        switch self {
        case .none:              return "None"
        case .follow:            return "Follow"
        case .followWithHeading: return "Heading"
        }
    }
    
    public var nextMode: MKUserTrackingMode {
        return MKUserTrackingMode(rawValue: (rawValue + 1) % 3)!
    }
}
