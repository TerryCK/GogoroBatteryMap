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

protocol ManuDelegate: class {
    func getAnnotationFromRemote(_ completeHandle: CompleteHandle?)
    var  stationData: (totle: Int, available: Int, hasFlags: Int, hasCheckins: Int) { get set }
}


final class MapViewController: UIViewController, MKMapViewDelegate, AnnotationHandleable, DataGettable, ManuDelegate {
    
    var currentUserLocation: CLLocation!
    var myLocationManager: CLLocationManager!
    var stationData: (totle: Int, available: Int, hasFlags: Int, hasCheckins: Int) = (0, 0, 0, 0)
    
    
    
    fileprivate var selectedAnnotationView: MKAnnotationView? =  MKAnnotationView()
    fileprivate var detailView = DetailAnnotationView()
    
    var index: Int = 0
    var selectedPin: CustomPointAnnotation?
    
    var willRemovedAnnotations = [CustomPointAnnotation]() {
        didSet {
            if willRemovedAnnotations.count > 0 {
                self.mapView.removeAnnotations(willRemovedAnnotations)
            }
            self.matchForAnnotationCorrect(annotationsCounter: self.annotations.count, mapViewsAnnotationsCounter: self.mapView.annotations.count)
        }
        
    }
    
    var annotations = [CustomPointAnnotation]() {
        didSet {
            saveToDatabase(with: annotations)
            updateSummaryInfo()
            
            self.mapView.addAnnotations(self.annotations)
            print("annotations did set")
        }
    }
    
    private func updateSummaryInfo() {
        var stationsOfAvailable = 0
        var hasFlags = 0
        var hasCheckins = 0
        
        annotations.forEach {
            stationsOfAvailable += $0.isOpening ? 1 : 0
            hasFlags += $0.checkinCounter > 0 ? 1 : 0
            hasCheckins += $0.checkinCounter
        }
        
        stationData.totle = annotations.count
        stationData.hasFlags = hasFlags
        stationData.available = stationsOfAvailable
        stationData.hasCheckins = hasCheckins
        
    }
    
    
    
    private func matchForAnnotationCorrect(annotationsCounter: Int, mapViewsAnnotationsCounter: Int) {
        // Mark: mapView remaind nil when annotations removed, so -1 to offset it.
        // Mark: check for avoid add annotation at same location which case too closeing to find
        
        let differential = Swift.abs(annotationsCounter - mapViewsAnnotationsCounter)
        if differential > 1 {
             
            print("")
            print("error: annotation view count out of controller!!")
            print("annotations:", annotationsCounter, " mapView:", mapViewsAnnotationsCounter)
            print("")
        } else {
            print(" ** annotation view count currect ** ")
        }
        
        
    }
    
    
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
        initializeData()
        setupPurchase()
        
                    
//                #if DEBUG
//        
//                    let activity = selectedPin?.userActivity
//                    activity?.isEligibleForPublicIndexing = true
//                    activity?.isEligibleForSearch = true
//        
//                    userActivity = activity
//        
//                #endif
    
    }

    
    
    
    func checkin() {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Check in"])
        let checkinCounter = annotations[index].checkinCounter + 1
        detailView.timesOfCheckinLabel.text = "打卡：\(checkinCounter) 次"
        detailView.lastCheckTimeLabel.text = "最近的打卡日：\(Date.today)"
        annotations[index].checkinCounter = checkinCounter
        annotations[index].checkinDay = Date.today
        
        if checkinCounter > 0 && annotations[index].image != #imageLiteral(resourceName: "checkin") {
            selectedAnnotationView?.image = #imageLiteral(resourceName: "checkin")
            annotations[index].image = selectedAnnotationView?.image
            detailView.buttonStackView.addArrangedSubview(detailView.unCheckinButton)
            
        }
        post()
        saveToDatabase(with: annotations)
    }
    
    func unCheckin() {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Remove check in"])
        let checkinCounter = annotations[index].checkinCounter - 1
        detailView.timesOfCheckinLabel.text = "打卡：\(checkinCounter) 次"
        annotations[index].checkinCounter = checkinCounter
        
        if checkinCounter == 0 {
            selectedAnnotationView?.image = #imageLiteral(resourceName: "pinFull")
            annotations[index].image = selectedAnnotationView?.image
            annotations[index].checkinDay = ""
            detailView.buttonStackView.removeArrangedSubview(detailView.unCheckinButton)
            detailView.lastCheckTimeLabel.text = "最近的打卡日："
            
        }
        post()
        saveToDatabase(with: annotations)
    }
    
    func post() {
        updateSummaryInfo()
        NotificationCenter.default.post(name: NotificationName.shared.manuContent, object: nil)
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
        guidePageController.delegate = self
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
        menuController.delegate = self
//        guard let navigationController = self.navigationController else { return }
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuController)
        SideMenuManager.menuLeftNavigationController?.leftSide = true
        
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
//        SideMenuManager.menuAddPanGestureToPresent(toView: navigationController.navigationBar)
//        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: navigationController.view)
        SideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        setSideMenuDefalts()
    }
    
    private func setSideMenuDefalts() {
        SideMenuManager.menuFadeStatusBar = true
        SideMenuManager.menuShadowOpacity = 0.59
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.80)
        SideMenuManager.menuAnimationTransformScaleFactor = 0.95
        SideMenuManager.menuAnimationFadeStrength = 0.40
        SideMenuManager.menuBlurEffectStyle = nil
        SideMenuManager.menuPresentMode = .viewSlideInOut
    }
    
    
    private func setupMapViewAndNavTitle() {
        navigationItem.title = "Gogoro " + NSLocalizedString("Battery Station", comment: "")
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor.lightGreen

        
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
        
        
        guard let customAnnotation = annotation as? CustomPointAnnotation else { return nil }
        let detailView: DetailAnnotationView = DetailAnnotationView(with: customAnnotation)
        
        detailView.goButton.addTarget(self, action: #selector(navigating), for: .touchUpInside)
        detailView.checkinButton.addTarget(self, action: #selector(checkin), for: .touchUpInside)
        detailView.unCheckinButton.addTarget(self, action: #selector(unCheckin), for: .touchUpInside)
        
        annotationView?.image = customAnnotation.checkinCounter > 0 ? #imageLiteral(resourceName: "checkin") : customAnnotation.image
        annotationView?.detailCalloutAccessoryView = detailView
        
        return annotationView
        
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons,
                               customAttributes: [Log.sharedName.mapButton: "Display annotation view"])
        self.selectedAnnotationView = view
        
        guard
            let annotation = view.annotation as? CustomPointAnnotation,
            let detailCalloutView = view.detailCalloutAccessoryView as? DetailAnnotationView,
            let index = annotations.index(of: annotation) else { return }
        
        self.selectedPin = annotation
        self.index = index
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        detailCalloutView.distanceLabel.text = "計算中..."
        detailCalloutView.etaLabel.text = "計算中..."
        self.detailView = detailCalloutView
        
        
        getETAData { (distance, travelTime) in
            DispatchQueue.main.async {
                detailCalloutView.distanceLabel.text = "距離：\(distance) km "
                detailCalloutView.etaLabel.text = "約：\(travelTime)"
                NetworkActivityIndicatorManager.shared.networkOperationFinished()
            }
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .heavyBlue
        
        return renderer
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
                                               name: NotificationName.shared.removeAds,
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

extension MapViewController: GuidePageViewControllerDelegate {
    
}
