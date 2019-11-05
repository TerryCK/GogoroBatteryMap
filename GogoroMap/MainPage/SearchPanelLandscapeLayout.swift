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
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .tip: return 60.0
        default: return nil
        }
    }
    
    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        } else {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        }
    }
    
//    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
//        return 0.0
//    }
}

final class MapFloatingLayout : FloatingPanelLayout {
    var initialPosition: FloatingPanelPosition { return .half }
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 18.0
        case .half: return 262.0
        case .tip: return 60.0 + 50
        case .hidden: return nil
        }
    }
}
