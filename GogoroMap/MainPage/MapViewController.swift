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


typealias ManuGuideDelegate = ManuDelegate & GuidePageViewControllerDelegate

final class MapViewController: UIViewController, MKMapViewDelegate, AnnotationHandleable, DataGettable, ManuGuideDelegate {
    
    
    
    //         MARK: - Properties
    var currentUserLocation: CLLocation!
    var myLocationManager: CLLocationManager!
    let myCellid = "myCellid"
    let segmentItems: [SegmentStatus] = [.map , .checkin, .nearby, .building]
    
    var listToDisplay = [CustomPointAnnotation]() {
        didSet {
            if !listToDisplay.isEmpty {
                cellEmptyGuideView.isHidden = true
                collectionView.reloadData()
            } else { showupEmptyGuide() }
        }
    }
    
    private func showupEmptyGuide() {
        mapView.isHidden = true
        collectionView.isHidden = true
        cellEmptyGuideView.isHidden = false
    }
    
    let cellEmptyGuideView: UITextView = {
        let myTextView = UITextView()
        myTextView.text = "目前尚未有符合資料可顯示..."
        myTextView.font = UIFont.systemFont(ofSize: 32)
        myTextView.textAlignment = .center
        myTextView.isEditable = false
        myTextView.isHidden = true
        return myTextView
    }()
    
    private var selectedAnnotationView: MKAnnotationView? = MKAnnotationView()
    private var detailView = DetailAnnotationView()
    
    
    var indexOfAnnotations: Int = 0
    var selectedPin: CustomPointAnnotation?
    
    enum CheckinStatus {
        case checkin
        case unCheckin
    }
    
    var counterOfcheckin: Int = 0 {
        didSet {
            var lastCheckinString: String = "最近的打卡日："
            let checkinStatus: CheckinStatus = counterOfcheckin > 0 ? .checkin : .unCheckin
            
            switch checkinStatus {
                
            case .checkin:
                selectedAnnotationView?.image = #imageLiteral(resourceName: "checkin")
                annotations[indexOfAnnotations].checkinDay = Date.today
                detailView.buttonStackView.addArrangedSubview(detailView.unCheckinButton)
                lastCheckinString = "最近的打卡日：\(Date.today)"
                
            case .unCheckin:
                selectedAnnotationView?.image = getImage(with: selectedPin?.title)
                annotations[indexOfAnnotations].checkinDay = ""
                detailView.buttonStackView.removeArrangedSubview(detailView.unCheckinButton)
                
            }
            
            detailView.timesOfCheckinLabel.text = "打卡：\(counterOfcheckin) 次"
            detailView.lastCheckTimeLabel.text = lastCheckinString
            annotations[indexOfAnnotations].checkinCounter = counterOfcheckin
            annotations[indexOfAnnotations].image = selectedAnnotationView?.image
            
            saveToDatabase(with: annotations)
        }
    }
    
    
    //     MARK: - Handler of Annotations on map with store property obsever
    var willRemovedAnnotations = [CustomPointAnnotation]() {
        didSet {
            DispatchQueue.main.async { self.mapView.removeAnnotations(self.willRemovedAnnotations) }
        }
    }
    
    var annotations = [CustomPointAnnotation]() {
        didSet {
            DispatchQueue.main.async { self.clusterUpdating(with: oldValue) }
            saveToDatabase(with: annotations)
        }
    }
    
    private func clusterUpdating(with oldValue: [CustomPointAnnotation]) {
        clusterManager.remove(oldValue)
        updataAnnotationImage(annotations: annotations)
        clusterManager.add(annotations)
    }
    
    //     MARK: - Computed Properties
    var userLocationCoordinate: CLLocationCoordinate2D! {
        get { return currentUserLocation.coordinate }
        set { currentUserLocation = CLLocation(latitude: newValue.latitude, longitude: newValue.longitude) }
    }
    var stationData: StationDatas {
        return annotations.getStationData
    }
    
