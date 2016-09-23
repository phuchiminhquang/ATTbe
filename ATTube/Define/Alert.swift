//
//  Alert.swift
//  ATTube
//
//  Created by Quang Phù on 8/18/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import UIKit

typealias ConfirmYes = () -> Void
typealias InputTextConfirmYes = (text: String) -> Void
typealias ConfirmPlaylistFinished = (index: Int?, isCreate: Bool) -> Void

private let kNumberItemOverHeight = 4

class Alert {
    static var sharedInstance = Alert()
    // Default alert
    func showAlert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: Strings.yes, style: .Default, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }

    // Confirm alert, choose Yes or No
    func showConfirmAlert(viewController: UIViewController, title: String, message: String, confirmYes: ConfirmYes) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: Strings.confirm, style: .Default, handler: { (action: UIAlertAction!) in
            confirmYes()
            }))
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .Default, handler: { (action: UIAlertAction!) in
            alert .dismissViewControllerAnimated(true, completion: nil)
            }))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    // input text alert, to create something.
    func inputTextAlert(viewController: UIViewController, title: String,
        message: String, confirmHandler confirmYes: InputTextConfirmYes) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: Strings.confirm, style: .Default, handler: { (action: UIAlertAction) in
                if let textFields = alert.textFields, text = textFields[0].text {
                    let name = text == "" ? textFields[0].placeholder!: text
                    confirmYes(text: name)
                }
                }))
            alert.addAction(UIAlertAction(title: Strings.cancel, style: .Default, handler: { (action: UIAlertAction!) in
                alert .dismissViewControllerAnimated(true, completion: nil)
                }))
            alert.addTextFieldWithConfigurationHandler { (textField) in

                textField.placeholder = RealmManager.getPlaylistNameAutomatically()
            }
            viewController.presentViewController(alert, animated: true, completion: nil)
    }
    // show actionsheet
    func showActionSheet(viewController: UIViewController, title: String?, message: String?,
        options: [String]?, confirmHandler confirm: ConfirmPlaylistFinished?) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            alert.addAction(UIAlertAction(title: Strings.addNew, style: .Destructive, handler: { (action) in
                confirm?(index: nil, isCreate: true) }))
            if let options = options {
                if options.count >= kNumberItemOverHeight { // fixed height of alert height equal with 4 items.
                    let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .Height,
                        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
                        multiplier: 1, constant: viewController.view.bounds.height / 3 * 2)
                    alert.view.addConstraint(height)
                }
                for (index, item) in options.enumerate() {
                    alert.addAction(UIAlertAction(title: item, style: .Default, handler: { (action: UIAlertAction) in
                        confirm?(index: index, isCreate: false)
                        }))
                }
            }
            alert.addAction(UIAlertAction(title: Strings.cancel, style: .Cancel, handler: nil))
            viewController.presentViewController(alert, animated: true, completion: nil)
    }
}
