//
//  BackupElement.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/4/8.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

struct BackupElement {
    enum type { case backup, delete }
    let titleView: SupplementaryCell?
    var cells: [BackupTableViewCell]?
    let footView: SupplementaryCell?, type: type
}
