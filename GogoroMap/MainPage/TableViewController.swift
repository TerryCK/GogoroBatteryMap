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
        tableView.contentOffset = .init(x: 0, y: 56)
        searchBar.setTextField(color: UIColor.white.withAlphaComponent(0.3))
        searchBar.setPlaceholder(textColor: UIColor.white.withAlphaComponent(0.8))
        searchBar.set(textColor: .white)
    }
    
    var stations: [BatteryStationPointAnnotation]  {
        set { searchResultData = searchText.isEmpty ? newValue : newValue.filter(text: searchText)  }
        get { tabItem.stationDataSource }
    }
    
    var searchResultData: [BatteryStationPointAnnotation] = [] {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeaderView") as! TableViewHeaderView
        header.countLabel.text = "\(searchResultData.count) 站"
        header.regionLabel.text = searchText.isEmpty ? "總共: " : "過濾關鍵字：\(searchText)"
        return header
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResultData.count
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
