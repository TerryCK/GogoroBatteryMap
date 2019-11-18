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

extension TableViewController: ADSupportable {
    
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bridgeAd(bannerView)
    }
}

extension TableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       
        UIApplication.mapViewController?.fpc.move(to: .full, animated: true)
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
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        segmentStatus = SegmentStatus(rawValue: selectedScope) ?? .nearby
    }
}

final class TableViewController: UITableViewController, ViewTrackable {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
    private var observation: NSKeyValueObservation?

    
    private var searchText = "" {
        didSet {
            DispatchQueue.global().async {
                self.searchResultData = self.stations.filter(self.segmentStatus.hanlder).filter(text: self.searchText)
            }
        }
    }

    private let locationManager: LocationManager = .shared
    
    var segmentStatus: SegmentStatus = .nearby {
        didSet {
            DispatchQueue.global().async {
                self.stations = self.stations.sorted(userLocation: self.locationManager.userLocation, by: <)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        setupAd(with: tableView)
        setupObserve()
        tableView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        searchBar.setTextField(color: UIColor.white.withAlphaComponent(0.3))
        searchBar.setPlaceholder(textColor: UIColor.white.withAlphaComponent(0.8))
        searchBar.set(textColor: .white)
    }
    
    
    private func setupObserve() {
        observation = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (_, _) in
            self.stations = DataManager.shared.stations.sorted(userLocation: self.locationManager.userLocation, by: <)
        }
    }
    
    deinit {
        observation?.invalidate()
    }
    
    private var stations = DataManager.shared.stations {
        didSet {
            searchResultData = stations.filter(segmentStatus.hanlder).filter(text: searchText)
        }
    }
    
    private var searchResultData = DataManager.shared.stations {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentStatus = .nearby
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        header.countLabel.text = "\(searchResultData.count) 站"
        header.regionLabel.text = searchText.isEmpty ? segmentStatus.name : "過濾關鍵字：\(searchText)"
        return header
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        let station = searchResultData[indexPath.row]
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
        searchBar.resignFirstResponder()
         UIApplication.mapViewController?.mapViewMove(to: searchResultData[indexPath.row])
    }
}

extension UIColor {
    
    enum Colors {
        static let label: UIColor = {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .white
            }
        }()
        static let tint: UIColor = {
            guard  #available(iOS 13.0, *) else {
                return .white
            }
            return UIColor { $0.userInterfaceStyle == .dark ? .white : .lightText }
        }()
    }
}
