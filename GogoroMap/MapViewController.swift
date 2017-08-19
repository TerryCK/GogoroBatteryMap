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
import Crashlytics
import GoogleMobileAds



final class MapViewController: UIViewController, MKMapViewDelegate, GADBannerViewDelegate, AnnotationHandleable, DataGettable {
    
    var currentUserLocation: CLLocation!
    var myLocationManager: CLLocationManager!
    var stationData: (totle: Int, available: Int) = (0, 0)
    
    
    var annotations = [MKAnnotation]() {
        didSet {
            DispatchQueue.main.async {
                
                self.mapView.addAnnotations(self.annotations)
                self.mapView.removeAnnotations(oldValue)
                
                // Mark: mapView remaind nil when annotations removed, so -1 to offset it.
                // Mark: check for avoid add annotation at same location which case too closeing to find
                
                let differential = Swift.abs(self.annotations.count - self.mapView.annotations.count)
                if differential > 1 {
                    print("")
                    print("error: annotation view count out of controller!!")
                    print("annotations: ", self.annotations.count, "mapView: ", self.mapView.annotations.count)
                    print("")
                }
            }
        }
    }
    
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
        let containerView = AdContainerView.shared
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
        getData()
        setupPurchase()
        
    }
    
    
    
    
    func setupPurchase() {
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            verifyPurchase(RegisteredPurchase.removeAds)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.logContentView(withName: "Map Page", contentType: nil, contentId: nil, customAttributes: nil)
        seupAdContainerView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }
    
    
    func performGuidePage() {
        if UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) { return }
        let guidePageController = GuidePageViewController()
        guidePageController.mapViewController = self
        present(guidePageController, animated: true, completion: nil)
    }
    
    func performMenu() {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Perform Menu"])
        if let sideManuController = SideMenuManager.menuLeftNavigationController {
            self.setTrackModeNone()
            present(sideManuController, animated: true, completion: nil)
        }
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
        
        
    }
    
    private func seupAdContainerView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Answers.logContentView(withName: "Ad View", contentType: nil, contentId: nil, customAttributes: nil)
            self.mapView.addSubview(self.adContainerView)
            self.adContainerView.anchor(top: nil, left: self.mapView.leftAnchor, bottom: self.mapView.bottomAnchor, right: self.mapView.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
        }
        
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
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Display annotation view"])
        self.selectedPin = view.annotation as? CustomPointAnnotation
    }
    
    func navigating() {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Navigate"])
        guard let destination = self.selectedPin else { return }
        go(to: destination)
    }
    
    func locationArrowPressed() {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Changing tracking mode"])
        locationArrowTapped()
    }
    
}



// MARK: verify purchase notification
extension MapViewController: IAPPurchasable {
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: RegisteredPurchase.observerName,
                                               object: nil)
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        print("MapViewController recieved notify")
        guard
            let productID = notification.object as? String,
            RegisteredPurchase.removedProductID == productID else {
                return
        }
        
        Answers.logCustomEvent(withName: Log.sharedName.purchaseEvents, customAttributes: [Log.sharedName.purchaseEvent: "Removed Ad"])
        adContainerView.removeFromSuperview()
        mapView.layoutIfNeeded()
    }
}

