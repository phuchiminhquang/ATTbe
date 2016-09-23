//
//  CollectionCellOption.swift
//  ATTube
//
//  Created by Quang Phù on 9/11/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

class CollectionCellOption: UICollectionViewCell {

    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
        autoFontSize()
    }

    private func configUI() {
        blurView.addBlurBackground(.Dark)
    }

    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        title.font = helveticaFont.Bold(17)
    }

}
