//
//  TableViewController.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/17.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds

extension TableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        UIApplication.mapViewController?.fpc?.move(to: .full, animated: true)
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchText = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

extension TableViewController {
    @objc func handlePurchaseNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.nativeAd = nil
            self.stations = self.tabItem.stationDataSource
        }
    }
    
    private func setupObserver() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(handlePurchaseNotification(_:)),
                         name: .init(rawValue: Keys.standard.removeAdsObserverName),
                         object: nil)
    }
}

final class TableViewController: UITableViewController, ViewTrackable {
    
    @IBOutlet weak var searchBar: UISearchBar!
    private var observation: NSKeyValueObservation?
    private var searchText = "" {
        didSet {
            stations = tabItem.stationDataSource
        }
    }
    
    private let locationManager: LocationManager = .shared
    
    let tabItem: TabItemCase
    
    var nativeAd: GADUnifiedNativeAd? {
        didSet {
            DispatchQueue.main.async {
                self.setupAds()
                guard self.nativeAd?.aspcetHeight != oldValue?.aspcetHeight else { return }
                self.adRecalculating()
                self.stations = self.tabItem.stationDataSource
            }
        }
    }
    
    init(style: UITableView.Style, tabItem: TabItemCase) {
        self.tabItem = tabItem
        searchResultData = tabItem.stationDataSource
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {    
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        nativeAd = UIApplication.mapViewController?.nativeAd
        setupObserve()
    }
    
    private func setupObserve() {
        observation = DataManager.shared.observe(\.lastUpdate, options: [.initial, .new]) { [unowned self] (_, _) in
            DispatchQueue.main.async {
                self.stations = self.tabItem.stationDataSource
            }
        }
    }
    
    func invilidateObserver() {
        observation?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
        tableView.register(UINib(nibName: "NativeAdTableViewCell", bundle: nil), forCellReuseIdentifier: adid)
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        
        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        adRecalculating()
        searchBar.setTextField(color: UIColor.white.withAlphaComponent(0.3))
        searchBar.setPlaceholder(textColor: UIColor.white.withAlphaComponent(0.8))
        searchBar.set(textColor: .white)
    }
    
    private var stations: [BatteryStationPointAnnotation]  {
        set {
            var result = searchText.isEmpty ? newValue : newValue.filter(text: searchText)
            searchResultData = nativeAd == nil ? result : result.ads(array: ads)
        }
        get { tabItem.stationDataSource }
    }
    
    var searchResultData: [BatteryStationPointAnnotation] = [] {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupAds() {
        guard let nativeAd = self.nativeAd else { return }
        for case let adCells as NativeAdTableViewCell in tableView.visibleCells {
            adCells.combind(nativeAd: nativeAd)
            break
        }
    }
    
    private func adRecalculating() {
        fequentlyAdShow = adfequently()
        ads = recalculator()
    }
    
    private let adid: String = "ads"
    
    private func adfequently() -> Int {
        let cellHeight = tableView.visibleCells.first?.bounds.height ?? 100
        let adHeight = nativeAd?.aspcetHeight ?? 200
        return Int((tableView.frame.height + adHeight) / max(cellHeight, 1)) + 2
    }
    
    private func recalculator() -> [BatteryStationPointAnnotation] {
        (0...(stations.count / max(fequentlyAdShow, 1)))
            .map { BatteryStationPointAnnotation(ad: adid, insert: $0 * fequentlyAdShow + 3)   }
    }
    
    private var fequentlyAdShow: Int = 0
    
    private var ads: [BatteryStationPointAnnotation] = []
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !searchResultData.isEmpty, searchResultData[indexPath.row].address == adid, let nativeAd = nativeAd {
            return nativeAd.aspcetHeight + 100
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        header.countLabel.text = "\(nativeAd == nil ? searchResultData.count : max(searchResultData.count - ads.count, 0)) 站"
        header.regionLabel.text = searchText.isEmpty ? "總共: " : "過濾關鍵字：\(searchText)"
        return header
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResultData.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let nativeAd = nativeAd, searchResultData[indexPath.row].address == adid {
            (cell as? NativeAdTableViewCell)?.combind(index: indexPath.row + 1, nativeAd: nativeAd)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let station = searchResultData[indexPath.row]
        
        if station.address == adid {
            return tableView.dequeueReusableCell(withIdentifier: adid) ?? NativeAdTableViewCell.builder()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        cell.addressLabel.text = station.address.matches(with: "^[^()]*".regex).first
        cell.titleLabel.text = "\(indexPath.row + 1). \(station.title ?? "")"
        cell.subtitleLabel.text = locationManager.userLocation
            .map { "距離：\(station.distance(from: $0).km) 公里" }
        if let checkinCount = station.checkinCounter, let checkdate = station.checkinDay {
            cell.checkinLabel.text = "打卡次數: \(checkinCount) (最新日期：\(checkdate.string(dateformat: "yyyy.MM.dd")))"
        } else {
            cell.checkinLabel.text = nil
        }
        cell.statusIconImageView.image = station.iconImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard searchResultData[indexPath.row].address != adid else { return }
        searchBar.resignFirstResponder()
        UIApplication.mapViewController?.mapViewMove(to: searchResultData[indexPath.row])
    }
}

extension GADUnifiedNativeAd {
    
    var aspcetHeight: CGFloat {
        mediaContent.aspectRatio == 0 ? 0 : UIScreen.main.bounds.width / mediaContent.aspectRatio
    }
}
