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

class BackupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CloudBackupable {
    
    let cellID = "CellID"
    
    let backupHeadView = HeadCellView(title: "資料備份", subltitle: "建立一份備份資料，當你的機器損壞或遺失時，iCloud雲端回復舊有資料")
    let restoreHeadView = HeadCellView(title: "資料還原", subltitle: "從iCloud中選擇您要還原的資料備份，回復舊有狀態")
    let backupfooterView = FooterView(title: "footTitle", subltitle: "最後更新日: \(UserDefaults.standard.getLastBackupTime())")
    
    let myCell = CustomTableViewCell(type: .custom, title: "自動備份")
    let myCell2 = CustomTableViewCell(type: .none, title: "開始備份", titleColor: .grassGreen)
    let myCell3 = CustomTableViewCell(type: .none, title: "刪除備份", titleColor: .red)
    let myCell4 = CustomTableViewCell(type: .backupData, title: "2017-11-03, 12:00:01", subtitle: "備份 - 31 KB")
    
    lazy var backupElement = BackupElement(titleView: backupHeadView, cells: [myCell2], footView: backupfooterView, elementType: .backup)
    lazy var restoreElement = BackupElement(titleView: restoreHeadView, cells: backupCells, footView: nil, elementType: .restore)
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    var backupCells: [CustomTableViewCell] = [] {
        didSet {
            elements[1].cells = backupCells
            tableView.reloadData()
        }
    }
    
    var backupDatas: [BackupData] = [] {
        didSet {
            print(backupDatas.count)
            DispatchQueue.main.async {
                let backups = self.backupDatas.sorted {
                        $0.timeInterval ?? 0.0  > $1.timeInterval ?? 0.0
                    }.map {
                        CustomTableViewCell(type: .backupData, title: $0.timeInterval?.toTimeString ?? "", subtitle: "備份 - \(String(describing: $0.data?.sizeString() ?? ""))") }
                
                self.backupCells = backups + [self.myCell3]
            }
            
        }
    }
    

    func setupView() {
       
        query { (records, error) in
            guard error == nil, let records = records else {
                print("cloud query error:", error!)
                return
            }
            print("quering")
            self.backupDatas = records.map {
                let creationData = $0.creationDate?.timeIntervalSince1970
                let data = $0.value(forKey: self.recordKey) as? Data
                return BackupData(timeInterval: creationData, data: data)
            }
            
            
        }
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .grassGreen
        setupNavigationTitle()
        setupTableView()
        
    }
    
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    private func setupNavigationTitle() {
        self.navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "備份與還原"
    }
    
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CustomTableViewCell
//        cell = elements[indexPath.section].cell?[indexPath.row]
        
        return elements[indexPath.section].cells?[indexPath.row] ?? CustomTableViewCell(type: .none)
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = elements[indexPath.section].cells?[indexPath.row] ?? CustomTableViewCell(type: .none)
        let backupType = elements[indexPath.section].elementType
        let cellType = cell.cellType
        let cellTitleColor = cell.titleLabel.textColor
        switch (cellType, backupType) {
        case (.custom, _):
            
            print("custom cell")
        case (.none, .backup):

            UserDefaults.standard.saveDataToCloudFromDatabase()
            UserDefaults.standard.saveNowTime(with: Date.now)
            print("doing backup")
            backupfooterView.subtitleLabel.text = "最新備份時間: \(Date.now)"
        case (.none, .restore):
            
            print("doing restore")
            
        case (.backupData, _):
            print("downLoad")
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

struct BackupElement {
    let titleView: HeadCellView?
    var cells: [CustomTableViewCell]?
    let footView: UIView?
    let elementType: BackupStatus
}

enum BackupStatus {
    case backup
    case restore
}

class FooterView: HeadCellView {
    override lazy var titleLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "title Label"
        myLabel.font = UIFont.systemFont(ofSize: 16)
        myLabel.textColor = .gray
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
        myLabel.font = UIFont.systemFont(ofSize: 20)
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
    
    func setupView() {
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 12, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 22)
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
    }
    
}

struct BackupData {
    let timeInterval: TimeInterval?
    let data: Data?
    
}
