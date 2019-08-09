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


final class TableViewController: UITableViewController, UISearchBarDelegate, ADSupportable {
    
    static let shared: TableViewController = TableViewController()
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
    private var observation: NSKeyValueObservation?
    private var searchText = "" {
        didSet {
            searchResultData = stations.filter(segmentStatus.hanlder).filter(text: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    var segmentStatus: SegmentStatus = .nearby
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
        setupAd(with: view)
    }
    
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        switch parent {
        case .some(let parent as MapViewController) :
            observation = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (dataManager, changed) in
                self.stations = dataManager.stations.sorted(userLocation: parent.locationManager.location, by: <)
            }
        default:
            observation?.invalidate()
        }
    }

    private var stations = DataManager.shared.stations {
        didSet {
            searchResultData = stations.filter(segmentStatus.hanlder).filter(text: searchText)
        }
    }

    private var searchResultData = [BatteryStationPointAnnotation]() {
        didSet {
            DispatchQueue.main.async(execute: tableView.reloadData)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        let station = searchResultData[indexPath.row]
        cell.addressLabel.text = station.address.matches(with: "^[^()]*".regex).first
        cell.titleLabel.text = "\(indexPath.row + 1). \(station.title ?? "")"
        cell.subtitleLabel.text = (parent as? MapViewController)?.locationManager.location
            .map { "距離：\(station.distance(from: $0).km) 公里"}
        cell.statusIconImageView.image = station.iconImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapViewController = parent as? MapViewController {
            mapViewController.displayContentController = nil
            mapViewController.segmentedControl.selectedSegmentIndex = SegmentStatus.map.rawValue
            mapViewController.mapViewMove(to: searchResultData[indexPath.row])
        }
    }
}
