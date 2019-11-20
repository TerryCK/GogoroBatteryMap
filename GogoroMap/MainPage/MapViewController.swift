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
import FloatingPanel
import ColorMatchTabs

extension MapViewController: ADSupportable {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bridgeAd(bannerView)
    }
}

extension MapViewController  {
    
    func setCurrentLocation(latDelta: Double, longDelta: Double) {
        let userLocation = locationManager.userLocation ?? CLLocation(latitude: 25.047908, longitude: 121.517315)
        mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate,
                                             span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)), animated: false)
    }
    
    func setTracking(mode: MKUserTrackingMode) {
        Answers.logCustomEvent(withName: "TrackingMode", customAttributes: ["TrackingMode" : "\(mode)"])
        mapView.setUserTrackingMode(mode, animated: true)
    }
}

extension MapViewController: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            vc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            vc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return SearchPanelLandscapeLayout()
        default:
            vc.surfaceView.borderWidth = 0.0
            vc.surfaceView.borderColor = nil
            return MapFloatingLayout()
        }
    }
    
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        bannerView.isHidden = targetPosition == .full
        if targetPosition == .full { setTracking(mode: .none) }
    }
    
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        guard vc.position == .full,
            let tableViewController = vc.contentViewController as? TableViewController else {
                return
        }
        tableViewController.searchBar.showsCancelButton = false
        tableViewController.searchBar.resignFirstResponder()
    }
}

extension MapViewController: GADAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}

extension MapViewController: GADUnifiedNativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        self.nativeAd = nativeAd
        self.nativeAd?.delegate = self
    }
}


final class MapViewController: UIViewController, ManuDelegate, GADUnifiedNativeAdDelegate  {
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
    
    var nativeAd: GADUnifiedNativeAd?
    
    lazy var nativeAdLoader: GADAdLoader? = GADAdLoader.createNativeAd(delegate: self)
    
    private let locationManager: LocationManager = .shared
    
    var clusterSwitcher = ClusterStatus() {
        didSet {
            clusterManager.maxZoomLevel = clusterSwitcher.maxZoomLevel
        }
    }
    
    private var selectedTabItem: TabItemCase {
        TabItemCase(rawValue: (fpc.contentViewController as? FloatingViewController)?.selectedSegmentIndex ?? 0) ?? .nearby
    }
    
