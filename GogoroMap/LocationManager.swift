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
    
    static let shared = LocationManager()
    
    private var manager: CLLocationManager? {
        didSet {
            manager?.distanceFilter = kCLLocationAccuracyNearestTenMeters
            manager?.desiredAccuracy = kCLLocationAccuracyBest
            manager?.delegate = self
        }
    }
    
    func authorize() {
        if manager == nil { manager = CLLocationManager() }
    }
    
    var status: CLAuthorizationStatus? {
        didSet {
            if [.authorizedWhenInUse, .authorizedAlways].contains(status) {
                DataManager.shared.sorting()
            }
        }
    }
    
    
    func authorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager?.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            manager?.startUpdatingLocation()
            UIApplication.mapViewController?.setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
            
        case .restricted, .denied, _:
            let alert = UIAlertController(title: "LocationPermission".localize(),
                                          message: "LocationMessage".localize(),
                                          preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings".localize(), style: .default)  { _ in
                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingURL)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Ignore".localize(), style: .default, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            alert.preferredAction = settingsAction
            UIApplication.mapViewController?.fpc?.present(alert, animated: true, completion: nil)
        }
        
        guard let mapViewController = UIApplication.mapViewController else { return }
        if  mapViewController.fpc?.parent != mapViewController {
            mapViewController.fpc?.addPanel(toParent: mapViewController , animated: true)
        }
        
    }
    
    var userLocation: CLLocation? { manager?.location }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
        authorization(status: status)
    }
}
