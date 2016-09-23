//
//  FavoriteVC.swift
//  ATTube
//
//  Created by Asiantech1 on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SwiftUtils
import RealmSwift

private extension Selector {
    static let reloadData = #selector(FavoriteVC.reloadData)
}

class FavoriteVC: ViewController {

    // MARK:- Outlet
    @IBOutlet private weak var tableView: UITableView!
    private var selectedIndexPlaylist = 0

    // MARK:- Property
    private var playlists: Results<Playlist>?
    private var dragVideo: DraggalbeVideo?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK - Init UI & Data
    override func configUI() {
        tableView.registerNib(FavoriteCell)
    }
    override func loadData() {
        playlists = RealmManager.getAvailablePlaylists()
        addNotification()
    }

    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: .reloadData,
            name: Strings.notificationAddPlaylist,
            object: nil)
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }

}

// MARK: - UITableviewDataSource, UITableViewDelegate
extension FavoriteVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists?.count ?? 0
    }

    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let playlist = playlists?[indexPath.row]
            let favoriteCell = tableView.dequeue(FavoriteCell)
            favoriteCell.delegate = self
            favoriteCell.configCellAtIndex(indexPath.row, object: playlist)
            return favoriteCell
    }

    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return FavoriteCell.getCellHeight()
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
}

extension FavoriteVC: FavoriteCellDelegate {
    func playVideo(indexVideo: Int?, InPlaylist indexPlaylist: Int) {
        selectedIndexPlaylist = indexPlaylist
//        let player = PlayerVC(index: indexVideo, listVideos: playlists?[indexPlaylist].videos, isShowPlaylist: true)
//        player.delegate = self
//        self.presentViewController(player, animated: true, completion: nil)

        let drag = AppDelegate.appDelegate?.getDraggableVideo()
        drag?.videoPlayerViewController?.delegate = self
        drag?.presentPlayerVC(indexVideo, InListVideos: playlists?[indexPlaylist].videos, isShowPlaylist: true)
    }
}

extension FavoriteVC: UpdatePlaylistDelegate {

    func deleteVideoAt(index: Int) {
        playlists?[selectedIndexPlaylist].deleteVideoByIndex(index, finished: { (success, error) in
            if success {
                self.playlists = RealmManager.getAvailablePlaylists()
                self.tableView.reloadData()
            }
        })
    }

    func swapVideo(firstIndex: Int, secondIndex: Int) {
        playlists?[selectedIndexPlaylist].swapVideo(firstIndex, index2: secondIndex)
        tableView.reloadData()
    }

    func deletePlaylist() {
        if playlists?.count <= selectedIndexPlaylist {
            self.tableView.reloadData()
            return
        }
        playlists?[selectedIndexPlaylist].del({ (success, error) in
        })
    }
}
