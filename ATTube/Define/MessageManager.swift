//
//  Message.swift
//  ATTube
//
//  Created by Quang Phù on 8/30/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import SwiftMessages

class MessageManager {

    class var sharedInstance: MessageManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: MessageManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = MessageManager()
        }
        return Static.instance!
    }

    // MARK: Property
    private var fuMessageView: FUMessageView? = nil
    private var isShowing = false

    // MARK: Private function
    private func initMessageView(messageType type: MessageType) {
        fuMessageView = FUMessageView(messageType: type)
        fuMessageView?.hiddenFinishedBlock = releaseMemory
        print("Inited")
    }

    private func releaseMemory() -> Void {
        fuMessageView = nil
        isShowing = false
        print("Deleted")
    }

    // MARK: Public
    func show(messageType type: MessageType, title: String, subTitle: String, finished: (() -> Void)?) {
        if isShowing {
            fuMessageView?.removeFromSuperview()
            fuMessageView?.hiddenFinishedBlock = nil
            fuMessageView = nil
        }
        initMessageView(messageType: type)
        fuMessageView?.show(title: title, subTitle: subTitle, finished: finished)
        isShowing = true
    }
}
