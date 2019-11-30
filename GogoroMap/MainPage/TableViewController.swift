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
extension Array where Element: BatteryDataModalProtocol {
    mutating func ads(array: Array) -> Array {
        for adCell in array  {
            if adCell.state < count {
                insert(adCell, at: Swift.max(0, adCell.state - 1))
            } else {
                append(adCell)
            }
        }
        return self
    }
}


final class TableViewController: UITableViewController, ViewTrackable {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var searchText = "" {
        didSet {
            guard !searchText.isEmpty else { return }
            DispatchQueue.global().async {
                self.searchResultData = self.stations.filter(text: self.searchText)
            }
        }
    }
    
    private let locationManager: LocationManager = .shared
    
    let tabItem: TabItemCase
    
    var nativeAdLoader: GADAdLoader?
    
    var nativeAd: GADUnifiedNativeAd?
    
    init(style: UITableView.Style, tabItem: TabItemCase) {
        self.tabItem = tabItem
        searchResultData = tabItem.stationDataSource
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        
        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        searchBar.setTextField(color: UIColor.white.withAlphaComponent(0.3))
        searchBar.setPlaceholder(textColor: UIColor.white.withAlphaComponent(0.8))
        searchBar.set(textColor: .white)
        nativeAdLoader = GADAdLoader.createNativeAd(delegate: self)
    }
    
    var stations: [BatteryStationPointAnnotation]  {
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
    
    private let adid: String = "ads"
    
    private let fequentlyAdShow = 8
    
    var ads: [BatteryStationPointAnnotation] {
        (0...(stations.count / fequentlyAdShow)).map { BatteryStationPointAnnotation(ad: adid, insert: $0 * fequentlyAdShow + 3)   }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchResultData[indexPath.row].address == adid, let nativeAd = nativeAd {
            return nativeAd.aspcetHeight + 100
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        header.countLabel.text = "\(max(searchResultData.count - ads.count, 0)) 站"
        header.regionLabel.text = searchText.isEmpty ? "總共: " : "過濾關鍵字：\(searchText)"
        return header
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResultData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let station = searchResultData[indexPath.row]
        
        if let nativeAd = nativeAd, station.address == adid {
            return NativeAdTableViewCell.builder().combind(index: indexPath.row + 1, nativeAd: nativeAd)
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") as! TableViewCell
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
        
        guard searchResultData[indexPath.row].address != adid else {
            return
        }
        
        searchBar.resignFirstResponder()
        UIApplication.mapViewController?.mapViewMove(to: searchResultData[indexPath.row])
    }
}


 
extension TableViewController: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        debugPrint("TableViewController recived an native ad: ", nativeAd)
        DispatchQueue.global().async {
            self.nativeAd = nativeAd
            self.nativeAd?.delegate = self
            self.stations = self.tabItem.stationDataSource
        }
    }
}

extension TableViewController: GADUnifiedNativeAdDelegate, NativeAdIdentify {
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("TableViewController: didFailToReceiveAdWithError ", error)
    }
    
    var nativeAdID: String {
        switch Environment.environment {
        case .debug  : return "ca-app-pub-3940256099942544/3986624511"
        case .release: return Keys.standard.tableViewNativeAdID
        }
    }
    
    
}

extension GADUnifiedNativeAd {
    var aspcetHeight: CGFloat {
        mediaContent.aspectRatio == 0 ? 0 : UIScreen.main.bounds.width / mediaContent.aspectRatio
    }
}
