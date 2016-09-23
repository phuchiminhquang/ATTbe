//
//  AutoplayCell.swift
//  ATTube
//
//  Created by Quang Phù on 9/3/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

private extension CGFloat {
    static let cellHeight: CGFloat = 50 * Ratio.widthIPhone6
}

typealias AutoPlay = (Bool) -> Void

class AutoplayCell: UITableViewCell {

    @IBOutlet private weak var upNextLabel: UILabel!
    @IBOutlet private weak var autoplayLabel: UILabel!
    @IBOutlet private weak var autoPlaySwitch: UISwitch!

    var autoplay: AutoPlay?

    override func awakeFromNib() {
        super.awakeFromNib()
        autoFontSize()
        selectionStyle = .None
        autoPlaySwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
        autoPlaySwitch.layoutIfNeeded()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static func getCellHeight() -> CGFloat {
        return .cellHeight
    }

    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        upNextLabel.font = helveticaFont.Regular(15)
        autoplayLabel.font = helveticaFont.Bold(14)
    }

    @IBAction func didChangeValueAutoplay(sender: UISwitch) {
        autoplay?(sender.on)
    }
}
