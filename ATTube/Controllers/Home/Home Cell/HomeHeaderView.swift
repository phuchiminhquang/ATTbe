//
//  HomeHeaderView.swift
//  ATTube
//
//  Created by Quang Phù on 9/5/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
typealias LoadVideosByCategoryId = (Int) -> Void

class HomeHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var categoryNameLabel: UILabel!

    func configCellAtIndex(title title: String?) {
        categoryNameLabel.text = title ?? "None"
    }

    static func getCellHeight() -> CGFloat {
        return 35 * Ratio.widthIPhone6
    }
}
