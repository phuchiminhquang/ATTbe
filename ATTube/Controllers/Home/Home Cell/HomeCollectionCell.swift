//
//  HomeCollectionCell.swift
//  ATTube
//
//  Created by Quang Phù on 9/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

class HomeCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var videoNameLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var descriptionlabel: UILabel!
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var blurView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        autoFontSize()
        configUI()
    }

    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        videoNameLabel.font = helveticaFont.Regular(16)
        durationLabel.font = helveticaFont.Light(14)
        descriptionlabel.font = helveticaFont.Regular(12)
    }

    private func configUI() {
        blurView.addBlurBackground(.Dark)
    }

    func configCellAtIndex(index: Int, object: Video?) {
        if let thumbnailURLString = object?.highThumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
            photoImageView.sd_setImageWithURL(thumbnailURL, placeholderImage: UIImage(assetIdentifier: .BgHomeCell))
        }
        videoNameLabel.text = object?.title
        durationLabel.text = HandleData.duration(object?.duration)
        descriptionlabel.text = object?.describe
    }
}
