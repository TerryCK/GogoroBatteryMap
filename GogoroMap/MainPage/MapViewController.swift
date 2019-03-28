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
import Cluster
import CloudKit

final class MapViewController: UIViewController, MKMapViewDelegate, ManuDelegate, MenuDataSource, GuidePageViewControllerDelegate, CLLocationManagerDelegate {
    
    var currentUserLocation: CLLocation!
    
    lazy var locationManager = CLLocationManager {
        $0.delegate = self
        $0.distanceFilter = kCLLocationAccuracyNearestTenMeters
        $0.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    var clusterSwitcher = ClusterStatus() {
        didSet {
            clusterManager.maxZoomLevel = clusterSwitcher == .on ? 16 : 8
            reloadMapView()
        }
    }
    
    func reloadMapView() {
        DispatchQueue.main.async {
            self.clusterManager.reload(self.mapView, visibleMapRect: self.mapView.visibleMapRect)
        }
    }
    
    var listToDisplay = [BatteryStationPointAnnotation]() {
        didSet {
            cellEmptyGuideView.isHidden = !listToDisplay.isEmpty
            collectionView.isHidden = listToDisplay.isEmpty
            if !listToDisplay.isEmpty { collectionView.reloadData() }
        }
    }
    
    let cellEmptyGuideView = UITextView {
        $0.text = "目前尚未有符合資料可顯示..."
        $0.font = .systemFont(ofSize: 32)
        $0.textAlignment = .center
        $0.isEditable = false
        $0.isHidden = true
    }
    
    private var selectedAnnotationView: MKAnnotationView? = nil
    
    //     MARK: - View Creators
    private lazy var clusterManager: ClusterManager = {
        let cm = ClusterManager()
        cm.maxZoomLevel = clusterSwitcher == .on ? 16 : 8
        cm.minCountForClustering = 3
        cm.add(batteryStationPointAnnotations)
        return cm
    }()
    
    lazy var mapView = MKMapView {        
        $0.delegate = self
        $0.mapType = .standard
        $0.showsUserLocation = true
        $0.isZoomEnabled = true
        $0.showsCompass = true
        $0.showsScale = true
        $0.showsTraffic = false
    }
    
    lazy var adContainerView: AdContainerView = {
        AdContainerView.shared.nativeAdView.delegate = self
        AdContainerView.shared.nativeAdView.rootViewController = self
        return AdContainerView.shared
    }()
    
    lazy var locationArrowView: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "locationArrowNone"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(locationArrowPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var menuBarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "manuButton"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(MapViewController.performMenu), for: .touchUpInside)
        return button
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        SegmentStatus.items.forEach {
            sc.insertSegment(withTitle: $0.name,
                             at: $0.rawValue,
                             animated: false)
        }
        
        sc.selectedSegmentIndex = 0
        sc.tintColor = .white
        sc.addTarget(self,
                     action: #selector(MapViewController.segmentChange),
                     for: .valueChanged)
        return sc
    }()
    
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout {
            $0.itemSize = CGSize(width: view.frame.width, height: 70)
            $0.minimumInteritemSpacing = 0
            $0.minimumLineSpacing = 0
        }
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyCollectionViewCell.self))
        cv.isHidden = true
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return cv
    }()
    
    private lazy var segmentControllerContainer = UIView { $0.backgroundColor = .lightGreen }
    
