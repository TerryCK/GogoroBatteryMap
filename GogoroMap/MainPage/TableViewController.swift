//
//  TableViewController.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/17.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol SearchableViewControllerProtocol: UIViewController, UISearchBarDelegate {
    associatedtype DataSource
    var rawData: DataSource { get set }
    var searchResultData: DataSource { get set }
    var searchText: String { get set }
    func apply(searchText: String) -> DataSource
}

protocol Searchable {
    func apply(searchText: String) -> Self
}

extension TableViewGroupDataManager: Searchable where Element: ResponseStationProtocol {
    func apply(searchText: String) -> TableViewGroupDataManager<Element> {
        <#code#>
    }
    
    
}


final class TableViewController: UITableViewController, UISearchBarDelegate, ADSupportable, SearchableViewControllerProtocol {
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
    
    private var observation: NSKeyValueObservation?
    
    var searchText: String = "" {
        didSet {
            searchResultData = apply(searchText: searchText)
        }
    }
    
    func apply(searchText: String) -> TableViewGroupDataManager<Response.Station> {
        guard !searchText.isEmpty else {
           return rawData
        }
        let searchResult = rawData.reduce([Response.Station]()) { $0 + $1.value.filter {
            $0.name.localized()?.contains(searchText) ?? false || $0.address.localized()?.contains(searchText) ?? false}
        }
       return TableViewGroupDataManager(searchResult, closure: groupHandler)
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
        DataManager.shared.fetchStations { (_) in }
    }
    
    private func setupObserve() {
        observation  = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (dataManager, changed) in
            self.rawData = TableViewGroupDataManager(dataManager.stations, closure: self.groupHandler)
            DispatchQueue.main.async(execute: self.tableView.reloadData)
        }
    }
    
    private let groupHandler: (Response.Station) -> String = {
        $0.address.localized()?.matches(with: "^[^市縣]*".regex).first ?? ""
    }
    
    deinit {
        observation?.invalidate()
    }
    
     var rawData: TableViewGroupDataManager<Response.Station> = TableViewGroupDataManager([Response.Station]()) {
        didSet {
            searchResultData = apply(searchText: searchText)
        }
    }
    
    
     var searchResultData: TableViewGroupDataManager<Response.Station> = TableViewGroupDataManager([Response.Station]()) {
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
        let title = searchResultData[indexPath].name.localized()
        cell.textLabel?.text = (title?.isEmpty ?? true) ? "  敬請期待  " : title
        cell.textLabel?.textAlignment = (title?.isEmpty ?? true) ? .center : .natural
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapViewController = navigationController?.viewControllers.first(where: { $0.isKind(of: MapViewController.self) }) as? MapViewController {
            navigationController?.popViewController(animated: false)
            mapViewController.mapViewMove(to: searchResultData[indexPath].mkPointAnnotation)
        }
    }
}
