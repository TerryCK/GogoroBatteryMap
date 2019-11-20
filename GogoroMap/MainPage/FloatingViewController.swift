//
//  FloatingViewController.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/11/15.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import ColorMatchTabs
import FloatingPanel

final class FloatingViewController: ColorMatchTabsViewController {
    
    weak var flatingPanelController: FloatingPanelController? {
        didSet {
            didSelectItemAt(0)
        }
    }
    
    private let locationManager: LocationManager = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        colorMatchTabDataSource = self
        colorMatchTabDelegate = self
    }
    
    private var tabItemProvider: [TabItemCase] = TabItemCase.allCases
}

extension FloatingViewController: ColorMatchTabsViewControllerDataSource, ColorMatchTabsViewControllerDelegate {
    
    func numberOfItems(inController controller: ColorMatchTabsViewController) -> Int {
         tabItemProvider.count - 2
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController {
         TabItemCase.viewControllers[index]
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleAt index: Int) -> String {
         tabItemProvider[index].title
    }
    
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage {
         tabItemProvider[index].normalImage
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage {
         tabItemProvider[index].normalImage
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor {
         .lightGreen
    }
    
    
    func didSelectItemAt(_ index: Int) {
        
        if let scrollerView = (TabItemCase.viewControllers[index] as? ViewTrackable)?.trackView {
            flatingPanelController?.track(scrollView: scrollerView)
        }
        
        if tabItemProvider[index] != .setting {
             DataManager.shared.lastUpdate = Date()
        }
        
        guard let tableViewController = TabItemCase.viewControllers[index] as? TableViewController else  {
            return
        }
        tableViewController.stations = tabItemProvider[index]
            .stationDataSource
            .sorted(userLocation: self.locationManager.userLocation, by: <)
        
    }
}

protocol ViewTrackable {
    
    var trackView: UIScrollView { get }
}

extension ViewTrackable where Self: UITableViewController {

    var trackView: UIScrollView { tableView }
}

extension ViewTrackable where Self: UICollectionViewController {

    var trackView: UIScrollView { collectionView }
}

struct TabItem {
    
    let title: String
    let tintColor: UIColor
    let normalImage: UIImage
    var highlightedImage: UIImage { normalImage }
}


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
    
    static let viewControllers = TabItemCase.allCases.map { $0.viewController }
    
    
    private var viewController: UIViewController {
        switch self {
            
        case .building, .nearby , .uncheck, .checkin:
            return TableViewController(style: .grouped)
            
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
        case .nearby            : return DataManager.shared.stations
        case .checkin, .backup  : return DataManager.shared.checkins
        case .uncheck           : return DataManager.shared.unchecks
        case .building          : return DataManager.shared.buildings
        case .setting           : return DataManager.shared.originalStations
        }
    }
}



extension UIImage {
    /// Inverts the colors from the current image. Black turns white, white turns black etc.
    func invertedColors() -> UIImage? {
        guard let ciImage = CIImage(image: self) ?? ciImage, let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return nil }
        return UIImage(ciImage: outputImage)
    }
}
