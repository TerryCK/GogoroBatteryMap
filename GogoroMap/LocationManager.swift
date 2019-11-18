//
//  LocationManager.swift
//  GogoroMap
//
//  Created by CHEN GUAN-JHEN on 2019/8/9.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import CoreLocation

final class LocationManager {
    private init() {}
    static let shared = LocationManager()
    
    private let manager: CLLocationManager = {
        $0.distanceFilter = kCLLocationAccuracyNearestTenMeters
        $0.desiredAccuracy = kCLLocationAccuracyBest
        return $0
    }(CLLocationManager())
    
    func authorize(onComplete: (CLAuthorizationStatus) -> Void) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default: break
        }
        onComplete(CLLocationManager.authorizationStatus())
    }
    
    var userLocation: CLLocation? { manager.location }
}