/*
    private lazy var testButton1 : UIButton = {
        let myButton = UIButton(type: .system)
        myButton.setTitle("save", for: .normal)
        myButton.backgroundColor = .lightBlue
        myButton.titleLabel?.textColor = .white
        myButton.addTarget(self, action: #selector(saveTest), for: .touchUpInside)
        return myButton
    }()
    
    private lazy var testButton2 : UIButton = {
        let myButton = UIButton(type: .system)
        myButton.setTitle("query", for: .normal)
        myButton.backgroundColor = .lightBlue
        myButton.titleLabel?.textColor = .white
        myButton.addTarget(self, action: #selector(queryTest), for: .touchUpInside)
        return myButton
    }()
    
    private lazy var testStack: UIStackView = {
        let myStack = UIStackView(arrangedSubviews: [testButton1,testButton2])
        myStack.axis = .horizontal
        myStack.distribution = .fillEqually
        myStack.alignment = .center
        myStack.spacing = 10
        return myStack
    }()
    */
    
    override func loadView() {
        super.loadView()
        setupNavigationTitle()
        setupNavigationItems()
        setupSegmentControllerContainer()
        setupMainViews()
        setupSideMenu()
    }

    
    func dataUpdate(onCompletion: (() -> Void)? = nil) {
        DataManager.shared.fetchStations { [weak self] (result) in
            if case let .success(remote) = result {
                self?.batteryStationPointAnnotations.keepOldUpdate(with: remote)
            }
            onCompletion?()
        }
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        performGuidePage()
        authrizationStatus()
        setupPurchase()
        dataUpdate()
//        setupAdContainerView()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
//
//            self.batteryStationPointAnnotations = DataManager.shared.initialData ?? []
//            self.reloadMapView()
//        })
        
//
        
//
        
        
        Answers.log(view: "Map Page")
//        DispatchQueue.main.asyncAfter(deadline:  .now() + 0.5, execute: setupAdContainerView)
        
        #if REALEASE
        setupRating()
        #endif
        //        testFunction()
    }
    
   
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func resignApp(_ notification: Notification) {
        guard case .UIApplicationDidEnterBackground = notification.name else { return }
        locationManager.stopUpdatingLocation()
        DataManager.shared.saveToDatabase(with: batteryStationPointAnnotations)
    }
    
    var batteryStationPointAnnotations = DataManager.shared.initialData ?? [] {
        willSet {
            clusterManager.removeAll()
            clusterManager.add(newValue)
            reloadMapView()
        }
    }
    
    //     MARK: - Perfrom
    func performGuidePage() {
        if UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) { return }
        present(GuidePageViewController { $0.delegate = self }, animated: true)
    }
    
    @objc func performMenu() {
        Answers.log(event: .MapButtons, customAttributes: "Perform Menu")
        if let sideManuController = SideMenuManager.default.menuLeftNavigationController {
            setTracking(mode: .none)
            present(sideManuController, animated: true, completion: nil)
        }
    }
    
    //     MARK: - View setups
    private func setupSideMenu(sideMenuManager: SideMenuManager = .default, displayFactor: CGFloat = 0.8) {
        
        let flowLyout = UICollectionViewFlowLayout {
            $0.itemSize = CGSize(width: view.frame.width * displayFactor - 20 , height: view.frame.height - 90)
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
        }
        
        let menuController = MenuController(collectionViewLayout: flowLyout)
        menuController.delegate = self
        menuController.dataSource = self
        sideMenuManager.menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuController)
        sideMenuManager.menuLeftNavigationController?.leftSide = true
        sideMenuManager.menuAnimationBackgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        sideMenuManager.menuFadeStatusBar = true
        sideMenuManager.menuShadowOpacity = 0.59
        sideMenuManager.menuWidth = view.frame.width * displayFactor
        sideMenuManager.menuAnimationTransformScaleFactor = 0.95
        sideMenuManager.menuAnimationFadeStrength = 0.40
        sideMenuManager.menuBlurEffectStyle = nil
        sideMenuManager.menuPresentMode = .viewSlideInOut
    }
    
    private func setupNavigationTitle() {
        navigationItem.title = "Gogoro \("Battery Station".localize())"
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = .lightGreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
    
    private func setupNavigationItems() {
        guard let navigationController = navigationController else { return }
        [locationArrowView,  menuBarButton].forEach(navigationController.view.addSubview)
        let sidePading: CGFloat = 8, height: CGFloat = 38,  width: CGFloat = 50
        var topAnchor: NSLayoutYAxisAnchor = navigationController.view.topAnchor
        var topPadding: CGFloat = 23
        
        if #available(iOS 11.0, *) {
            topAnchor = navigationController.view.safeAreaLayoutGuide.topAnchor
            topPadding = 0
            setupBottomBackgroundView()
        }
        locationArrowView.anchor(top: topAnchor, left:  nil, bottom: nil, right:  navigationController.view.rightAnchor, topPadding: topPadding, leftPadding: 0, bottomPadding: 0, rightPadding: sidePading, width: width, height: height)
        menuBarButton.anchor(top: topAnchor, left: navigationController.view.leftAnchor, bottom: nil, right: nil, topPadding: topPadding, leftPadding: sidePading, bottomPadding: 0, rightPadding: 0, width: width, height: height)
    }
    
    private func setupRating() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    private func setupMainViews() {
        [mapView, collectionView, cellEmptyGuideView].forEach { (myView: UIView) in
            view.addSubview(myView)
            myView.anchor(top: segmentControllerContainer.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }
    }
    
    private func setupSegmentControllerContainer() {
        view.addSubview(segmentControllerContainer)
        var topAnchor = view.topAnchor
        if #available(iOS 11, *) { topAnchor = view.safeAreaLayoutGuide.topAnchor }
        segmentControllerContainer.anchor(top: topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 44)
        segmentControllerContainer.addSubview(segmentedControl)
        segmentedControl.anchor(top: segmentControllerContainer.topAnchor, left: segmentControllerContainer.leftAnchor, bottom: segmentControllerContainer.bottomAnchor, right: segmentControllerContainer.rightAnchor, topPadding: 10, leftPadding: 10, bottomPadding: 10, rightPadding: 10, width: 0, height: 0)
    }
    
    private func setupAdContainerView() {
        Answers.log(view: "Ad View")
        view.addSubview(adContainerView)
        var bottomAnchor = view.bottomAnchor
        if #available(iOS 11.0, *) { bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor }
        adContainerView.anchor(top: nil, left: view.leftAnchor, bottom: bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
    }
    
    private func setupBottomBackgroundView() {
        let backgroundView = UIView {  $0.backgroundColor = .lightGreen }
        view.addSubview(backgroundView)
        backgroundView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 40)
    }
}

