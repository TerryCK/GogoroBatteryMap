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
    var searchText: String { get set }
//    func apply(searchText: String) -> DataSource
}

final class TableViewController: UITableViewController, UISearchBarDelegate, ADSupportable, SearchableViewControllerProtocol {
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))

    private var observation: NSKeyValueObservation?
    
    var searchText: String = "" {
        didSet {
            searchResultData = rawData.apply(searchText: searchText, groupKey: groupHandler)
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserve()
        setupAd(with: view)
        title = "站點列表"
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    private func setupObserve() {
        observation = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (dataManager, changed) in
            self.rawData = TableViewGroupDataManager(dataManager.stations, closure: self.groupHandler)
            DispatchQueue.main.async(execute: self.tableView.reloadData)
        }
    }
    
    private let groupHandler: (BatteryStationPointAnnotation) -> String = {
        $0.address.matches(with: "^[^市縣]*".regex).first ?? ""
    }
    
    deinit {
        observation?.invalidate()
    }
    
    private var userLocation: MKUserLocation? {
        return (navigationController?.viewControllers.first { $0.isKind(of: MapViewController.self) } as? MapViewController)?.mapView.userLocation
    }
    
    var rawData = TableViewGroupDataManager([BatteryStationPointAnnotation]()) {
        didSet {
            if let userLocation = userLocation?.location {
                rawData = rawData
                    .sortedValue { $0.distance(from: userLocation) < $1.distance(from: userLocation)
                    }.sorted {
                        guard case let (a?, b?) = ($0.value.first?.distance(from: userLocation), $1.value.first?.distance(from: userLocation)) else {
                            return false
                        }
                        return a < b
                }
            }
            searchResultData = rawData.apply(searchText: searchText, groupKey: groupHandler).apply(searchText: searchText, groupKey: groupHandler)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let title = searchResultData[indexPath].title
        cell.textLabel?.text = (title?.isEmpty ?? true) ? "  敬請期待  " : title
        cell.textLabel?.textAlignment = (title?.isEmpty ?? true) ? .center : .natural
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapViewController = navigationController?.viewControllers.first(where: { $0.isKind(of: MapViewController.self) }) as? MapViewController {
            navigationController?.popViewController(animated: false)
            mapViewController.mapViewMove(to: searchResultData[indexPath])
        }
    }
}
