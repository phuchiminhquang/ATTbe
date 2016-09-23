//
//  HomeVC.swift
//  ATTube
//
//  Created by Asiantech1 on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SwiftUtils
import SVPullToRefresh
import RealmSwift

private extension Selector {
    static let filterCategory = #selector(HomeVC.filterCategory(_:))
}

class HomeVC: ViewController {

    // MARK - Outlet
    @IBOutlet private weak var videosTableView: UITableView!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    // MARK:- Property
    private var availableCategories: [VideoCategory] = []
    private var maxResults = 10
    private var videoCategories: [String: [Video]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK - Init UI & Data
    override func configUI() {
        addNotification()
        videosTableView.registerNib(HomeCell)
    }

    override func loadData() {
        videoCategories = [:]
        let availabelCategories = RealmManager.getVideoCategories()

        if availabelCategories?.count == 0 {
            startAnimatingLoading()
            APIManager.sharedInstance.getCategories(Strings.VNCode, completionHanlder: { (videoCategories, error) in
                self.stopAnimationLoading()
                guard let videoCategories = videoCategories else { return }
                RealmManager.addVideoCategory(videoCategories, finished: { (success, error) in
//                    availabelCategories = RealmManager.getVideoCategories()
                    self.loadVideoFromCategoryID(self.convertResultToArray(availabelCategories))
                })
            })
        } else {
            self.loadVideoFromCategoryID(self.convertResultToArray(availabelCategories))
        }
    }

    @objc private func filterCategory(notification: NSNotification) {
        guard let categories = notification.object as? [VideoCategory] else { return }
        loadVideoFromCategoryID(categories)
    }

    // MARK:- Private
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .filterCategory, name: Strings.filterCategoryNotification, object: nil)
    }

    private func convertResultToArray(object: Results<VideoCategory>?) -> [VideoCategory]? {
        guard let object = object else { return nil }
        var categories: [VideoCategory] = []
        for item in object {
            categories.append(item)
        }
        return categories
    }

    @objc private func loadVideoFromCategoryID(categories: [VideoCategory]?) {
        guard let categories = categories else { return }
        videoCategories.removeAll()
        availableCategories.removeAll()
        videosTableView.reloadData()
        for item in categories {
            startAnimatingLoading()
            APIManager.sharedInstance.getVideosFromCategoryID(regionCode: Strings.VNCode,
                id: item.id!,
                limit: maxResults,
                nextPage: nil,
                completionHanlder: { (videos, nextPageToken, error) in
                    self.stopAnimationLoading()
                    guard let videos = videos, title = item.title else { return }
                    self.availableCategories.append(item)
                    self.videoCategories[title] = videos

                    self.videosTableView.beginUpdates()
                    self.videosTableView.insertSections(NSIndexSet(index: self.videoCategories.count - 1), withRowAnimation: .Automatic)
                    self.videosTableView.endUpdates()
            })
        }
    }

    private func startAnimatingLoading() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        indicator.startAnimating()
    }

    private func stopAnimationLoading() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        indicator.stopAnimating()
    }

    private func showVideosByCategoryId(video: Video?, categoryID: Int) -> Void {
        if let video = video {
            let listVideos = List<Video>()
            listVideos.append(video)
            let drag = AppDelegate.appDelegate?.getDraggableVideo()
            drag?.presentPlayerVC(nil, InListVideos: listVideos, isShowPlaylist: false)
        } else {
            let videoCategory = VideoCategoryVC(category: availableCategories[categoryID])
            navigationController?.pushViewController(videoCategory, animated: true)
        }
    }
}

// MARK: - UITableviewDataSource & Delegate
extension HomeVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return videoCategories.count
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HomeHeaderView.getCellHeight()
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NSBundle.mainBundle().loadNibNamed("HomeHeaderView", owner: self, options: nil)[0] as? HomeHeaderView
        header?.configCellAtIndex(title: availableCategories[section].title)
        return header
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let homeCell = tableView.dequeue(HomeCell)
        if let videos = videoCategories[availableCategories[indexPath.section].title ?? ""] {
            homeCell.configCellAtIndex(indexPath.section, object: videos)
            homeCell.showVideosByCategory = showVideosByCategoryId
        }
        return homeCell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return HomeCell.getCellHeight()
    }
}