// MARK: - UICollectionViewDataSource
extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyCollectionViewCell.self), for: indexPath) as! MyCollectionViewCell).configure(index: indexPath.item, station: listToDisplay[indexPath.item], userLocation: currentUserLocation)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Answers.logCustomEvent(withName: Log.sharedName.mapButtons, customAttributes: [Log.sharedName.mapButton: "Pressd CellView"])
        let seletedItem = listToDisplay[indexPath.item]
        segmentedControl.selectedSegmentIndex = 0
        segmentChange(sender: segmentedControl)
        if !mapView.annotations.contains { $0.title ?? ""  == seletedItem.title } { mapViewMove(to: seletedItem) }
        mapView.selectAnnotation(seletedItem, animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    private func mapViewMove(to station: MKPointAnnotation) {
        Answers.log(event: .MapButtons, customAttributes: "mapViewMove")
        let annotationPoint = MKMapPointForCoordinate(station.coordinate).centerOfScreen
        let factor = 0.7, height = 20000.0
        let width = factor * height
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, width, height)
        mapView.setVisibleMapRect(pointRect, animated: false)
    }
}

//MARK: - Checkin functions
extension MapViewController {

    private func checkinCount(with calculate: (Int, Int) -> Int, log: String) {
        Answers.log(event: .MapButtons, customAttributes: log)
        guard let batteryAnnotation = selectedAnnotationView?.annotation as? BatteryStationPointAnnotation else { return }
        let counterOfcheckin = calculate(batteryAnnotation.checkinCounter ?? 0, 1)
        batteryAnnotation.checkinDay = counterOfcheckin > 0 ? Date.today : ""
        batteryAnnotation.checkinCounter = counterOfcheckin
        selectedAnnotationView?.image = batteryAnnotation.iconImage
        (selectedAnnotationView?.detailCalloutAccessoryView as? DetailAnnotationView)?.setup(with: counterOfcheckin)
    }
    
    @objc func checkin()   { checkinCount(with: +, log: "Check in") }
    
    @objc func unCheckin() { checkinCount(with: -, log: "Remove check in") }
}

//MARK: - Lists of function annotations
extension MapViewController {
    @objc func segmentChange(sender: UISegmentedControl) {
        let segmentStatus = SegmentStatus.items[sender.selectedSegmentIndex]
        Answers.log(event: .MapButtons, customAttributes: segmentStatus.eventName)
        mapView.isHidden            = segmentStatus != .map
        collectionView.isHidden     = segmentStatus == .map
        locationArrowView.isEnabled = segmentStatus == .map
        cellEmptyGuideView.isHidden = segmentStatus == .map
        setTracking(mode: .none)
        guard segmentStatus != .map else { return }
        listToDisplay = segmentStatus.annotationsToDisplay(annotations: batteryStationPointAnnotations,
                                                           currentUserLocation: currentUserLocation)
    }
}

//MARK: - Present annotationView and Navigatorable
extension MapViewController {
    
    @objc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let clusterAnnotation = annotation as? ClusterAnnotation else {
            return originalMKAnnotationView(mapView, viewFor: annotation)
        }
        
