//
//  SegmentStatus.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 16/10/2017.
//  Copyright © 2017 陳 冠禎. All rights reserved.
//

import UIKit


enum TabItemCase: Int, CaseIterable {
    
    case nearby, checkin, uncheck, building, setting, backup
    
    var title: String {
        switch self {
        case .nearby    : return "營運中"
        case .checkin   : return "已打卡"
        case .uncheck   : return "未打卡"
        case .building  : return "即將啟用"
        case .setting   : return "設定"
        case .backup    : return "雲端備份"
        }
    }
    
    
    var normalImage: UIImage {
        switch self {
        case .nearby:    return #imageLiteral(resourceName: "recent")
        case .checkin:   return #imageLiteral(resourceName: "checkin")
        case .uncheck:   return #imageLiteral(resourceName: "pinFull")
        case .building:  return #imageLiteral(resourceName: "building")
        case .setting:   return #imageLiteral(resourceName: "setting")
        case .backup:    return #imageLiteral(resourceName: "cloud")
        }
    }
    
    var hightlightImage: UIImage {
        switch self {
        case .nearby: return #imageLiteral(resourceName: "recent").invertedColors() ?? normalImage
        default     : return normalImage
        }
    }
    
    var tabContantController: UIViewController {
        Self.viewControllers[rawValue]
    }
    
    static let viewControllers = TabItemCase.allCases.map { $0.viewController }
    
    var hanlder: (BatteryStationPointAnnotation) -> Bool {
        switch self {
        case .checkin       : return { $0.checkinCounter ?? 0 > 0 && $0.isOperating }
        case .uncheck       : return { $0.checkinCounter ?? 0 == 0 && $0.isOperating }
        case .nearby,.setting, .backup        : return { $0.isOperating }
        case .building      : return { !$0.isOperating }
        }
    }
    
    private var viewController: UIViewController {
        switch self {
            
        case .building, .nearby , .uncheck, .checkin:
            let tableViewController = TableViewController(style: .grouped, tabItem: self)
            return tableViewController
            
        case .setting   :
            let flowLyout: UICollectionViewFlowLayout = {
                $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 20 , height: UIScreen.main.bounds.height - 90)
                $0.minimumLineSpacing = 0
                $0.minimumInteritemSpacing = 0
                return $0
            }(UICollectionViewFlowLayout())
            return MenuController(collectionViewLayout: flowLyout)
        case .backup: return BackupViewController(style: .grouped)
        }
    }
    
    var stationDataSource: [BatteryStationPointAnnotation] {
        switch self {
        case .nearby, .setting  : return DataManager.shared.operations
        case .checkin, .backup  : return DataManager.shared.checkins
        case .uncheck           : return DataManager.shared.unchecks
        case .building          : return DataManager.shared.buildings
        }
    }
}

