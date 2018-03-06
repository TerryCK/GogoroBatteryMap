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



class BackupViewController: UIViewController, CloudBackupable {
    let cellID = "CellID"
    
    
    let backupHeadView = HeadCellView(title: "資料備份", subltitle: "建立一份備份資料，當機器損壞或遺失時，可以從iCloud回復舊有資料")
    let restoreHeadView = HeadCellView(title: "資料還原", subltitle: "從iCloud中選擇您要還原的備份資料的時間點以還原舊有資料")
    
    let backupfooterView = FooterView(title: "目前沒有登入的iCloud帳號", subltitle: "最後更新日: \(UserDefaults.standard.getLastBackupTime())")
    
    
    let backupCell = CustomTableViewCell(type: .none, title: "立即備份", titleColor: .grassGreen)
    let deleteCell = CustomTableViewCell(type: .none, title: "刪除備份", titleColor: .red)
    
    
    lazy var backupElement = BackupElement(titleView: backupHeadView, cells: [backupCell], footView: backupfooterView, elementType: .backup)
    
    lazy var restoreElement = BackupElement(titleView: restoreHeadView, cells: backupCells, footView: nil, elementType: .delete)
    
    
    lazy var elements: [BackupElement] = [backupElement, restoreElement]
    
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    
    lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 20, width: fullScreenSize.width, height: fullScreenSize.height - 20)
        let myTableView = UITableView(frame: frame, style: .grouped)
        myTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellID)
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        myTableView.allowsSelection = true
        myTableView.allowsMultipleSelection = false
        return myTableView
    }()
    
    

    
    
    var cloudAccountStatus = CKAccountStatus.noAccount {
        didSet {
            DispatchQueue.main.async {
                self.checkAccountStatus()
            }
        }
    }
    
    func checkAccountStatus() {
        
        switch cloudAccountStatus {
        case .available:
            enableBackup()
            
        default:
            disableBackup()
        }
        tableView.reloadData()
    }
    
    private func enableBackup() {
        backupCell.isUserInteractionEnabled = true
        deleteCell.isUserInteractionEnabled = true
        backupCell.titleColor = .grassGreen
        deleteCell.titleColor = .red
        queryingBackupData()
        
    }
    
   private func disableBackup() {
        backupCell.isUserInteractionEnabled = false
        deleteCell.isUserInteractionEnabled = false
        backupCell.titleColor = .gray
        deleteCell.titleColor = .gray
        backupfooterView.titleLabel.text = "目前沒有登入的iCloud帳號"
        backupfooterView.subtitleLabel.text = "無法取得最後更新日"
        backupCells = [CustomTableViewCell(type: .none, title: "暫無資料", titleColor: .black)]
        
    }
    
    
    var backupCells: [CustomTableViewCell] = [] {
        didSet {
            elements[1].cells = backupCells
            tableView.reloadData()
        }
    }
    
    var backupDatas: [BackupData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.backupCells = self.backupDatas.toCustomTableViewCell + [self.deleteCell]
            }
        }
    }
    override func loadView() {
        super.loadView()
        setupNavigationTitle()
        setupTableView()
        backupElement.footView?.titleLabel.updateUserStatus { self.cloudAccountStatus = $0 }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserve()
        queryingBackupData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    private func setupNavigationTitle() {
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "備份與還原"
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



//MARK: - UITableView
extension BackupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements[section].cells?.count ?? 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return elements[indexPath.section].cells?[indexPath.row] ?? CustomTableViewCell(type: .none)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard cloudAccountStatus == .available else { return }
        
        let cell = elements[indexPath.section].cells?[indexPath.row] ?? CustomTableViewCell(type: .none)
        let backupType = elements[indexPath.section].elementType
        let cellType = cell.cellType
        let cellTitleColor = cell.titleLabel.textColor
        switch (cellType, backupType) {
        case (.switchButton, _):
            print("switchButton cell")
            
        case (.none, .backup):

            
            UserDefaults.standard.databaseToData?.backupToCloud(completeHandler: queryingBackupData)
            
            print("doing backup")
//            backupfooterView.subtitleLabel.text = "最新備份時間: \(Date.now)"
            
            
        case (.none, .delete):
            print("deleted all backup on cloud")
            
            
            
            
        case (.backupButton, _):
            print("doing recovery")
            
            backupDatas[indexPath.row].data?.updataNotifiy()
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        cell.titleLabel.textColor = cellTitleColor
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return elements[section].titleView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
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
        backupElement.footView?.titleLabel.updateUserStatus { self.cloudAccountStatus = $0 }
    }
    
    
}

struct BackupElement {
    let titleView: HeadCellView?
    var cells: [CustomTableViewCell]?
    let footView: FooterView?
    let elementType: BackupStatus
}

enum BackupStatus {
    case backup
    case delete
}


class FooterView: HeadCellView {
    override lazy var titleLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "title Label"
        myLabel.font = UIFont.systemFont(ofSize: 16)
        myLabel.textColor = .gray
        myLabel.textAlignment = .center
        return myLabel
    }()
}

class HeadCellView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init(title:String?, subltitle:String?) {
        self.init()
        self.titleLabel.text = title ?? ""
        self.subtitleLabel.text = subltitle ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     lazy var titleLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "title Label"
        myLabel.font = UIFont.systemFont(ofSize: 16)
        myLabel.textColor = .gray
        return myLabel
    }()
    
    lazy var subtitleLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "subtitleTextView init(coder:) has not been implemented init(coder:) has not been implemented init(coder:) has not been implemented"
        myLabel.font = UIFont.systemFont(ofSize: 16)
        myLabel.numberOfLines = 0
        myLabel.textColor = .lightGray
        return myLabel
    }()
    
    private func setupView() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 12, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 22)
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
}


struct BackupData {
    let timeInterval: TimeInterval?
    let data: Data?
    var checkinCount: Int { return data?.toAnnoatations?.totalCheckin ?? 0 }
}
