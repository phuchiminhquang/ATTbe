//
//  TrendingVC.swift
//  ATTube
//
//  Created by Asiantech1 on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SVPullToRefresh
import RealmSwift

typealias PlayVideoBlock = (index: Int?, InListVideos: List<Video>?, isShowPlaylist: Bool) -> Void

class TrendingVC: ViewController {

    // MARK: - Outlet
    @IBOutlet private weak var videosTableView: UITableView!
    @IBOutlet private weak var thumbnailVideoContainerView: UIView!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!

    // MARK: - Property
    private var trendingVideos: [Video] = []

    private var nextPageToken: String?
    private var limit = 10
    private var regionCode = "VN"

    override func viewDidLoad() {
        super.viewDidLoad()
        videosTableView.userInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK - Init UI & Data
    override func configUI() {
        addNotification()

        // Register xib for cell
        videosTableView.registerNib(TrendingCell)

        // setup pull-to-refresh
        videosTableView.addPullToRefreshWithActionHandler {
            self.loadVideos(isRefresh: true)
        }

        // setup infinite scrolling
        videosTableView.addInfiniteScrollingWithActionHandler {
            self.loadVideos(isRefresh: false)
        }

        configPullToRefreshView()
    }

    override func loadData() {
        self.loadVideos(isRefresh: true)
        indicator.startAnimating()
    }

    // MARK: - Private function
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(TrendingVC.refreshData),
            name: Strings.refreshListTrending,
            object: nil)
    }

    private func configPullToRefreshView() {
        videosTableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        videosTableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
    }

    private func loadVideos(isRefresh refresh: Bool) {
        if !Reachability.isConnectedToNetwork() {
            MessageManager.sharedInstance.show(messageType: .Warning, title: Strings.warning, subTitle: Strings.networkFailedMessage, finished: nil)
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if refresh {
            nextPageToken = nil
            trendingVideos.removeAll()
            videosTableView.reloadData()
//            indicator.startAnimating()
        }
        APIManager.sharedInstance.getTrendingVideos(limit, regionCode: regionCode, nextPageToken: nextPageToken) {
            (videos, nextPageToken, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.indicator.stopAnimating()
            self.videosTableView.userInteractionEnabled = true

            self.videosTableView.pullToRefreshView.stopAnimating()
            self.videosTableView.infiniteScrollingView.stopAnimating()
            if let videos = videos where error == nil {
                self.nextPageToken = nextPageToken
                self.trendingVideos.appendContentsOf(videos)

                self.videosTableView.beginUpdates()
                var indexPaths = [NSIndexPath]()
                for row in (self.trendingVideos.count - videos.count)..<self.trendingVideos.count {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                }
                self.videosTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                self.videosTableView.endUpdates()

            }
        }
    }

    private func addFavorite(index: Int) -> Void {
        let video = trendingVideos[index]
        showAlertAddVideoToPlaylist(video)
    }

    @objc private func refreshData() {
        indicator.startAnimating()
        loadVideos(isRefresh: true)
    }

}

// MARK: - UITableviewDataSource, UITableViewDelegate
extension TrendingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trendingVideos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let video = trendingVideos[indexPath.row]
        let trendingCell = tableView.dequeue(TrendingCell)
        trendingCell.configCellAtIndex(indexPath.row, object: video)
        trendingCell.addFavorite = addFavorite
        return trendingCell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TrendingCell.getCellHeight()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let video = trendingVideos[indexPath.row]
        let listVideos = List<Video>()
        listVideos.append(video)
        let drag = AppDelegate.appDelegate?.getDraggableVideo()
        drag?.presentPlayerVC(nil, InListVideos: listVideos, isShowPlaylist: false)
    }
}
