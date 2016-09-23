//
//  HomeCell.swift
//  ATTube
//
//  Created by Quang Phù on 9/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import RealmSwift

typealias VideoByCategoryID = (video: Video?, categoryId: Int) -> Void

private extension CGFloat {
    static let collectionCellWidth: CGFloat = 180 * Ratio.widthIPhone6
    static let minimumLineSpacing: CGFloat = 5 * Ratio.widthIPhone6

    static let paddingTop: CGFloat = 0
    static let paddingLeft: CGFloat = 5 * Ratio.widthIPhone6
    static let paddingRight: CGFloat = 5 * Ratio.widthIPhone6
    static let paddingBottom: CGFloat = 0

    static let cellHeight: CGFloat = 200 * Ratio.widthIPhone6
    static let titleHeight: CGFloat = 35 * Ratio.widthIPhone6
}

class HomeCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!

    private var videos: [Video]? = nil
    private var index = 0
    var showVideosByCategory: VideoByCategoryID?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configCellAtIndex(index: Int, object: [Video]?) {
        self.index = index
        self.videos = object
        collectionView.registerNib(HomeCollectionCell)
        collectionView.registerNib(CollectionCellOption)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        contentView.backgroundColor = index % 2 == 0 ? Color.black10 : Color.black20
    }

    static func getCellHeight() -> CGFloat {
        return .cellHeight
    }

}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource
extension HomeCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (videos?.count ?? (-1)) + 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == videos?.count {
            let lastCell = collectionView.dequeue(CollectionCellOption.self, forIndexPath: indexPath)
            return lastCell
        }

        let video = videos?[indexPath.row]
        let homeCollectionCell = collectionView.dequeue(HomeCollectionCell.self, forIndexPath: indexPath)
        homeCollectionCell.configCellAtIndex(indexPath.row, object: video)
        return homeCollectionCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var video: Video? = nil
        if indexPath.row < videos?.count {
            video = videos?[indexPath.row]
        }
        showVideosByCategory?(video: video, categoryId: index)
    }
}

// MARK:- UICollectionViewDelegateFlowLayout
extension HomeCell: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSize(width: .collectionCellWidth, height: collectionView.bounds.size.height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: .paddingTop,
                left: .paddingLeft,
                bottom: .paddingBottom,
                right: .paddingRight)
    }

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return .minimumLineSpacing
    }
}
