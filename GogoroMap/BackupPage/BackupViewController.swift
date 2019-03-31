//
//  BackupViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 02/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

/*TODO: - 1.deleted all cloud Data
 2.quering data with < 10 items
 3.download and restore data which user selected
 4.backup and reload tableView when backupd
 5.refactoring code
 */


import UIKit
import CloudKit

final class BackupViewController: UITableViewController {
    
    weak var stations: StationDataSource?
    
    private let backupHeadView = HeadCellView(title: "資料備份", subltitle: "建立一份備份資料，當機器損壞或遺失時，可以從iCloud回復舊有資料")
    private let restoreHeadView = HeadCellView(title: "資料還原", subltitle: "從iCloud中選擇您要還原的備份資料的時間點以還原舊有資料")
    private let backupfooterView = FooterView(title: "目前沒有登入的iCloud帳號", subltitle: "最後更新日: \(UserDefaults.standard.string(forKey: Keys.standard.nowDateKey) ?? "")")
    
    
    private let backupCell = BackupTableViewCell(type: .none, title: "立即備份", titleColor: .grassGreen)
    private let deleteCell = BackupTableViewCell(type: .none, title: "刪除備份", titleColor: .red)
    
    
    private lazy var backupElement = BackupElement(titleView: backupHeadView, cells: [backupCell], footView: backupfooterView, type: .backup)
    
    private lazy var restoreElement = BackupElement(titleView: restoreHeadView, cells: nil, footView: nil, type: .delete)
    
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
            elements[1].cells = [BackupTableViewCell(type: .none, title: "暫無資料", titleColor: .black)]
        }
        backupfooterView.subtitleLabel.text = cloudAccountStatus.description
        tableView.reloadData()
    }
    
    var records: [CKRecord]? {
        didSet {
            records?.sort { $0.creationDate > $1.creationDate }
            let subtitleText: String?
            
            if let records = records, let date = records.first?.creationDate?.string(dateformat: "yyyy.MM.dd  hh:mm:ss") {
                elements[1].cells = records.enumerated().flatMap(BackupTableViewCell.init) + [deleteCell]
                subtitleText = "最新備份時間：\(date)"
            } else {
                elements[1].cells = nil
                subtitleText = nil
            }
            
            DispatchQueue.main.async {
                self.backupfooterView.subtitleLabel.text = subtitleText
                if self.records?.isEmpty ?? true {
                    self.tableView.reloadData()
                } else {
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        checkTheCloudAccountStatus()
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "備份與還原"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserve()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        CKContainer.default().fetchData { self.records = $0  }
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
        switch (elements[indexPath.section].cells?[indexPath.row].cellType, elements[indexPath.section].type) {
            
        case (.switchButton?, _):
            print("switchButton cell")
            
        case (.none?, .backup):
            _ = stations
                .flatMap { try? JSONEncoder().encode($0.batteryStationPointAnnotations) }
                .map { CKContainer.default().save(data: $0) {
                    guard let newRecord = $0 else { return }
                    switch self.records {
                    case .none: self.records = [newRecord]
                    case let records?: self.records = records + [newRecord]
                    }
                    }}
            
        case (.none?, .delete):
            print("deleted all backup on cloud")
            records?.forEach {
                
                CKContainer.default().privateCloudDatabase.delete(withRecordID: $0.recordID) { (recordID, error) in
                    guard error == nil,
                        let recordID = recordID,
                        let index = self.records?.map({ $0.recordID }).index(of: recordID) else { return }
                    
                    
                    self.records?.remove(at: index)
                }
            }
            
            
            
            
            
        case (.backupButton?, _):
            print("doing recovery")
            
            //            backupDatas[indexPath.row].data?.updataNotifiy()
            
        default: break
        }
        
        
        
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

struct BackupElement {
    enum type { case backup, delete }
    let titleView: HeadCellView?
    var cells: [BackupTableViewCell]?
    let footView: FooterView?, type: type
}




final class FooterView: HeadCellView {
    override func setupView() {
        super.setupView()
        titleLabel.textAlignment = .center
    }
}

class HeadCellView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(title: String?, subltitle: String?) {
        self.init()
        titleLabel.text = title
        subtitleLabel.text = subltitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    lazy var titleLabel = UILabel {
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    lazy var subtitleLabel = UILabel {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.textColor = .lightGray
    }
    
    func setupView() {
        [titleLabel, subtitleLabel].forEach(addSubview)
        
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 12, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 22)
        
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
}

