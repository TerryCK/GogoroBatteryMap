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

extension MapViewController: ADSupportable {
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Google Ad error: \(error)")
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        didReceiveAd(bannerView)
    }
}


final class MapViewController: UIViewController, MKMapViewDelegate, ManuDelegate, StationDataSource, GuidePageViewControllerDelegate, CLLocationManagerDelegate  {
    
    var currentUserLocation: CLLocation!
    
    var adUnitID = Keys.standard.adUnitID
    
    var bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [locationArrowView,  menuBarButton].forEach { $0.isHidden = false }
        reloadMapView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        [locationArrowView,  menuBarButton].forEach { $0.isHidden = true }
        
    }
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
        Answers.log(view: "Map Page")
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(action))
        longPressRecognizer.numberOfTapsRequired = 1
        longPressRecognizer.minimumPressDuration = 0.1
        mapView.addGestureRecognizer(longPressRecognizer)
        #if DEBUG
        adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        setupAd()
        #endif
        
    }
    enum Status {
        case lock, release
    }
    private var lastTouchPoint: CGPoint?
    
    private var gestureRecognizerStatus: Status  = .release
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPoint = touches.first?.location(in: mapView)
    }
    
    @objc func action(sender: UILongPressGestureRecognizer) {
        let isLongPressGestureRecognizerActive = [.possible, .began, .changed].contains(sender.state)
        
        gestureRecognizerStatus = isLongPressGestureRecognizerActive ? .lock : .release
        guard isLongPressGestureRecognizerActive, let lastTouchPoint = lastTouchPoint else {
            clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
            return
        }
        let current = sender.location(in: mapView)
        let deltaY = current.y - lastTouchPoint.y
        self.lastTouchPoint = current
        
        mapZoomWith(scale: deltaY > 0 ? 1.05 : 0.95)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func resignApp(_ notification: Notification) {
        guard case UIApplication.didEnterBackgroundNotification = notification.name else { return }
        locationManager.stopUpdatingLocation()
        DataManager.shared.saveToDatabase(with: batteryStationPointAnnotations)
    }
    
    var batteryStationPointAnnotations = DataManager.shared.initialStations {
        willSet {
            clusterManager.removeAll()
            reloadMapView()
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
        let annotationPoint = MKMapPoint(station.coordinate).centerOfScreen
        let factor = 0.7, height = 20000.0
        let width = factor * height
        let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: width, height: height)
        mapView.setVisibleMapRect(pointRect, animated: false)
    }
}

//MARK: - Checkin functions
extension MapViewController {
    // Date().string(dateformat: "yyyy.MM.dd") : ""
    private func checkinCount(with calculate: (Int, Int) -> Int, log: String) {
        Answers.log(event: .MapButtons, customAttributes: log)
        guard let batteryAnnotation = selectedAnnotationView?.annotation as? BatteryStationPointAnnotation else { return }
        let counterOfcheckin = calculate(batteryAnnotation.checkinCounter ?? 0, 1)
        batteryAnnotation.checkinDay = counterOfcheckin > 0 ? Date() : nil
        batteryAnnotation.checkinCounter = counterOfcheckin
        selectedAnnotationView?.image = batteryAnnotation.iconImage
        _ = (selectedAnnotationView?.detailCalloutAccessoryView as? DetailAnnotationView)?.configure(annotation: batteryAnnotation)
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
        if let view = view as? ClusterAnnotationView {
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
        
        detailCalloutView.distanceLabel.text = "距離計算中..."
        detailCalloutView.etaLabel.text = "時間計算中..."
        Navigator.travelETA(from: currentUserLocation.coordinate, to: destination) { (result) in
            var distance = "無法取得資料", travelTime = "無法取得資料"
            DispatchQueue.main.async {
                if case .success(let response) = result, let route = response.routes.first {
                    let (hours, minutes) = TimeInterval.travelTimeConvert(seconds: route.expectedTravelTime)
                    distance = "距離：\(String(format: "%.1f", route.distance/1000)) km "
                    travelTime = "約：" + (hours > 0 ? "\(hours) 小時 " : "") + "\(minutes) 分鐘 "
                }
                detailCalloutView.distanceLabel.text = distance
                detailCalloutView.etaLabel.text = travelTime
            }
        }
    }
    
    
    private func mapZoomWith(scale: Double) {
        var span = mapView.region.span
        var region = mapView.region
        let latDelt = min(158.0, max(span.latitudeDelta * scale, 0))
        let longDelt = min(145.5, max(span.longitudeDelta * scale, 0))
        span.latitudeDelta = latDelt
        span.longitudeDelta = longDelt
        region.span = span
        mapView.setRegion(region, animated: false)
    }
    
    
    private func clusterSetVisibleMapRect(with cluster: ClusterAnnotation) {
        let zoomRect = cluster.annotations.reduce(MKMapRect.null) { (zoomRect, annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 2500, height: 0)
            return zoomRect.isNull ? pointRect : zoomRect.union(pointRect)
        }
        mapView.setVisibleMapRect(zoomRect, animated: true)
    }
    
    
    @objc func navigating() {
        Answers.log(event: .MapButtons, customAttributes: #function)
        guard let destination = selectedAnnotationView?.annotation as? BatteryStationPointAnnotation else { return }
        
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
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        bannerView.isHidden = UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey)
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
        guard gestureRecognizerStatus == .release else { return }
        clusterManager.reload(mapView, visibleMapRect: mapView.visibleMapRect)
    }
}


//TODO:- test area
extension MapViewController {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentUserLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
    }
    
    
    //    func getRadius(centralLocation: CLLocation) -> Double {
    //        let topCentralLat: Double = centralLocation.coordinate.latitude -  mapView.region.span.latitudeDelta/2
    //        let topCentralLocation = CLLocation(latitude: topCentralLat, longitude: centralLocation.coordinate.longitude)
    //        let radius = centralLocation.distance(from: topCentralLocation)
    //        return radius / 1000.0 // to convert radius to meters
    //    }
}
