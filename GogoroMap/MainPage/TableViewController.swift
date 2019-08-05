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

protocol SearchableViewControllerProtocol: UIViewController, UISearchBarDelegate {
    associatedtype DataSource
    var rawData: DataSource { get set }
    var searchResultData: DataSource { get set }
}

final class TableViewController: UITableViewController, UISearchBarDelegate, ADSupportable, SearchableViewControllerProtocol {
    
    static let shared: TableViewController = TableViewController()
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
    private var observation: NSKeyValueObservation?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultData = rawData.filter(searchText: searchText)
    }
    
    var segmentStatus: SegmentStatus = .nearby {
        didSet {
            searchResultData = rawData.filter(segmentStatus.hanlder)
            title = segmentStatus.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserve()
        
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "reuseIdentifier")
        setupAd(with: view)
    }
    
    
    
    private func setupObserve() {
        observation = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (dataManager, changed) in
            self.rawData = TableViewGroupDataManager(dataManager.stations,
                                                     groupKey: { $0.address.matches(with: "^[^市縣]*".regex).first ?? ""} )
        }
    }
  
    deinit {
        observation?.invalidate()
    }
    
    var rawData = TableViewGroupDataManager(DataManager.shared.stations) {
        didSet {
            if let userLocation = (parent as? MapViewController)?.userLocation {
                rawData = rawData
                    .sortedValue { $0.distance(from: userLocation) < $1.distance(from: userLocation)
                    }.sorted {
                        guard case let (a?, b?) = ($0.value.first?.distance(from: userLocation), $1.value.first?.distance(from: userLocation)) else {
                            return false
                        }
                        return a < b
                    }
            }
            searchResultData = rawData.filter(segmentStatus.hanlder)
        }
    }
    
    
    var searchResultData = TableViewGroupDataManager([BatteryStationPointAnnotation]()) {
        didSet {
            DispatchQueue.main.async(execute: tableView.reloadData)
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searchResultData.numberOfSection
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let indexPath = IndexPath(row: .max, section: section)
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        header.countLabel.text = "\(searchResultData.numberOfRowsInSection(indexPath: indexPath)) 站"
        header.regionLabel.text = searchResultData.title(indexPath: indexPath)
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultData.numberOfRowsInSection(indexPath: IndexPath(row: .max, section: section))
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        let station = searchResultData[indexPath]
        cell.goAction = { Navigator.go(to: station) }
        cell.addressLabel.text = station.address.matches(with: "^[^()]*".regex).first
        cell.titleLabel.text = "\(indexPath.row + 1). \(station.title ?? "")"
        if let userLocation = (parent as? MapViewController)?.userLocation {
            cell.subtitleLabel.text = "距離：\(station.distance(from: userLocation).km) 公里"
        }
        cell.statusIconImageView.image = station.iconImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapViewController = parent as? MapViewController {
            mapViewController.displayContentController = nil
            
            mapViewController.segmentedControl.selectedSegmentIndex = SegmentStatus.map.rawValue
            mapViewController.mapViewMove(to: searchResultData[indexPath])
        }
    }
}
