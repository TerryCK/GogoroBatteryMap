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
    
    weak var flatingPanelController: FloatingPanelController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        colorMatchTabDataSource = self
        colorMatchTabDelegate = self
    }
}


extension FloatingViewController: ColorMatchTabsViewControllerDataSource, ColorMatchTabsViewControllerDelegate {
    
    func numberOfItems(inController controller: ColorMatchTabsViewController) -> Int {
        return TabItemsProvider.items.count
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, viewControllerAt index: Int) -> UIViewController {
        return StubContentViewControllersProvider.viewControllers[index]
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, titleAt index: Int) -> String {
        return TabItemsProvider.items[index].title
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, iconAt index: Int) -> UIImage {
        return TabItemsProvider.items[index].normalImage
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, hightlightedIconAt index: Int) -> UIImage {
        return TabItemsProvider.items[index].highlightedImage
    }
    
    func tabsViewController(_ controller: ColorMatchTabsViewController, tintColorAt index: Int) -> UIColor {
        return TabItemsProvider.items[index].tintColor
    }
    
        
    func didSelectItemAt(_ index: Int) {
        if let scrollerView = StubContentViewControllersProvider.viewControllers[index] as? TableViewController {
            flatingPanelController?.track(scrollView: scrollerView.tableView)
        }
    }
}


struct TabItem {
    
    let title: String
    let tintColor: UIColor
    let normalImage: UIImage
    var highlightedImage: UIImage { normalImage }
}


enum TabItemCase: CaseIterable {
    
    case nearby, checkin, uncheck, building, setting
    
    var name: String {
        switch self {
        case .building  : return "即將啟用"
        case .nearby    : return "附近營運中"
        case .checkin   : return "已打卡"
        case .uncheck   : return "未打卡"
        case .setting   : return "設定"
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


class TabItemsProvider {
    
    static let items = {
        return [
            TabItem(
                title: "附近營運中",
                tintColor: UIColor(red: 0.51, green: 0.72, blue: 0.25, alpha: 1.00),
                normalImage: UIImage(named: "convenientStore")!
            ),
            TabItem(
                title: "已打卡",
                tintColor: UIColor(red: 0.15, green: 0.67, blue: 0.99, alpha: 1.00),
                normalImage: UIImage(named: "shortTime")!
            ),
            TabItem(
                title: "即將啟用",
                tintColor: UIColor(red: 1.00, green: 0.61, blue: 0.16, alpha: 1.00),
                normalImage: UIImage(named: "shortTime")!
            ),
            TabItem(
                title: "未打卡",
                tintColor: UIColor(red: 0.96, green: 0.61, blue: 0.58, alpha: 1.00),
                normalImage: UIImage(named: "shortTime")!
            ),
            TabItem(
                title: "設定",
                tintColor: UIColor(red: 0.96, green: 0.61, blue: 0.58, alpha: 1.00),
                normalImage: UIImage(named: "shortTime")!
            ),
            
        ]
    }()
    
}
class StubContentViewControllersProvider {
    
    static let viewControllers: [UIViewController] = {
        let productsViewController = TableViewController()
        
        let flowLyout: UICollectionViewFlowLayout = {
            
            $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 20 , height: UIScreen.main.bounds.height - 90)
            $0.minimumLineSpacing = 0
            $0.minimumInteritemSpacing = 0
            return $0
        }(UICollectionViewFlowLayout())
        let venuesViewController = MenuController(collectionViewLayout: flowLyout)
        
        
        let reviewsViewController = TableViewController()
        
        
        let usersViewController = TableViewController()
        
        let usersViewController2 = TableViewController()
                
        let usersViewController6 = TableViewController()
         
        let usersViewController3 = TableViewController()
         
        let usersViewController4 = TableViewController()
         
        let usersViewController5 = TableViewController()
        
        
        
        return [productsViewController, venuesViewController, reviewsViewController, usersViewController, usersViewController2, usersViewController3, usersViewController4, usersViewController5, usersViewController6]
    }()

}
