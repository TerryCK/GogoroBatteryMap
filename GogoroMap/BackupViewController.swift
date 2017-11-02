//
//  BackupViewController.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 02/11/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit

class BackupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellID = "CellID"
    
    let fullScreenSize = UIScreen.main.bounds.size
    lazy var headView: MyUIView = {
        let myView = MyUIView()
        myView.titleLabel.text = "這是客製化的Title Label"
        return myView
    }()
    lazy var backupElement = BackupElement(titleView: headView, cell: CustomTableViewCell(), footView: footLabel)
    lazy var backupElement2 = BackupElement(titleView: MyUIView(), cell: CustomTableViewCell(), footView: footLabel)
    lazy var elements: [BackupElement] = [backupElement2, backupElement]
    
    lazy var footLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.textAlignment = .center
        myLabel.textColor = .gray
        myLabel.font = UIFont.systemFont(ofSize: 18)
        myLabel.text = "this is footer"
        return myLabel
    }()
        
    lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 20, width: fullScreenSize.width, height: fullScreenSize.height - 20)
        let myTableView = UITableView(frame: frame, style: .grouped)
        myTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellID)
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.separatorStyle = .singleLine
        myTableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        myTableView.allowsSelection = true
        myTableView.allowsMultipleSelection = false
        return myTableView
    }()
    
    
    let backupDescription = "hi here is the tableView title"
    let restoreDescription = "nice to see you"
    
    lazy var descriptions: [String] = [restoreDescription, backupDescription]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .grassGreen
    }
    
    
    
    
    
    override func loadView() {
        super.loadView()
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
        return 3
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return elements.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CustomTableViewCell
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return descriptions[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return elements[section].titleView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 144
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return elements[section].footView
    }
}

struct BackupElement {
    let titleView: MyUIView?
    let cell: UITableViewCell?
    let footView: UIView?
}


class MyUIView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPadding: 12, leftPadding: 20, bottomPadding: 0, rightPadding: 10, width: 0, height: 22)
        addSubview(subtitleLabel)
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: titleLabel.leftAnchor, bottom: bottomAnchor, right: titleLabel.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 0)
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
        
    }
    
}
