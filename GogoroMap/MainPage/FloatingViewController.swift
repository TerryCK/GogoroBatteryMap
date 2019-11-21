//
//  FloatingViewController.swift
//  GogoroMap
//
//  Created by Terry Chen on 2019/11/15.
//  Copyright © 2019 陳 冠禎. All rights reserved.
//

import ColorMatchTabs
import FloatingPanel
import Crashlytics

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
        
        Answers.log(event: .Tab, customAttributes: String(describing: tabItemProvider[index]))
        
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



extension UIImage {
    /// Inverts the colors from the current image. Black turns white, white turns black etc.
    func invertedColors() -> UIImage? {
        guard let ciImage = CIImage(image: self) ?? ciImage, let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return nil }
        return UIImage(ciImage: outputImage)
    }
}
