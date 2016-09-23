//
//  AppDelegate.swift
//  ATTube
//
//  Created by AsianTech on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SwiftUtils
import PureLayout

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dragVideo: DraggalbeVideo?

    static let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let pageMenu = PageMenuVC.vc()
        let pageMenuNavi = UINavigationController(rootViewController: pageMenu)
        window?.rootViewController = pageMenuNavi
        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()

        UIApplication.sharedApplication().statusBarStyle = .LightContent
        return true
    }

    func getDraggableVideo() -> DraggalbeVideo? {
        if dragVideo == nil {
            dragVideo = DraggalbeVideo(rootViewController: (window?.rootViewController)!)
            dragVideo?.draggbleProgress()
            dragVideo?.addActionToView()
        }
        return dragVideo
    }

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = UIApplication.topViewControllerWithRootViewController(window?.rootViewController) {
            if rootViewController.respondsToSelector(#selector(PlayerVC.canRotate)) {
                // Unlock landscape view orientations for this view controller
                return .AllButUpsideDown
            }
        }
        // Only allow portrait (standard behaviour)
        return .Portrait
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}
