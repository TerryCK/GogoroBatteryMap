//
//  BackupViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 02/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit
import CloudKit
import GoogleMobileAds
import Crashlytics


extension BackupViewController: ADSupportable {
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Google Ad error: \(error)")
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        didReceiveAd(bannerView)
    }
}

final class BackupViewController: UITableViewController {
    
    var bannerView = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: UIScreen.main.bounds.width, height: 50)))
    
    let adUnitID: String = Keys.standard.backupAdUnitID
    private let backupHeadView = SupplementaryCell(title: "資料備份", subtitle: "建立一份備份資料，當機器損壞或遺失時，可以從iCloud回復舊有資料")
    private let restoreHeadView = SupplementaryCell(title: "資料還原", subtitle: "從iCloud中選擇您要還原的備份資料的時間點以還原舊有資料")
    private let backupfooterView = SupplementaryCell(title: "目前沒有登入的iCloud帳號", subtitle: "最後更新日: \(UserDefaults.standard.string(forKey: Keys.standard.nowDateKey) ?? "")", titleTextAlignment: .center)
    
    
    private let backupCell = BackupTableViewCell(type: .none, title: "立即備份", titleColor: .gray)
    private let deleteCell = BackupTableViewCell(type: .none, title: "刪除全部的備份資料", titleColor: .red)
    
    private let noDataCell = BackupTableViewCell(type: .none, title: "暫無資料", titleColor: .lightGray)
    private lazy var backupElement = BackupElement(titleView: backupHeadView, cells: [backupCell], footView: backupfooterView, type: .backup)
    
    private lazy var restoreElement = BackupElement(titleView: restoreHeadView, cells: [noDataCell], footView: SupplementaryCell(), type: .delete)
    
    private lazy var elements: [BackupElement] = [backupElement, restoreElement]
    
    
    var cloudAccountStatus = CKAccountStatus.noAccount {
        didSet {
            DispatchQueue.main.async(execute: checkAccountStatus)
        }
    }
    
    private func checkAccountStatus() {
        backupCell.isUserInteractionEnabled = cloudAccountStatus == .available
        deleteCell.isUserInteractionEnabled = cloudAccountStatus == .available
        backupCell.titleLabel.textColor = cloudAccountStatus == .available ? .grassGreen : .gray
        deleteCell.titleLabel.textColor = cloudAccountStatus == .available ? .red        : .gray
        switch cloudAccountStatus {
        case .available:
            CKContainer.default().fetchUserID { self.backupfooterView.titleLabel.text = $0 }
        default:
            backupfooterView.titleLabel.text = "目前沒有登入的iCloud帳號"
            backupfooterView.subtitleLabel.text = "無法取得最後更新日"
            elements[1].cells = [noDataCell]
        }
        backupfooterView.subtitleLabel.text = cloudAccountStatus.description
        tableView.reloadData()
    }
    
    var records: [CKRecord]? {
        didSet {
            records?.sort { $0.creationDate > $1.creationDate }
            let dataSize = records?.reduce(0) { $0 + (($1.value(forKey: "batteryStationPointAnnotation") as? Data)?.count ?? 0) }
            DispatchQueue.main.async {
                let subtitleText: String?
                if let records = self.records, let date = records.first?.creationDate?.string(dateformat: "yyyy.MM.dd  hh:mm:ss") {
                    self.elements[1].cells = records
                        .compactMap { (($0.value(forKey: "batteryStationPointAnnotation") as? Data), $0.creationDate?.string(dateformat: "yyyy.MM.dd   HH:mm:ss")) }
                        .enumerated()
                        .compactMap { (index, element) in
                            guard let data = element.0, let batteryRecords = try? JSONDecoder().decode([BatteryStationRecord].self, from: data) else { return nil }
                            let size = BackupTableViewCell.byteCountFormatter.string(fromByteCount: Int64(data.count))
                            return BackupTableViewCell(title: "\(index + 1). 上傳時間: \(element.1 ?? "")",
                                subtitle: "檔案容量: \(size), 打卡次數：\(batteryRecords.reduce(0) { $0 + $1.checkinCount })" ,
                                stationRecords: batteryRecords)
                        } + [self.deleteCell]
                    
                    
                    subtitleText = "最新備份時間：\(date)"
                } else {
                    self.elements[1].cells = [self.noDataCell]
                    subtitleText = nil
                }
                if let dataSize = dataSize {
                    self.elements[1].footView?.titleLabel.text = "iCloud 已使用儲存容量：" + BackupTableViewCell.byteCountFormatter.string(fromByteCount: Int64(dataSize))
                }
                self.backupfooterView.subtitleLabel.text = subtitleText
                self.tableView.reloadData()
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        checkTheCloudAccountStatus()
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Answers.log(view: "backup page")
        setupObserve()
        setupAd(with: view)
       
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        navigationItem.title = "資料更新中..."
        CKContainer.default().fetchData { (records, error) in
            self.records = records
            self.navigationItem.title = error == nil ? "備份與還原" : "發生錯誤，請稍後嘗試"
            self.backupCell.isUserInteractionEnabled = error == nil
            DispatchQueue.main.async(execute: self.tableView.reloadData)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



//MARK: - UITableView
extension BackupViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements[section].cells?.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return elements.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return elements[indexPath.section].cells?[indexPath.row] ?? BackupTableViewCell(type: .none)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard cloudAccountStatus == .available else { return }
        let cell = elements[indexPath.section].cells?[indexPath.row]
        switch (cell?.cellType, elements[indexPath.section].type) {
        case (.none?, .backup):
            cell?.isUserInteractionEnabled = false
            cell?.titleLabel.text = "資料備份中..."
            guard  let data = try? JSONEncoder().encode(DataManager.shared.stations.compactMap(BatteryStationRecord.init)) else { return }
            CKContainer.default().save(data: data) { (newRecord, error) in
                cell?.isUserInteractionEnabled = true
                cell?.titleLabel.text = "立即備份"
                guard let newRecord = newRecord else { return }
                switch self.records {
                case .none: self.records = [newRecord]
                case let records?: self.records = records + [newRecord]
                }
            }
            
            
        case (.none?, .delete):
            
            let alertController = UIAlertController(title: "要刪除所有備份資料？", message: "所有備份資料將從iPhone及iCloud刪除，無法復原。", preferredStyle: .actionSheet)
            [
                UIAlertAction(title: "刪除", style: .destructive, handler : { _ in
                    self.elements[indexPath.section].cells?.forEach {
                        guard $0.cellType == .backupButton else { return }
                        $0.titleLabel.text = "備份資料刪除中..."
                        $0.subtitleLabel.text = nil
                    }
                    
                    self.records?.forEach {
                        CKContainer.default().privateCloudDatabase.delete(withRecordID: $0.recordID) { (recordID, error) in
                            guard error == nil,
                                let recordID = recordID,
                                let index = self.records?.map({ $0.recordID }).firstIndex(of: recordID) else { return }
                            self.records?.remove(at: index)
                        }
                    }}),
                UIAlertAction(title: "取消", style: .cancel, handler: nil),
                ].forEach(alertController.addAction)
            self.present(alertController, animated: true)
            
        case (.backupButton?, _):
            let alertController =  UIAlertController(title: "要使用此資料？", message: "當前地圖資訊將被備份資料取代", preferredStyle: .actionSheet)
            [
                UIAlertAction(title: "使用", style: .destructive, handler : { _ in
                    DataManager.shared.fetchStations{ (result) in
                        NetworkActivityIndicatorManager.shared.networkOperationStarted()
                        self.navigationItem.title = "資料覆蓋中..."
                        guard case .success(let stations) = result, let stationRecords = self.elements[1].cells?[indexPath.row].stationRecords else { return }
                        stationRecords.forEach {
                            for station in stations where $0.id == station.coordinate {
                                (station.checkinDay, station.checkinCounter) = ($0.checkinDay, $0.checkinCount)
                                return
                            }
                        }
                        NetworkActivityIndicatorManager.shared.networkOperationFinished()
                        self.navigationItem.title = "備份與還原"
                    }
                }),
                UIAlertAction(title: "取消", style: .cancel, handler: nil),
                ].forEach(alertController.addAction)
            
            present(alertController, animated: true)
        default: break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return elements[indexPath.section].cells?[indexPath.row].cellType == .some(.backupButton)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "刪除") { (action, indexPath) in
            let alertController = UIAlertController(title: "要刪除資料？", message: "此筆資料將從iPhone及iCloud刪除，無法復原。", preferredStyle: .actionSheet)
            [
                UIAlertAction(title: "刪除", style: .destructive, handler : { _ in
                    guard let record = self.records?[indexPath.row] else { return }
                    self.elements[indexPath.section].cells?[indexPath.row].titleLabel.text = "資料刪除中..."
                    self.elements[indexPath.section].cells?[indexPath.row].subtitleLabel.text = nil
                    CKContainer.default().privateCloudDatabase.delete(withRecordID: record.recordID) { (recordID, error) in
                        guard error == nil,
                            let recordID = recordID,
                            let index = self.records?.map({ $0.recordID }).firstIndex(of: recordID) else { return }
                        self.records?.remove(at: index)
                    }
                }),
                UIAlertAction(title: "取消", style: .cancel, handler: nil),
                ].forEach(alertController.addAction)
            self.present(alertController, animated: true)
        }
        
        return [delete]
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return elements[section].titleView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return elements[section].footView
    }
}

extension BackupViewController {
    private func setupObserve() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkTheCloudAccountStatus),
                                               name: .CKAccountChanged,
                                               object: nil)
    }
    
    @objc private func checkTheCloudAccountStatus() {
        CKContainer.default().accountStatus { (status, _) in self.cloudAccountStatus = status }
    }
}
