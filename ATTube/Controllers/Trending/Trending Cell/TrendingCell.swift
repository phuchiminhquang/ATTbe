//
//  TableViewCell.swift
//  ATTube
//
//  Created by Asiantech1 on 8/3/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SDWebImage

private extension String {
    static let Hour = "H"
    static let Minute = "M"
    static let Second = "S"
}

class TrendingCell: UITableViewCell {

    // MARK - outlet
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var totalViewsLabel: UILabel!
    @IBOutlet private weak var blurView: UIView!

    var addFavorite: ((Int) -> Void)?
    private var index = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        autoFontSize()
        blurView.addBlurBackground(.Dark)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configCellAtIndex(index: Int, object: Video?) {
        self.index = index
        contentView.backgroundColor = index % 2 == 0 ? Color.black10 : Color.black20
        selectionStyle = UITableViewCellSelectionStyle.None

        if let thumbnailURLString = object?.highThumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
            photoImageView.sd_setImageWithURL(thumbnailURL, placeholderImage: UIImage(assetIdentifier: .BgHomeCell))
        }
        nameLabel.text = object?.title
        durationLabel.text = HandleData.duration(object?.duration)
        descriptionLabel.text = object?.describe
        totalViewsLabel.text = HandleData.viewCount(object?.viewCount)
    }

    static func getCellHeight() -> CGFloat {
        return 250 * Ratio.widthIPhone6
    }

    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        nameLabel.font = helveticaFont.Regular(18)
        durationLabel.font = helveticaFont.Light(14)
        descriptionLabel.font = helveticaFont.Regular(13)
        totalViewsLabel.font = helveticaFont.Regular(13)
    }

    @IBAction func didTapMoreButton(sender: UIButton) {
        addFavorite?(index)
    }
}
