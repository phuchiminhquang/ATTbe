//
//  UIView.swift
//  ATTube
//
//  Created by Asiantech1 on 8/5/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

extension UIView {

    var originX: CGFloat {
        set { frame = CGRect(x: newValue, y: originY, width: width, height: height) }
        get { return frame.origin.x }
    }

    var originY: CGFloat {
        set { frame = CGRect(x: originX, y: newValue, width: width, height: height) }
        get { return frame.origin.y }
    }

    var width: CGFloat {
        set { frame = CGRect(x: originX, y: originY, width: newValue, height: height) }
        get { return bounds.width }
    }

    var height: CGFloat {
        set { frame = CGRect(x: originX, y: originY, width: width, height: newValue) }
        get { return bounds.height }
    }

    convenience init(originX: CGFloat, originY: CGFloat, width: CGFloat, height: CGFloat) {
        self.init(frame: CGRect(x: originX, y: originY, width: width, height: height))
    }

    convenience init(origin: CGPoint, size: CGSize) {
        self.init(frame: CGRect(origin: origin, size: size))
    }

    func addBlurBackground(blurEffectStyle: UIBlurEffectStyle) {
        self.backgroundColor = Color.clear
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: blurEffectStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
            self.addSubview(blurEffectView)
        }
    }

    func autoPinEdgesToSuperviewEdgesWith(supperView: UIView, leading: CGFloat, top: CGFloat, trailing: CGFloat, bottom: CGFloat) {
        NSLayoutConstraint(item: self,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: superview,
            attribute: .Leading,
            multiplier: 1.0,
            constant: leading).active = true
        NSLayoutConstraint(item: self,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: superview,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0).active = true
        NSLayoutConstraint(item: self,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: superview,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0).active = true
        NSLayoutConstraint(item: self,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: superview,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0).active = true
    }

    func autoPinEdgesToSuperviewEdgesWith(leading: CGFloat, top: CGFloat, trailing: CGFloat, bottom: CGFloat) {
        NSLayoutConstraint(item: self,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .Leading,
            multiplier: 1.0,
            constant: leading).active = true
        NSLayoutConstraint(item: self,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0).active = true
        NSLayoutConstraint(item: self,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0).active = true
        NSLayoutConstraint(item: self,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0).active = true
    }

    func autoPin(edge: NSLayoutAttribute, toEdge: NSLayoutAttribute, ofView view: UIView, withOffset offset: CGFloat) {
        NSLayoutConstraint(item: self,
            attribute: edge,
            relatedBy: .Equal,
            toItem: view,
            attribute: toEdge,
            multiplier: 1.0,
            constant: offset).active = true
    }

    func autoPinCenterInSuperView() {
        NSLayoutConstraint(item: self,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: 0.0).active = true
        NSLayoutConstraint(item: self,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: self.superview,
            attribute: .CenterY,
            multiplier: 1.0,
            constant: 0.0).active = true
    }
}
