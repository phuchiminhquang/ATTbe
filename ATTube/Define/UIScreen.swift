//
//  Alert.swift
//  ATTube
//
//  Created by Quang Phù on 8/18/16.
//  Copyright © 2016 at. All rights reserved.
//
import Foundation
import UIKit
/**
 *  A structure of CGFloat to check the screen size and get width, height for kinds of iphone
 */
public struct Ratio {
    public static let widthIPhone4 = UIScreen.currentDevice.width / UIScreen.iPhone4.width
    public static let widthIPhone5 = UIScreen.currentDevice.width / UIScreen.iPhone5.width
    public static let widthIPhone6 = UIScreen.currentDevice.width / UIScreen.iPhone6.width
    public static let widthIPhone6P = UIScreen.currentDevice.width / UIScreen.iPhone6Plus.width

    public static let heightIPhone4 = UIScreen.currentDevice.height / UIScreen.iPhone4.height
    public static let heightIPhone5 = UIScreen.currentDevice.height / UIScreen.iPhone5.height
    public static let heightIPhone6 = UIScreen.currentDevice.height / UIScreen.iPhone6.height
    public static let heightIPhone6P = UIScreen.currentDevice.height / UIScreen.iPhone6Plus.height
}

/// This extesion adds some useful functions to UIScreen
public extension UIScreen {
    // MARK: - Global variables -
    public static var iPhone4: CGSize {
        get { return CGSize(width: 320.0, height: 480.0) }
    }

    public static var iPhone5: CGSize {
        get { return CGSize(width: 320.0, height: 568.0) }
    }

    public static var iPhone6: CGSize {
        get { return CGSize(width: 375.0, height: 667) }
    }

    public static var iPhone6Plus: CGSize {
        get { return CGSize(width: 414, height: 736.0) }
    }
    public static var currentDevice: CGSize {
        get { return UIScreen.mainScreen().bounds.size }
    }

    /// Get the screen width
    public class var mainWidth: CGFloat {
        get { return UIScreen.mainScreen().fixedScreenSize().width }
    }

    /// Get the screen height
    public class var mainHeight: CGFloat {
        get { return UIScreen.mainScreen().fixedScreenSize().height }
    }

    /// Get the maximum screen length
    public class var maxLength: CGFloat {
        get { return max(mainWidth, mainHeight) }
    }

    /// Get the minimum screen length
    public class var minLength: CGFloat {
        get { return min(mainWidth, mainHeight) }
    }

    // MARK: - Class functions -

    /**
     Check if the current device has a Retina display
     - returns: Returns true if it has a Retina display, false if not
     */
    public static func isRetina() -> Bool {
        if UIScreen.mainScreen().respondsToSelector(#selector(UIScreen.displayLinkWithTarget(_: selector:))) &&
        (UIScreen.mainScreen().scale == 2.0 || UIScreen.mainScreen().scale == 3.0) {
            return true
        } else {
            return false
        }
    }

    /**
     Check if the current device has a Retina HD display
     - returns: Returns true if it has a Retina HD display, false if not
     */
    public static func isRetinaHD() -> Bool {
        if UIScreen.mainScreen().respondsToSelector(#selector(UIScreen.displayLinkWithTarget(_: selector:))) && UIScreen.mainScreen().scale == 3.0 {
            return true
        } else {
            return false
        }
    }

    // MARK: - Instance functions -

    /**
     Returns the fixed screen size, based on device orientation
     - returns: Returns a GCSize with the fixed screen size
     */
    public func fixedScreenSize() -> CGSize {
        let screenSize = self.bounds.size

        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 &&
        UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            return CGSize(width: screenSize.height, height: screenSize.width)
        }

        return screenSize
    }

}