    lazy var fpc: FloatingPanelController = {
        $0.delegate = self
        $0.surfaceView.backgroundColor = .clear
        if #available(iOS 11, *) {
            $0.surfaceView.cornerRadius = 9.0
        } else {
            $0.surfaceView.cornerRadius = 0.0
        }
        $0.surfaceView.shadowHidden = false
        $0.surfaceView.grabberTopPadding = 1
        let floatingVC = FloatingViewController()
        $0.set(contentViewController: floatingVC)
        floatingVC.flatingPanelController = $0
        return $0
    }(FloatingPanelController(delegate: nil))
    
    
    private lazy var clusterManager: ClusterManager = {
        $0.maxZoomLevel = clusterSwitcher.maxZoomLevel
        $0.minCountForClustering = 3
        $0.add(DataManager.shared.stations)
        return $0
    }(ClusterManager())
    
    private lazy var mapView : MKMapView = {
        $0.delegate = self
        $0.mapType = .standard
        $0.showsUserLocation = true
        $0.isZoomEnabled = true
        $0.showsCompass = true
        $0.showsScale = true
        $0.showsTraffic = false
        $0.userLocation.title = "😏 \("here".localize())"
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(action))
        longPressRecognizer.numberOfTapsRequired = 1
        longPressRecognizer.minimumPressDuration = 0.1
        $0.addGestureRecognizer(longPressRecognizer)
        view.addSubview($0)
        $0.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, bottomPadding: 45)
        return $0
    }(MKMapView())
    
    lazy var locationArrowView: UIButton = {
        $0.setImage(#imageLiteral(resourceName: "locationArrowNone"), for: .normal)
        $0.addTarget(self, action: #selector(locationArrowPressed), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private lazy var menuBarButton: UIButton = {
        $0.setImage(#imageLiteral(resourceName: "manuButton"), for: .normal)
        $0.addTarget(self, action: #selector(MapViewController.performMenu), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        [locationArrowView,  menuBarButton].forEach { $0.isHidden = false }
        DispatchQueue.main.async {
            self.clusterManager.reload(mapView: self.mapView)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        [locationArrowView,  menuBarButton].forEach { $0.isHidden = true }
    }
    
    
    func promptLocationAuthenticateError() {
        let alertController = UIAlertController(title: "定位權限已關閉",
                                                message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "確認", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupNavigationItems()
        setupObserve()
        setupObserver()
        performGuidePage()
        nativeAdLoader?.update()
        setupSideMenu()
        LocationManager.shared.authorize { (status) in
            if [.denied, .restricted].contains(status) {
                promptLocationAuthenticateError()
            }
            setCurrentLocation(latDelta: 0.05, longDelta: 0.05)
        }
        
        setupPurchase()
        Answers.log(view: "Map Page")
        
        DataManager.shared.fetchStations()
        fpc.addPanel(toParent: self, animated: true)
        setupAd(with: view)
    }
    
    private enum Status {
        
        case lock, release
    }
    
    private var lastTouchPoint: CGPoint?
    
    private var gestureRecognizerStatus: Status  = .release {
        didSet {
            if gestureRecognizerStatus == .lock {
                setTracking(mode: .none)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPoint = touches.first?.location(in: mapView)
        if lastTouchPoint != nil {
            (fpc.contentViewController as? TableViewController)?.searchBar.resignFirstResponder()
            fpc.move(to: .tip, animated: true)
        }
    }
    
    @objc func action(sender: UILongPressGestureRecognizer) {
        let isLongPressGestureRecognizerActive = [.possible, .began, .changed].contains(sender.state)
        
        gestureRecognizerStatus = isLongPressGestureRecognizerActive ? .lock : .release
        guard isLongPressGestureRecognizerActive, let lastTouchPoint = lastTouchPoint else {
            clusterManager.reload(mapView: mapView)
            Answers.log(event: .MapButton, customAttributes: "single hand zoom")
            return
        }
        
        let current = sender.location(in: mapView)
        let deltaY = current.y - lastTouchPoint.y
        self.lastTouchPoint = current
        mapZoomWith(scale: deltaY > 0 ? 1.05 : 0.95)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        observation?.invalidate()
    }
    
    private var observation: NSKeyValueObservation?
    
    private func setupObserve() {
        observation = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.clusterManager.removeAll()
                self.clusterManager.add(self.selectedTabItem.stationDataSource)
                self.clusterManager.reload(mapView: self.mapView)
            }
        }
    }
    
    //     MARK: - Perfrom
    func performGuidePage() {
        if UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) { return }
        let guide = GuidePageViewController()
        guide.modalPresentationStyle = .fullScreen
        present(guide, animated: true)
    }
    
    @objc func performMenu() {
        guard let sideManuController = SideMenuManager.default.menuLeftNavigationController else {
            return
        }
        Answers.log(event: .MapButton, customAttributes: "Perform Menu")
        setTracking(mode: .none)
        (fpc.contentViewController as? TableViewController)?.searchBar.resignFirstResponder()
        nativeAdLoader?.update()
        fpc.present(sideManuController, animated: true)
    }
    
    private func setupSideMenu(sideMenuManager: SideMenuManager = .default, displayFactor: CGFloat = 0.8) {
        
        let flowLyout: UICollectionViewFlowLayout = {
            $0.itemSize = CGSize(width: view.frame.width * displayFactor - 20 , height: view.frame.height - 90)
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
            return $0
        }(UICollectionViewFlowLayout())
        
        let menuController = MenuController(collectionViewLayout: flowLyout)
        menuController.delegate = self
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
        navigationItem.titleView?.subviews.forEach { ($0 as? UILabel)?.textColor = .white }
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = .lightGreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
    
    private func setupNavigationItems() {
        guard let navigationController = navigationController else { return }
        [locationArrowView, menuBarButton].forEach(navigationController.view.addSubview)
        let sidePading: CGFloat = 12, height: CGFloat = 38,  width: CGFloat = 38
        var topAnchor: NSLayoutYAxisAnchor = navigationController.view.topAnchor
        var topPadding: CGFloat = 23
        
        if #available(iOS 11.0, *) {
            topAnchor = navigationController.view.safeAreaLayoutGuide.topAnchor
            topPadding = 0
            setupBottomBackgroundView()
        }
        
        locationArrowView.anchor(top: topAnchor, left:  nil, bottom: nil, right:  navigationController.view.rightAnchor, topPadding: topPadding, leftPadding: 0, bottomPadding: 0, rightPadding: sidePading, width: width, height: height)
        menuBarButton.anchor(top: topAnchor, left: navigationController.view.leftAnchor, bottom: nil, right: nil, topPadding: topPadding, leftPadding: sidePading, bottomPadding: 0, rightPadding: 0, width: width, height: height)
        [locationArrowView,  menuBarButton].forEach {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 38/2
            $0.tintColor = .white
            //            $0.backgroundColor = UIColor.orange.withAlphaComponent(0.9)
            //            $0.layer.borderWidth = 1
            //            $0.layer.borderColor = UIColor.white.cgColor
        }
        
    }
    
    private func setupBottomBackgroundView() {
        let backgroundView = UIView {  $0.backgroundColor = .lightGreen }
        view.addSubview(backgroundView)
        backgroundView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, height: 40)
    }
    
    func mapViewMove(to annotation: MKAnnotation) {
        let annotationPoint = MKMapPoint(annotation.coordinate).centerOfScreen
        let factor = 0.7, height = 15000.0
        let width = factor * height
        let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: width, height: height)
        mapView.setVisibleMapRect(pointRect, animated: false)
        fpc.move(to: .tip, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                if let selectedAnnotation = self.mapView.annotations.first(where: { $0.coordinate.latitude == annotation.coordinate.latitude }) {
                    self.mapView.selectAnnotation(selectedAnnotation, animated: true)
                }
            }
        }
    }
}

//MARK: - Present annotationView and Navigatorable
extension MapViewController: MKMapViewDelegate {
    
    @objc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let clusterAnnotation = annotation as? ClusterAnnotation else {
            return originalMKAnnotationView(mapView, viewFor: annotation)
        }
        
        let annotationView = mapView.annotationView(of: CountClusterAnnotationView.self, annotation: clusterAnnotation, reuseIdentifier: "Cluster")
        annotationView.countLabel.backgroundColor = .lightGreen
        return annotationView
    }
    
    
    //MARK: - Original MKAnnotationView
    private func originalMKAnnotationView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        let identifier = "station"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation,
                                                                                                                   reuseIdentifier: identifier)
        annotationView.canShowCallout = true
        switch annotation {
        case let batteryStation as BatteryStationPointAnnotation:
            annotationView.image = batteryStation.iconImage
            annotationView.detailCalloutAccessoryView = DetailAnnotationView()
                .configure(annotation: batteryStation,
                           nativeAd: nil)
        case _ as GoSharePointAnnotation:
            annotationView.image = UIImage(named: "test")
            
        default: return nil
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        locationArrowView.setImage(mapView.userTrackingMode.arrowImage, for: .normal)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard gestureRecognizerStatus == .release else { return }
        clusterManager.reload(mapView: mapView)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let clusterAnnotation = view.annotation as? ClusterAnnotation {
            clusterSetVisibleMapRect(with: clusterAnnotation)
            return
        }
        
        
        nativeAdLoader?.update()
        Answers.log(event: .MapButton, customAttributes: "Display annotation view")
        fpc.move(to: .tip, animated: true) {
            DetailCalloutAccessoryViewModel(annotationView: view,
                                            controller: self).bind(mapView: mapView,
                                                                   nativeAd: self.nativeAd)
        }
        
        UIView.animate(withDuration: 0.35) {
            view.alpha = 1
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        
        UIView.animate(withDuration: 0.35) {
            views.forEach {
                $0.alpha =  1
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
    
    @objc func locationArrowPressed() {
        Answers.log(event: .MapButton, customAttributes: #function)
        fpc.move(to: .tip, animated: true) {
            self.setTracking(mode: self.mapView.userTrackingMode.nextMode)
        }
    }
}

// MARK:- Verify purchase notification
extension MapViewController: IAPPurchasable {
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name:  .init(rawValue: Keys.standard.removeAdsObserverName),
                                               object: nil)
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: Keys.standard.hasPurchesdKey) {
            removeAds(view: view)
            DataManager.shared.lastUpdate = Date()
        }
    }
}
