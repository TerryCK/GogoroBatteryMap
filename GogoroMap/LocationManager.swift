//
//  LocationManager.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2019/8/9.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import CoreLocation
import UIKit

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    static let shared = LocationManager()
    
    private let manager: CLLocationManager = CLLocationManager()
    
    func authorize() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        authorization(status: authorizationStatus)
    }
    
    func authorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            UIApplication.mapViewController?.setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        case .restricted, .denied, .notDetermined:
            let alert = UIAlertController(title: "LocationPermission".localize(),
                                          message: "LocationMessage".localize(),
                                          preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings".localize(), style: .default)  { _ in
                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                     UIApplication.shared.open(settingURL)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel".localize(), style: .default, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            alert.preferredAction = settingsAction
            UIApplication.mapViewController?.fpc.present(alert, animated: true, completion: nil)
        }
    }
    
    var userLocation: CLLocation? { manager.location }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorization(status: status)
    }
}