        let style = ClusterAnnotationStyle.color(.grassGreen, radius: 36)
        let identifier = "Cluster"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if let view = view as? BorderedClusterAnnotationView {
            view.annotation = clusterAnnotation
            view.configure(with: style)
        } else {
            view = ClusterAnnotationView(annotation: clusterAnnotation, reuseIdentifier: identifier, style: style)
        }
        return view
    }
    
    
    //MARK: - Original MKAnnotationView
    private func originalMKAnnotationView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        let identifier = "station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        guard let batteryStation = annotation as? BatteryStationPointAnnotation else { return nil }
        annotationView?.image = batteryStation.iconImage
        
        annotationView?.detailCalloutAccessoryView = DetailAnnotationView {
            $0.goButton.addTarget(self, action: #selector(MapViewController.navigating), for: .touchUpInside)
            $0.checkinButton.addTarget(self, action: #selector(MapViewController.checkin), for: .touchUpInside)
            $0.unCheckinButton.addTarget(self, action: #selector(MapViewController.unCheckin), for: .touchUpInside)
            }.configure(annotation: batteryStation)
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let clusterAnnotation = view.annotation as? ClusterAnnotation {
            clusterSetVisibleMapRect(with: clusterAnnotation)
            selectedAnnotationView = nil
            return
        }
        
        Answers.log(event: .MapButtons, customAttributes: "Display annotation view")
        selectedAnnotationView = view
        guard let destination = view.annotation?.coordinate,
            let detailCalloutView = view.detailCalloutAccessoryView as? DetailAnnotationView else {
                return
        }
        NetworkActivityIndicatorManager.shared.networkOperationStarted()
        detailCalloutView.distanceLabel.text = "距離計算中..."
        detailCalloutView.etaLabel.text = "時間計算中..."
        Navigator.travelETA(from: currentUserLocation.coordinate, to: destination) { (result) in
            NetworkActivityIndicatorManager.shared.networkOperationFinished()
            var distance = "無法取得資料", travelTime = "無法取得資料"
            DispatchQueue.main.async {
                if case .success(let response) = result, let route = response.routes.first {
                    distance = "距離：\(String(format: "%.1f", route.distance/1000)) km "
                    travelTime = "約：\(route.expectedTravelTime.convertToHMS)"
                }
                detailCalloutView.distanceLabel.text = distance
                detailCalloutView.etaLabel.text = travelTime
            }
        }
    }
    
    
    private func clusterSetVisibleMapRect(with cluster: ClusterAnnotation) {
        let zoomRect = cluster.annotations.reduce(MKMapRectNull) { (zoomRect, annotation) in
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 2500, 0)
            return MKMapRectIsNull(zoomRect) ? pointRect : MKMapRectUnion(zoomRect, pointRect)
        }
        mapView.setVisibleMapRect(zoomRect, animated: true)
    }
    
    
    @objc func navigating() {
        Answers.log(event: .MapButtons, customAttributes: #function)
        guard let destination = selectedAnnotationView?.annotation else { return }
        Navigator.go(to: destination)
    }
    
    @objc func locationArrowPressed() {
        Answers.log(event: .MapButtons, customAttributes: #function)
        setTracking(mode: mapView.userTrackingMode.nextMode)
    }
}



// MARK:- Verify purchase notification
extension MapViewController: IAPPurchasable {
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name:  .init(rawValue: Keys.standard.removeAdsObserverName),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resignApp(_:)),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        print("MapViewController recieved notify")
        
        guard let productID = notification.object as? String,
            RegisteredPurchase.removedProductID == productID else { return }
        Answers.log(event: .PurchaseEvents, customAttributes: "Removed Ad")
        
        adContainerView.removeFromSuperview()
        mapView.layoutIfNeeded()
    }
}


//feature for cluster
extension MapViewController {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { views.forEach { $0.alpha = 1 } }
        )
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
    }
}


//TODO:- test area
extension MapViewController {
    
    private func testFunction() {
        //                #if DEBUG
        //
        //                    let activity = selectedPin?.userActivity
        //                    activity?.isEligibleForPublicIndexing = true
        //                    activity?.isEligibleForSearch = true
        //
        //                    userActivity = activity
        //
        //                #endif
        
//        #if DEBUG
//        
//        view.addSubview(testStack)
//        testStack.anchor(top: segmentedControl.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: 50, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
//        #endif
        
    }
    
    @objc func saveTest() {
        
        //        print("test for annotation save to cloud")
        //        saveToCloud(with: self.annotations)
        //
        //        self.annotations.toData.backupToCloud(completeHandler: )
        
        //        saveToCloud(with: self.annotations)
        //        queryDatabase()
        //        DispatchQueue.global().async {
        //            let predicated = self.annotations.getDistance(userPosition: self.currentUserLocation)
        //            predicated.forEach { (station) in
        //                print(station.title as Any)
        //            }
        //        }
    }
    
    @objc func queryTest() {
        //        getAnnoatationsFromCloud { self.annotations = $0 }
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentUserLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
//        let centralLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
//        print("Radius - \(getRadius(centralLocation: centralLocation))")
    }
    
    
    func getRadius(centralLocation: CLLocation) -> Double {
        let topCentralLat: Double = centralLocation.coordinate.latitude -  mapView.region.span.latitudeDelta/2
        let topCentralLocation = CLLocation(latitude: topCentralLat, longitude: centralLocation.coordinate.longitude)
        let radius = centralLocation.distance(from: topCentralLocation)
        return radius / 1000.0 // to convert radius to meters
    }
}
