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
    
    weak var dataSource: StationDataSource?
    
    let backupHeadView = HeadCellView(title: "資料備份", subltitle: "建立一份備份資料，當機器損壞或遺失時，可以從iCloud回復舊有資料")
    let restoreHeadView = HeadCellView(title: "資料還原", subltitle: "從iCloud中選擇您要還原的備份資料的時間點以還原舊有資料")
    let backupfooterView = FooterView(title: "目前沒有登入的iCloud帳號", subltitle: "最後更新日: \(UserDefaults.standard.string(forKey: Keys.standard.nowDateKey) ?? "")")
    
    
    let backupCell = BackupTableViewCell(type: .none, title: "立即備份", titleColor: .grassGreen)
    let deleteCell = BackupTableViewCell(type: .none, title: "刪除備份", titleColor: .red)
    
    
    lazy var backupElement = BackupElement(titleView: backupHeadView, cells: [backupCell], footView: backupfooterView, elementType: .backup)
    
    lazy var restoreElement = BackupElement(titleView: restoreHeadView, cells: backupCells, footView: nil, elementType: .delete)
    
    lazy var elements: [BackupElement] = [backupElement, restoreElement]

    
    var cloudAccountStatus = CKAccountStatus.noAccount {
        didSet {
            DispatchQueue.main.async { self.checkAccountStatus() }
        }
    }
    
    private func checkAccountStatus() {
        backupCell.isUserInteractionEnabled = cloudAccountStatus == .available
        deleteCell.isUserInteractionEnabled = cloudAccountStatus == .available
        backupCell.titleLabel.textColor = cloudAccountStatus == .available ? .grassGreen : .gray
        deleteCell.titleLabel.textColor = cloudAccountStatus == .available ? .red        : .gray
        switch cloudAccountStatus {
        case .available: break //queryingBackupData()
        default:
            backupfooterView.titleLabel.text = "目前沒有登入的iCloud帳號"
            backupfooterView.subtitleLabel.text = "無法取得最後更新日"
            backupCells = [BackupTableViewCell(type: .none, title: "暫無資料", titleColor: .black)]
        }
        tableView.reloadData()
    }

    
    var backupCells: [BackupTableViewCell] = [] {
        didSet {
            restoreElement.cells = backupCells
            tableView.reloadData()
        }
    }
    
    var backupDatas: [BackupData] = [] {
        didSet {
            DispatchQueue.main.async {
//                self.backupCells = self.backupDatas.toCustomTableViewCell + [self.deleteCell]
            }
        }
    }
    
    
    override func loadView() {
        super.loadView()
//        backupElement.footView?.titleLabel.updateUserStatus { self.cloudAccountStatus = $0 }
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
//        DataManager.shared.saveToCloud(data: DataManager.shared.fetchData(from: .bundle)!) {
//            print("doing backup")
//        }
//        queryingBackupData()
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



//MARK: - UITableView
extension BackupViewController {
    
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements[section].cells?.count ?? 1
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
        guard cloudAccountStatus == .available else { return }
        let cell = elements[indexPath.section].cells?[indexPath.row] ?? BackupTableViewCell(type: .none)
        let backupType = elements[indexPath.section].elementType
        let cellType = cell.cellType
        switch (cellType, backupType) {
        case (.switchButton, _):
            print("switchButton cell")
            
        case (.none, .backup):

//            DataManager.fetchData(from: .database)?.backupToCloud(completeHandler: queryingBackupData)
            
            DataManager.shared.saveToCloud(data: DataManager.shared.fetchData(from: .bundle)!) {
                print("doing backup")
            }
           
//            backupfooterView.subtitleLabel.text = "最新備份時間: \(Date.now)"
            
            
        case (.none, .delete):
            print("deleted all backup on cloud")
            
            
            
            
        case (.backupButton, _):
            print("doing recovery")
            
//            backupDatas[indexPath.row].data?.updataNotifiy()
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkTheCloudAccountStatus),
                                               name: .CKAccountChanged,
                                               object: nil)
    }
    
    @objc private func checkTheCloudAccountStatus() {
//        backupElement.footView?.titleLabel.updateUserStatus { self.cloudAccountStatus = $0 }
    }
    
    
}

struct BackupElement {
    let titleView: HeadCellView?
    var cells: [BackupTableViewCell]?
    let footView: FooterView?, elementType: BackupStatus
}

enum BackupStatus {
    case backup, delete
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


struct BackupData {
    let timeInterval: TimeInterval?, data: Data?
    
    var checkinCount: Int {
        guard let data = data,
        let stations = (try? JSONDecoder().decode([BatteryStationPointAnnotation].self, from: data)) else { return 0 }
        return stations.reduce(0) {  $0 + ($1.checkinCounter ?? 0)  }
    }
}
