//
//  ViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import MapKit
import SideMenu
import GoogleMobileAds

final class MapViewController: UIViewController, MKMapViewDelegate, GADBannerViewDelegate, AnnotationHandleable {
    
    var currentUserLocation: CLLocation!
    var myLocationManager: CLLocationManager!
    var stationData: (totle: Int, available: Int) = (0, 0)
    var hasUserPurchased = false
    
    fileprivate var selectedPin: CustomPointAnnotation?
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = false
        return mapView
    }()
    
    lazy var adContainerView: AdContainerView = {
        let containerView = AdContainerView()
        containerView.nativeAdView.delegate = self
        containerView.nativeAdView.rootViewController = self
        return containerView
    }()
    
    lazy var locationArrowView: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "locationArrowNone"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(locationArrowPressed), for: .touchUpInside)
        return button
        }()
    
    private lazy var menuBarButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "manuButton"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(performMenu), for: .touchUpInside)
        return button
        }()
    
    var userLocationCoordinate: CLLocationCoordinate2D! {
        get {
            return currentUserLocation.coordinate
        }
        set {
            currentUserLocation = CLLocation(latitude: newValue.latitude, longitude: newValue.longitude)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        performGuidePage()
        setupSideMenu()
        setupMapViewAndNavTitle()
        authrizationStatus()
        getDataOffline()

        setupPurchase()
    }
    
    func setupPurchase() {
        if UserDefaults.standard.bool(forKey: "hasPurchesd") {
            verifyPurchase(RegisteredPurchase.removeAds)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }
    
    
    func performGuidePage() {
        let hasReiewedGuidePage = UserDefaults.standard.bool(forKey: "hasReviewedGuidePage")
        guard !hasReiewedGuidePage else { return }
        let guidePageController = GuidePageViewController()
        guidePageController.mapViewController = self
        present(guidePageController, animated: true, completion: nil)
    }
    
    func performMenu() {
        if let sideManuController = SideMenuManager.menuLeftNavigationController {
            self.setTrackModeNone()
            present(sideManuController, animated: true, completion: nil)
        }
    }
    
    
    func getDataOffline() {
        guard
            let filePath = Bundle.main.path(forResource: "gogoro", ofType: "json"),
            let data = NSData(contentsOfFile: filePath) as Data?,
            let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let jsonDic = jsonDictionary?["data"] as? [[String: Any]] else { return }
        
        let stations = jsonDic.map { Station(dictionary: $0) }
        
        mapView.addAnnotations(getObjectArray(from: stations, userLocation: currentUserLocation))
        
        var stationsOfAvailable = 0
        
        stations.forEach { stationsOfAvailable += $0.state == 1 ? 1 : 0 }
        stationData = (totle: stations.count, available: stationsOfAvailable)
    }
    
    
    
    private func setupSideMenu() {
        let layout = UICollectionViewFlowLayout()
        let menuController = MenuController(collectionViewLayout: layout)
        menuController.mapViewController = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuController)
        SideMenuManager.menuLeftNavigationController?.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        setSideMenuDefalts()
    }
    
    private func setSideMenuDefalts() {
        SideMenuManager.menuFadeStatusBar = true
        SideMenuManager.menuShadowOpacity = 0.59
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.75)
        SideMenuManager.menuAnimationTransformScaleFactor = 0.95
        SideMenuManager.menuAnimationFadeStrength = 0.40
        SideMenuManager.menuBlurEffectStyle = nil
        SideMenuManager.menuPresentMode = .viewSlideInOut
    }
    
    
    private func setupMapViewAndNavTitle() {
        navigationItem.title = "Gogoro 電池交換站地圖"
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor.lightGreen
        navigationController?.view.layer.cornerRadius = 3
        navigationController?.view.layer.masksToBounds = true
        
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
        
        navigationController?.view.addSubview(locationArrowView)
        locationArrowView.anchor(top: navigationController?.view.topAnchor, left: nil, bottom: nil, right: navigationController?.view.rightAnchor, topPadding: 23, leftPadding: 0, bottomPadding: 0, rightPadding: 8, width: 50, height: 38)
        
        navigationController?.view.addSubview(menuBarButton)
        menuBarButton.anchor(top: navigationController?.view.topAnchor, left: navigationController?.view.leftAnchor, bottom: nil, right: nil, topPadding: 23, leftPadding: 8, bottomPadding: 0, rightPadding: 0, width: 50, height: 38)
        
        seupAdContainerView()
    }
    
    private func seupAdContainerView() {
        mapView.addSubview(adContainerView)
        adContainerView.anchor(top: nil, left: mapView.leftAnchor, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
    }
    func locationArrowPressed() {
        locationArrowTapped()
    }
}


// Mark: present annotationView
extension MapViewController: Navigatorable {
    
    @objc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        let identifier = "station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation
        }
        
        guard
            let customAnnotation = annotation as? CustomPointAnnotation,
            let distance = Double(customAnnotation.distance ?? "0") else { return nil }
        
        let subTitleView = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: distance > 100 ? 40 : 28, height: 40)))
        subTitleView.font = subTitleView.font.withSize(12)
        subTitleView.textAlignment = .right
        subTitleView.numberOfLines = 0
        subTitleView.textColor = .gray
        
        subTitleView.text = "\(distance) km"
        annotationView?.image = customAnnotation.image
        
        
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 43, height: 43)))
        button.setBackgroundImage(#imageLiteral(resourceName: "go").withRenderingMode(.alwaysOriginal), for: UIControlState())
        
        button.addTarget(self, action: #selector(MapViewController.navigating), for: .touchUpInside)
        
        annotationView?.rightCalloutAccessoryView = button
        annotationView?.leftCalloutAccessoryView = subTitleView
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedPin = view.annotation as? CustomPointAnnotation
    }
    
    func navigating() {
        guard let destination = self.selectedPin else { return }
        go(to: destination)
    }
}



// MARK: verify purchase notification
extension MapViewController: IAPPurchasable {
    
    fileprivate func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: RegisteredPurchase.observerName,
                                               object: nil)
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        print("MapViewController recieved notify")
        guard let productID = notification.object as? String,
            RegisteredPurchase.removedProductID == productID else {
                hasUserPurchased = false
                return
        }
        
        hasUserPurchased = true
        adContainerView.removeFromSuperview()
        mapView.layoutIfNeeded()
    }
    
    

}