    //     MARK: - View Creators
    private let clusterManager: ClusterManager = {
        let myManager = ClusterManager()
        myManager.maxZoomLevel = 14
        myManager.minCountForClustering = 2
        return myManager
    }()
    
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
        button.addTarget(self, action: #selector(performMenu), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        segmentItems.enumerated().forEach {
            sc.insertSegment(withTitle: $1.rawValue, at: $0, animated: false)
        }
        sc.selectedSegmentIndex = 0
        sc.tintColor = .white
        sc.addTarget(self, action: #selector(segmentChange), for: .valueChanged)
        
        return sc
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let myCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: myCellid)
        myCollectionView.isHidden = true
        myCollectionView.backgroundColor = .clear
        myCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        return myCollectionView
    }()
    
    private lazy var segmentControllerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGreen
        return view
    }()
    
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
    
    //     MARK: - ViewController life cycle
    override func loadView() {
        super.loadView()
        setupView()
        setupSideMenu()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
        performGuidePage()
        authrizationStatus()
        initializeData()
        setupPurchase()
        #if REALEASE
        setupRating()
            #endif
//        testFunction()
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Answers.log(view: "Map Page")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.seupAdContainerView()
        }
        menuBarButton.willDisplay()
        locationArrowView.willDisplay()
        
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        myLocationManager.stopUpdatingLocation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        menuBarButton.isHidden = true
        locationArrowView.isHidden = true
    }
    
    //     MARK: - Perfrom
    func performGuidePage() {
        if UserDefaults.standard.bool(forKey: Keys.standard.beenHereKey) { return }
        let guidePageController = GuidePageViewController()
        guidePageController.delegate = self
        present(guidePageController, animated: true, completion: nil)
    }
    
    
    
    @objc func performMenu() {
        Answers.log(event: .mapButton, customAttributes: "Perform Menu")
        if let sideManuController = SideMenuManager.default.menuLeftNavigationController {
            self.setTrackModeNone()
            present(sideManuController, animated: true, completion: nil)
        }
    }
    
    //     MARK: - View setups
    private func setupSideMenu() {
        let layout = UICollectionViewFlowLayout()
        let menuController = MenuController(collectionViewLayout: layout)
        menuController.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuController)
        let sideManuManager = SideMenuManager.default
        sideManuManager.menuLeftNavigationController?.leftSide = true
        sideManuManager.menuLeftNavigationController = menuLeftNavigationController
        sideManuManager.menuAnimationBackgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        setSideMenuDefalts()
    }
    
    
    
    private func setSideMenuDefalts() {
        let displayFactor: CGFloat = 0.80
        let sideMenuManager = SideMenuManager.default
        sideMenuManager.menuFadeStatusBar = true
        sideMenuManager.menuShadowOpacity = 0.59
        sideMenuManager.menuWidth = view.frame.width * displayFactor
        sideMenuManager.menuAnimationTransformScaleFactor = 0.95
        sideMenuManager.menuAnimationFadeStrength = 0.40
        sideMenuManager.menuBlurEffectStyle = nil
        sideMenuManager.menuPresentMode = .viewSlideInOut
        menuBarButton.isHidden = false
    }
    
    private func setupView() {
        setupNavigationTitle()
        setupNavigationItems()
        setupSegmentControllerContainer()
        setupMainViews()
        
    }
    
    private func setupNavigationTitle() {
        navigationItem.title = "Gogoro \(NSLocalizedString("Battery Station", comment: ""))"
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.barTintColor = UIColor.lightGreen
        navigationController?.isNavigationBarHidden = false
        navigationController?.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        
    }
    
    private func setupNavigationItems() {
        navigationController?.view.addSubview(locationArrowView)
        navigationController?.view.addSubview(menuBarButton)
        
        guard let navigationControllerView = navigationController?.view else { return }
        let sidePading: CGFloat = 8
        let height: CGFloat = 38
        let width: CGFloat = 50
        
        var topAnchor: NSLayoutYAxisAnchor = navigationControllerView.topAnchor
        var topPadding: CGFloat = 23
        
        if UIDevice.isiPhoneX,
            #available(iOS 11.0, *) {
            topAnchor = navigationControllerView.safeAreaLayoutGuide.topAnchor
            topPadding = 0
            setupBottomBackgroundView()
        }
        
        locationArrowView.anchor(top: topAnchor, left:  nil, bottom: nil, right:  navigationControllerView.rightAnchor, topPadding: topPadding, leftPadding: 0, bottomPadding: 0, rightPadding: sidePading, width: width, height: height)
        
        menuBarButton.anchor(top: topAnchor, left: navigationControllerView.leftAnchor, bottom: nil, right: nil, topPadding: topPadding, leftPadding: sidePading, bottomPadding: 0, rightPadding: 0, width: width, height: height)
    }
    
    private func setupRating() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    private func setupMainViews() {
        setupMainViews(with: mapView, collectionView, cellEmptyGuideView)
    }
    
    private func setupSegmentControllerContainer() {
        
        view.addSubview(segmentControllerContainer)
        
        var topPadding: CGFloat = 64
        
        if UIDevice.isiPhoneX {
            let safeAreaTopPadding: CGFloat = 80
            topPadding = safeAreaTopPadding
        }
        
        segmentControllerContainer.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: topPadding, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 44)
        
        segmentControllerContainer.addSubview(segmentedControl)
        
        segmentedControl.anchor(top: segmentControllerContainer.topAnchor, left: segmentControllerContainer.leftAnchor, bottom: segmentControllerContainer.bottomAnchor, right: segmentControllerContainer.rightAnchor, topPadding: 10, leftPadding: 10, bottomPadding: 10, rightPadding: 10, width: 0, height: 0)
    }
    
    private func setupMainViews(with myViews: UIView...) {
        myViews.forEach { (myView) in
            view.addSubview(myView)
            myView.anchor(top: segmentControllerContainer.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        }
        
    }
    
    private func seupAdContainerView() {
        
        Answers.log(view: "Ad View")
        view.addSubview(self.adContainerView)
        
        var bottomAnchor = view.bottomAnchor
        //         MARK:  iPhone X autolayout
        if #available(iOS 11.0, *),
            UIDevice.isiPhoneX {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        }
        adContainerView.anchor(top: nil, left: view.leftAnchor, bottom: bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
        
        view.bringSubview(toFront: adContainerView)
    }
    
    private func setupBottomBackgroundView() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightGreen
        view.addSubview(backgroundView)
        backgroundView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 40)
    }
}

