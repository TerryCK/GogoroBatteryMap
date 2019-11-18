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
        return tabItemProvider.count
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController {
        return TabItemCase.viewControllers[index]
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleAt index: Int) -> String {
        return tabItemProvider[index].tabItem.title
    }
    
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage {
        return tabItemProvider[index].tabItem.normalImage
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage {
        return tabItemProvider[index].tabItem.highlightedImage
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor {
        return tabItemProvider[index].tabItem.tintColor
    }
    
    
    func didSelectItemAt(_ index: Int) {
        if let scrollerView = (TabItemCase.viewControllers[index] as? ViewTrackable)?.trackView {
            flatingPanelController?.track(scrollView: scrollerView)
        }
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


enum TabItemCase: CaseIterable {
    
    case nearby, checkin, uncheck, building, setting, backup
    
    var title: String {
        switch self {
        case .building  : return "即將啟用"
        case .nearby    : return "附近營運中"
        case .checkin   : return "已打卡"
        case .uncheck   : return "未打卡"
        case .setting   : return "設定"
        case .backup    : return "雲端備份"
        }
    }
    
    
    static let viewControllers = TabItemCase.allCases.map { $0.viewController }
    
    var tabItem: TabItem {
        switch self {
        case .building  :
            return TabItem(
                title: title,
                tintColor: UIColor(red: 0.51, green: 0.72, blue: 0.25, alpha: 1.00),
                normalImage: #imageLiteral(resourceName: "building"))
            
        case .nearby    :
            return TabItem(
                title: title,
                tintColor: UIColor(red: 0.15, green: 0.67, blue: 0.99, alpha: 1.00),
                normalImage: #imageLiteral(resourceName: "pinFull"))
        case .checkin   :
            return TabItem(
                title: title,
                tintColor: UIColor(red: 0.96, green: 0.61, blue: 0.58, alpha: 1.00),
                normalImage: #imageLiteral(resourceName: "checkin"))
        case .uncheck   :
            return TabItem(
                title: title,
                tintColor: UIColor(red: 0.51, green: 0.72, blue: 0.25, alpha: 1.00),
                normalImage: #imageLiteral(resourceName: "pinFull"))
        case .setting   :
            return TabItem(
                title: title,
                tintColor: UIColor(red: 0.96, green: 0.61, blue: 0.58, alpha: 1.00),
                normalImage: UIImage(named: "convenientStore")!)
        case .backup    :
            return TabItem(
                title: title,
                tintColor: UIColor(red: 0.51, green: 0.72, blue: 0.25, alpha: 1.00),
                normalImage: UIImage(named: "downloadFromCloud")!)
        }
    }
    
    private var viewController: UIViewController {
        switch self {
            
        case .building, .nearby , .uncheck, .checkin:
            let tabViewController = TableViewController(style: .grouped)
            tabViewController.segmentStatus = SegmentStatus.allCases.first { String(describing: $0) == String(describing: self) } ?? .nearby
            return tabViewController
            
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
