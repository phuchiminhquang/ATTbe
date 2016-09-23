//
//  FUMessageView.swift
//  ATTube
//
//  Created by Quang Phù on 9/15/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

private extension Selector {
    static let hidden = #selector(FUMessageView.hidden)
}
enum Icon: String {
    case Success = "success"
    case Warning = "warning"
    case Error = "error"

    var image: UIImage? {
        return UIImage(named: rawValue)
    }
}

enum MessageType: Int {
    case Success = 0
    case Warning
    case Error

    var icon: UIImage? {
        switch self {
        case .Success:
            return Icon.Success.image
        case .Warning:
            return Icon.Warning.image
        case .Error:
            return Icon.Error.image
        }
    }

    var backgourdColor: UIColor {
        switch self {
        case .Success:
            return UIColor(red: 78 / 255, green: 143 / 255, blue: 18 / 255, alpha: 0.95)
        case .Warning:
            return UIColor(red: 245 / 255, green: 211 / 255, blue: 40 / 255, alpha: 0.9)
        case .Error:
            return UIColor(red: 245 / 255, green: 41 / 255, blue: 36 / 255, alpha: 0.9)
        }
    }

    var titleColor: UIColor {
        switch self {
        case .Success:
            return UIColor(red: 46 / 255, green: 197 / 255, blue: 37 / 255, alpha: 1)
        case .Warning:
            return UIColor(red: 245 / 255, green: 211 / 255, blue: 40 / 255, alpha: 1)
        case .Error:
            return UIColor(red: 245 / 255, green: 41 / 255, blue: 36 / 255, alpha: 1)
        }
    }

    var iconSize: CGSize {
        let width = 50 * Ratio.widthIPhone6
        return CGSize(width: width, height: width)
    }
}

private extension CGFloat {
    static let space: CGFloat = 0.0 * Ratio.widthIPhone6
    static let cornerRadius: CGFloat = 10.0 * Ratio.widthIPhone6
    static let messageViewHeight: CGFloat = 80.0 * Ratio.widthIPhone6
    static let messageViewWidth: CGFloat = UIScreen.mainScreen().bounds.width - (CGFloat.space * 2)
    static let messageOrginY: CGFloat = UIScreen.mainScreen().bounds.height - messageViewHeight
}

class FUMessageView: UIView {
    private var messageType: MessageType!
    private var title: UILabel!
    private var subTitle: UILabel!
    private var messageTypeIcon: UIImageView?
    private var timeHidden: NSTimer?
    var hiddenFinishedBlock: (Void -> ())?

    convenience init(messageType: MessageType) {
        let frame = CGRect(origin: CGPoint(x: .space, y: .messageOrginY),
            size: CGSize(width: .messageViewWidth, height: .messageViewHeight))
        self.init(frame: frame)
        self.messageType = messageType
        configureUI()
    }

    // MARK: Private
    private func configureUI() {
        // Set Background
//        layer.cornerRadius = CGFloat.cornerRadius
//        layer.masksToBounds = true
        addBlurBackground(.Dark)
//        backgroundColor = messageType.backgourdColor

        // Add Message Type Icon
        let iconView = UIView(origin: CGPoint.zero,
            size: CGSize(width: self.height, height: self.height))
        let imageViewIcon = UIImageView(image: messageType.icon)
        imageViewIcon.frame = CGRect(origin: CGPoint.zero, size: messageType.iconSize)
        iconView.addSubview(imageViewIcon)
        imageViewIcon.center = iconView.center
        addSubview(iconView)

        let helveticaFont = HelveticaFont()
        title = UILabel(frame: CGRect(x: iconView.width, y: imageViewIcon.originY,
            width: width - iconView.width, height: imageViewIcon.height / 2))
        subTitle = UILabel(frame: CGRect(x: iconView.width, y: imageViewIcon.originY + title.height,
            width: width - iconView.width, height: imageViewIcon.height / 2))

        title.textColor = messageType.titleColor
        subTitle.textColor = Color.white

        title.font = helveticaFont.Bold(18)
        subTitle.font = helveticaFont.Regular(15)

        addSubview(title)
        addSubview(subTitle)
    }

    // MARK: Public
    func show(title title: String, subTitle: String, finished: (() -> Void)?) {
        self.title.text = title.uppercaseString
        self.subTitle.text = subTitle
        let finalPoint = center
        center = CGPoint(x: center.x, y: UIScreen.mainScreen().bounds.height + height / 2)
//        AppDelegate.appDelegate?.window?.rootViewController?.view.addSubview(self)
        AppDelegate.appDelegate?.window?.addSubview(self)
        UIView.animateWithDuration(0.3, animations: {
            self.center = finalPoint
        }) { (finish) in
            self.timeHidden?.invalidate()
            self.timeHidden = NSTimer.scheduledTimerWithTimeInterval(2.0,
                target: self,
                selector: .hidden,
                userInfo: nil, repeats: false)
            finished
        }
    }

    @objc private func hidden() {
        let finalPoint = CGPoint(x: center.x, y: UIScreen.mainScreen().bounds.height + height / 2)
        UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: .CurveEaseInOut,
            animations: {
                self.center = finalPoint
        }) { (finish) in
                self.removeFromSuperview()
                self.hiddenFinishedBlock?()
        }
    }
}