// MARK: - CollectionView
extension MapViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listToDisplay.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myCellid, for: indexPath) as? MyCollectionViewCell ?? MyCollectionViewCell()
        
        let item = listToDisplay[indexPath.item]
        
        cell.titleLabel.text = "\(indexPath.item + 1 ). \(item.title ?? "")"
        cell.dateLabel.text = item.checkinCounter > 0 ? "打卡日期: \(item.checkinDay)" : ""
        cell.imageView.image = item.image
        cell.distanceLabel.text = "距離: \(item.getDistance(from: currentUserLocation).km) km"
        
        cell.backgroundColor = .clear
        cell.alpha = 0.98
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Answers.log(event: .mapButton, customAttributes: "Pressd CellView")
        let seletedItem = listToDisplay[indexPath.item]
        
        changeToMapview()
        if !mapView.annotations.contains(where: { $0.title ?? "" == seletedItem.title }) {
            mapViewMove(to: seletedItem)
        }
        
        mapView.selectAnnotation(seletedItem, animated: true)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    private func changeToMapview() {
        segmentedControl.selectedSegmentIndex = 0
        mapView.isHidden = false
        collectionView.isHidden = !mapView.isHidden
        cellEmptyGuideView.isHidden = !mapView.isHidden
        self.locationArrowView.isEnabled = true
    }
    
    private func mapViewMove(to station: CustomPointAnnotation) {
        Answers.log(event: .mapButton, customAttributes: "mapViewMove")
        let annotationPoint = MKMapPointForCoordinate(station.coordinate).centerOfScreen
        let factor = 0.7
        let height: Double = 20000
        let width = factor * height
        let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, width, height)
        mapView.setVisibleMapRect(pointRect, animated: false)
    }
}


//MARK: - Checkin functions
extension MapViewController {
    
    @objc func checkin() {
        Answers.log(event: .mapButton, customAttributes: "Check in")
        counterOfcheckin = annotations[indexOfAnnotations].checkinCounter + 1
    }
    
    
    @objc func unCheckin() {
        Answers.log(event: .mapButton, customAttributes: "Remove check in")
        counterOfcheckin = annotations[indexOfAnnotations].checkinCounter - 1
    }
}

//MARK: - Lists of function annotations
extension MapViewController {
    @objc func segmentChange(sender: UISegmentedControl) {
        let segmentStatus = segmentItems[sender.selectedSegmentIndex]
        
        mapView.isHidden = segmentStatus == .map ? false : true
        collectionView.isHidden =  !mapView.isHidden
        self.setTrackModeNone()
        self.locationArrowView.isEnabled = false
        var eventName: String = ""
        
        switch segmentStatus {
            
        case .map:
            eventName = "Map mode"
            changeToMapview()
            
        case .checkin:
            eventName = "Checkin list"
            listToDisplay = annotations.filter { $0.checkinCounter > 0 }
                .sortedByDistance(userPosition: currentUserLocation)
            
        case .nearby:
            eventName =  "Nearby list"
            listToDisplay = annotations.sortedByDistance(userPosition: currentUserLocation)
                .filter { $0.getDistance(from: currentUserLocation).km < 45 }
            
            
        case .building:
            eventName = "Building list"
            listToDisplay = annotations.filter { $0.title?.contains("建置中") ?? false }
                .sortedByDistance(userPosition: currentUserLocation)
        }
        
        
        Answers.log(event: .mapButton, customAttributes: eventName)
    }
}
//MARK: - Present annotationView and Navigatorable
extension MapViewController: Navigatorable {
    
