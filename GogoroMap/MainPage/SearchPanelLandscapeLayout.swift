//
//  SearchPanelLandscapeLayout.swift
//  SupplyMap
//
//  Created by Terry Chen on 2019/8/15.
//  Copyright © 2019 Yi Shiung Liu. All rights reserved.
//

import Foundation
import FloatingPanel

public class SearchPanelLandscapeLayout: FloatingPanelLayout {
    
    public var initialPosition: FloatingPanelPosition { .tip  }
    
    public var supportedPositions: Set<FloatingPanelPosition> { [.full, .tip] }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .tip: return 60.0
        default: return nil
        }
    }
    
    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        
        let leftAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            leftAnchor = view.safeAreaLayoutGuide.leftAnchor
        } else {
            leftAnchor = view.leftAnchor
        }
        
        return [
            surfaceView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8.0),
            surfaceView.widthAnchor.constraint(equalToConstant: 291),
        ]
    }
}

final class MapFloatingLayout : FloatingPanelLayout {
    
    var initialPosition: FloatingPanelPosition { .half }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 18.0
        case .half: return 262.0
        case .tip: return 60.0 + 50
        case .hidden: return nil
        }
    }
}
