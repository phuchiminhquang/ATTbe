//
//  UIApplication.swift
//  ATTube
//
//  Created by Quang Phù on 9/13/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
//    class func topViewController(base: UIViewController? = AppDelegate.appDelegate!.window!.rootViewController) -> ViewController? {
//        if let nav = base as? UINavigationController {
//            return topViewController(nav.visibleViewController)
//        }
//        if let tab = base as? UITabBarController {
//            if let selected = tab.selectedViewController {
//                return topViewController(selected)
//            }
//        }
//        if let presented = base?.presentedViewController {
//            return topViewController(presented)
//        }
//        return base as? ViewController
//    }

    class func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        guard let _ = rootViewController else { return nil }
        if rootViewController.isKindOfClass(UITabBarController) {
            return topViewControllerWithRootViewController((rootViewController as? UITabBarController)!.selectedViewController)
        } else if rootViewController.isKindOfClass(UINavigationController) {
            return topViewControllerWithRootViewController((rootViewController as? UINavigationController)!.visibleViewController)
        } else if rootViewController.presentedViewController != nil {
            return topViewControllerWithRootViewController(rootViewController.presentedViewController)
        }
        return rootViewController
    }
}