    @objc func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? ClusterAnnotation {
            let style = ClusterAnnotationStyle.color(.grassGreen, radius: 36)
            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if let view = view as? BorderedClusterAnnotationView {
                view.annotation = annotation
                view.configure(with: style)
            } else {
                view = BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, style: style, borderColor: .white)
            }
            return view
            
        } else {
            return getOriginalMKAnnotationView(mapView, viewFor: annotation)
        }
    }
    
    
    //MARK: - Original MKAnnotationView
    private func getOriginalMKAnnotationView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
        
        detailView.goButton.addTarget(self, action: .navigating(), for: .touchUpInside)
        detailView.checkinButton.addTarget(self, action: .checkin(), for: .touchUpInside)
        detailView.unCheckinButton.addTarget(self, action: .unCheckin(), for: .touchUpInside)
        
        annotationView?.image = customAnnotation.checkinCounter > 0 ? #imageLiteral(resourceName: "checkin") : customAnnotation.image
        annotationView?.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        Answers.log(event: .mapButton, customAttributes: "Display annotation view")
        guard let annotation = view.annotation else { return }
        self.selectedAnnotationView = nil
        
        //        MARK:  feature fo cluster
        if let clusterAnnotation = annotation as? ClusterAnnotation {
            clusterSetVisibleMapRect(with: clusterAnnotation)
            return
        }
        
        self.selectedAnnotationView = view
        
        guard
            let customPointannotation = annotation as? CustomPointAnnotation,
            let detailCalloutView = view.detailCalloutAccessoryView as? DetailAnnotationView,
            let index = annotations.index(of: customPointannotation) else { return }
        
        self.selectedPin = customPointannotation
        self.indexOfAnnotations = index
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
    
    
    private func clusterSetVisibleMapRect(with cluster: ClusterAnnotation) {
        let zoomRect = cluster.annotations.reduce(MKMapRectNull) { (zoomRect, annotation) in
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 2500, 0)
            return MKMapRectIsNull(zoomRect) ? pointRect : MKMapRectUnion(zoomRect, pointRect)
        }
        mapView.setVisibleMapRect(zoomRect, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .heavyBlue
        return renderer
    }
    
    @objc func navigating() {
        Answers.log(event: .mapButton, customAttributes: "Navigate")
        guard let destination = self.selectedPin else { return }
        go(to: destination)
    }
    
    @objc func locationArrowPressed() {
        Answers.log(event: .mapButton, customAttributes: "Changing tracking mode")
        locationArrowTapped()
    }
}



// MARK:- Verify purchase notification
extension MapViewController: IAPPurchasable {
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseNotification(_:)),
                                               name: .removeAds,
                                               object: nil)
       
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataupdate(_:)),
                                               name: .dataUpdata,
                                               object: nil)
    }
    
    @objc func handleDataupdate(_ notification: Notification) {
        
        guard let data = notification.object as? Data,
            let annotations = data.toAnnoatations else { return }
        self.annotations = annotations
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        print("MapViewController recieved notify")
        
        guard
            let productID = notification.object as? String,
            RegisteredPurchase.removedProductID == productID else { return }
        Answers.log(event: .purchaseEvent, customAttributes: "Removed Ad")
        
        adContainerView.removeFromSuperview()
        mapView.layoutIfNeeded()
    }
}


//feature for cluster
extension MapViewController {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach { $0.alpha = 0 }
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            views.forEach { $0.alpha = 1 }
        }, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //        print("visibleMapRect : \(mapView.visibleMapRect)")
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
        
        #if DEBUG
            
            view.addSubview(testStack)
            testStack.anchor(top: segmentedControl.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: 50, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
        #endif
        
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
        let centralLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
        self.userLocationCoordinate = mapView.centerCoordinate
        print("Radius - \(self.getRadius(centralLocation: centralLocation))")
    }
    
    
    func getRadius(centralLocation: CLLocation) -> Double {
        let topCentralLat:Double = centralLocation.coordinate.latitude -  mapView.region.span.latitudeDelta/2
        let topCentralLocation = CLLocation(latitude: topCentralLat, longitude: centralLocation.coordinate.longitude)
        let radius = centralLocation.distance(from: topCentralLocation)
        return radius / 1000.0 // to convert radius to meters
    }
    
}



