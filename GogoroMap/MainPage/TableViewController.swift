//
//  TableViewController.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/7/17.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class TableViewController: UITableViewController, UISearchBarDelegate, ADSupportable {
    
    var bannerView: GADBannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
    
    private var observation: NSKeyValueObservation?
    
    private var searchText: String = ""
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserve()
        setupAd(with: view)
        title = "站點列表"
        tableView.register(UINib(nibName: "TableViewHeaderView", bundle: .main), forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    private func setupObserve() {
        observation  = DataManager.shared.observe(\.lastUpdate, options: [.new, .initial, .old]) { [unowned self] (dataManager, changed) in
            self.groupData = TableViewGroupDataManager(dataManager.stations, closure: self.groupHandler)
            self.tableView.reloadData()
        }
    }
    
    private let groupHandler: (Response.Station) -> String = {
        $0.name.localized()?.matches(with: "^[^市縣]*".regex).first ?? ""
    }
    
    deinit {
        observation?.invalidate()
    }
    
    private var rawData: TableViewGroupDataManager<Response.Station>!
    private var groupData: TableViewGroupDataManager<Response.Station> {
        set {
            rawData = newValue
        }
        get {
            guard !searchText.isEmpty, let rawDataModal = rawData else {
                return rawData
            }
            
            let searchResult = rawDataModal.reduce([Response.Station]()) { $0 + $1.value.filter {
                $0.name.localized()?.contains(searchText) ?? false || $0.address.localized()?.contains(searchText) ?? false}
            }
            return TableViewGroupDataManager(searchResult, closure: groupHandler)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupData.numberOfSection
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let indexPath = IndexPath(row: .max, section: section)
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        header.countLabel.text = "\(groupData.numberOfRowsInSection(indexPath: indexPath)) 站"
        header.regionLabel.text = groupData.title(indexPath: indexPath)
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupData.numberOfRowsInSection(indexPath: IndexPath(row: .max, section: section))
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let title = groupData[indexPath].name.localized()
        cell.textLabel?.text = (title?.isEmpty ?? true) ? "  敬請期待  " : title
        cell.textLabel?.textAlignment = (title?.isEmpty ?? true) ? .center : .natural
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mapViewController = navigationController?.viewControllers.first(where: { $0.isKind(of: MapViewController.self) }) as? MapViewController {
            navigationController?.popViewController(animated: false)
            mapViewController.mapViewMove(to: groupData[indexPath].mkPointAnnotation)
        }
    }
}
