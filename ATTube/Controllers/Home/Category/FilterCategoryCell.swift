//
//  CategoryCell.swift
//  ATTube
//
//  Created by Quang Phù on 9/3/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

private extension CGFloat {
    static let cellHeight: CGFloat = 44 * Ratio.widthIPhone6
}

class FilterCategoryCell: UITableViewCell {
    @IBOutlet private weak var checkedImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var thumbnailImageView: UIImageView!

    private var category: VideoCategory?

    override func awakeFromNib() {
        super.awakeFromNib()
        autoFontSize()
        selectionStyle = .None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkedImageView.hidden = !selected
        checkedImageView.alpha = 0.0
        UIView.animateWithDuration(0.3) {
            self.checkedImageView.alpha = 1.0
        }
    }

    func configCellAtIndex(index: Int, object: VideoCategory?) {
        category = object
        nameLabel.text = object?.title
        if let id = object?.id {
            thumbnailImageView.image = UIImage(named: id)
        }
    }

    static func getCellHeight() -> CGFloat {
        return .cellHeight
    }

    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        nameLabel.font = helveticaFont.Regular(17)
    }
}
