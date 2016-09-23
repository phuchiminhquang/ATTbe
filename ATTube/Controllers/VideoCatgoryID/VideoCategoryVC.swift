//
//  VideoCategoryVC.swift
//  ATTube
//
//  Created by Quang Phù on 9/5/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SVPullToRefresh
import RealmSwift

class VideoCategoryVC: ViewController {

    @IBOutlet private weak var videosTableView: UITableView!
    @IBOutlet private weak var categoryName: UILabel!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!

    private var videosCategory: [Video] = []
    private var category: VideoCategory?
    private var nextPageToken: String?
    private var maxResults = 10

    init(category: VideoCategory) {
        super.init(nibName: "VideoCategoryVC", bundle: nil)
        self.category = category
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videosTableView.userInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK - Init UI & Data
    override func configUI() {
        // Register xib for cell
        videosTableView.registerNib(TrendingCell)
        videosTableView.dataSource = self
        videosTableView.delegate = self

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
        categoryName.text = category?.title?.uppercaseString
        self.loadVideos(isRefresh: true)
        indicator.startAnimating()
    }

    // MARK: - Private function
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
            videosCategory.removeAll()
            videosTableView.reloadData()
        }
        APIManager.sharedInstance.getVideosFromCategoryID(regionCode: Strings.VNCode,
            id: category?.id ?? "0",
            limit: maxResults,
            nextPage: nextPageToken,
            completionHanlder: { (videos, nextPageToken, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                self.videosTableView.pullToRefreshView.stopAnimating()
                self.videosTableView.infiniteScrollingView.stopAnimating()
                self.indicator.stopAnimating()
                self.videosTableView.userInteractionEnabled = true

                guard let videos = videos else { return }

                self.nextPageToken = nextPageToken
                self.videosCategory.appendContentsOf(videos)

                self.videosTableView.beginUpdates()
                var indexPaths = [NSIndexPath]()
                for row in (self.videosCategory.count - videos.count)..<self.videosCategory.count {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                }
                self.videosTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                self.videosTableView.endUpdates()
        })
    }

    private func addFavorite(index: Int) -> Void {
        let video = videosCategory[index]
        showAlertAddVideoToPlaylist(video)
    }

    @IBAction func didTapBackViewController(sender: UIButton) {
        category = nil
        videosCategory.removeAll()
        navigationController?.popViewControllerAnimated(true)
    }

    deinit {
        category = nil
        videosCategory.removeAll()
    }
}

extension VideoCategoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosCategory.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let video = videosCategory[indexPath.row]
        let trendingCell = tableView.dequeue(TrendingCell)
        trendingCell.configCellAtIndex(indexPath.row, object: video)
        trendingCell.addFavorite = addFavorite
        return trendingCell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TrendingCell.getCellHeight()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let video = videosCategory[indexPath.row]
        let listVideos = List<Video>()
        listVideos.append(video)
        let drag = AppDelegate.appDelegate?.getDraggableVideo()
        drag?.presentPlayerVC(nil, InListVideos: listVideos, isShowPlaylist: false)
    }
}
