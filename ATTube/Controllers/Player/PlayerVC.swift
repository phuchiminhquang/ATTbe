//
//  PlayerVC.swift
//  ATTube
//
//  Created by Asiantech1 on 8/8/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SVPullToRefresh
import RealmSwift
import XCDYouTubeKit
import PureLayout

protocol PlayerVCDelegate {
    func playVideo(index: Int?, InListVideos listVideos: List<Video>?, isShowPlaylist: Bool)
}

protocol UpdatePlaylistDelegate {
    func deleteVideoAt(index: Int)
    func swapVideo(firstIndex: Int, secondIndex: Int)
    func deletePlaylist()
}

private extension Selector {
    static let longPressGestureRecognized = #selector(PlayerVC.longPress(_:))
    static let rotated = #selector(PlayerVC.rotated)
}

struct MyView {
    static var cellSnapshot: UIView? = nil
    static var cellIsAnimating: Bool = false
    static var cellNeedToShow: Bool = false
}

struct Path {
    static var initialIndexPath: NSIndexPath? = nil
}

class PlayerVC: ViewController {

    // MARK: IBOutlet
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var playVideoView: UIView!
    @IBOutlet private weak var videosTableView: UITableView!
    @IBOutlet private weak var videoNameLabel: UILabel!
    @IBOutlet private weak var totalViewsLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var showDescriptionButton: UIButton!
    @IBOutlet private weak var showMoreButton: UIButton!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundView: UIView!

    // MARK: Private Property
    private var moviePlayerVC: MoviePlayerVC?
    private var listVideos: List<Video>?
    lazy private var history: List<Video> = { return List<Video>() }()
    private var indexPlayingVideo: Int = 0
    private var indexHistory = 0
    private var isShowPlaylist = false
    private var isExpand = false
    private var isFullScreen = false
    private var isAutoplay = true
    private var isFirstRunTime = false
    private var isDeletedCell = false
    private var nextPageToken: String? = nil
    private var limit = 10
    private var longPress: UILongPressGestureRecognizer!
    private var repeatMode = RepeatType(rawValue: 1)!

    // MARK: Public Property
    var delegate: UpdatePlaylistDelegate?
    var handlePan: ((panGestureRecognizer: UIPanGestureRecognizer) -> Void)?
    var isAutoRelease = false

    // MARK: Construction & override method
    init() {
        super.init(nibName: "PlayerVC", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateContentViewFrame()
        moveToSelectedCell(indexPlayingVideo)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Allow rotate Device
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController() {
            let value = Int(UIInterfaceOrientation.Portrait.rawValue)
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
    }

    func canRotate() -> Void { }

    override func configUI() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PlayerVC.panning(_:)))
        playVideoView.addGestureRecognizer(panGesture)

        addNotification()
        autoFontSize()

        videosTableView.registerNib(PlayerCell)
        videosTableView.registerNib(AutoplayCell)
        videosTableView.addInfiniteScrollingWithActionHandler {
            self.handleLoadMore(self.listVideos?[0])
        }
        videosTableView.infiniteScrollingView.activityIndicatorViewStyle = .White

        if isShowPlaylist {
            videosTableView.addGestureRecognizer(longPress)
        }
        isFirstRunTime = true
    }

    override func loadData() {
        longPress = UILongPressGestureRecognizer(target: self, action: .longPressGestureRecognized)
        configMoviePlayerViewController()
        if !isShowPlaylist {
            indicator.startAnimating()
        }
        handleLoadMore(listVideos?[indexPlayingVideo])
    }

    // MARK:- Implement notification & selector method
    @objc private func reloadData() {
        if isShowPlaylist {
            videosTableView.reloadData()
        }
    }

    @objc private func panning(panGesture: UIPanGestureRecognizer) {
        handlePan?(panGestureRecognizer: panGesture)
    }

    // MARK: - Private function
    private func configMoviePlayerViewController() {
        moviePlayerVC = MoviePlayerVC(videoIdentifier: listVideos?[indexPlayingVideo].id)
        guard let moviePlayerVC = moviePlayerVC, video = listVideos?[indexPlayingVideo] else { return }
        moviePlayerVC.delegate = self
        moviePlayerVC.fetchVideo()

        playVideoView.addSubview(moviePlayerVC.view)
        moviePlayerVC.view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        addChildViewController(moviePlayerVC)
        loadDataForPlayingVideo(video)
        if !isShowPlaylist {
            saveHistory(video)
        }
    }

    private func saveHistory(video: Video) {
        history.append(video)
        indexHistory = history.count - 1
    }

    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .rotated,
            name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlayerVC.reloadData),
            name: Strings.notificationAddPlaylist, object: nil)
    }

    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        videoNameLabel.font = helveticaFont.Regular(20)
        totalViewsLabel.font = helveticaFont.Light(14)
        descriptionLabel.font = helveticaFont.Regular(14)
    }

    private func loadDataForPlayingVideo(video: Video?) {
        guard let playingVideo = video else { return }
        videoNameLabel.text = playingVideo.title
        totalViewsLabel.text = HandleData.viewCount(playingVideo.viewCount)
        descriptionLabel.text = playingVideo.describe
        descriptionLabel.numberOfLines = 2
        isExpand = false
    }

    private func reloadSectionIndexTitles() {
        videosTableView.beginUpdates()
        videosTableView.reloadSectionIndexTitles()
        videosTableView.endUpdates()
    }

    private func deleteVideoAt(index: Int) {
        // Delete video in realm
        delegate?.deleteVideoAt(index)

        isDeletedCell = true
        videosTableView.beginUpdates()
        videosTableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
        videosTableView.endUpdates()

        if listVideos?.count == 0 {
            moviePlayerVC?.releaseObjectBeforeDeinit()
            // SAI
            moviePlayerVC?.isDestroyed = true
            isAutoRelease = true
            closePlayerViewController()
            return
        }

        if indexPlayingVideo == index {
            indexPlayingVideo = 0
            playVideo(listVideos?[indexPlayingVideo])
        } else if index < indexPlayingVideo {
            indexPlayingVideo -= 1
        }
        print("index: \(indexPlayingVideo)")
        moveToSelectedCell(indexPlayingVideo, isScroll: false)
    }

    private func moveToSelectedCell(index: Int, isScroll: Bool = true) {
        if isShowPlaylist && index < listVideos?.count {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            guard let _ = videosTableView else { return }
            videosTableView.selectRowAtIndexPath(indexPath,
                animated: true,
                scrollPosition: .None)
            if isScroll {
                videosTableView.scrollToRowAtIndexPath(indexPath,
                    atScrollPosition: .Middle,
                    animated: true)
            }
        }
    }

    private func updateContentViewFrame() {
        guard let contentView = contentView else { return }
        contentView.frame.size = CGSize(width: contentView.width,
            height: 5 * Ratio.widthIPhone6 + videoNameLabel.height + totalViewsLabel.height + descriptionLabel.height + showMoreButton.height)
        reloadSectionIndexTitles()
    }

    private func showDescription(flag: Bool?) {
        let direction: CGFloat = flag ?? isExpand == false ? (180.0 * CGFloat(M_PI)) : (360.0 * CGFloat(M_PI))
        UIView.animateWithDuration(0.3, animations: {
            self.showDescriptionButton.transform = CGAffineTransformMakeRotation(direction / 180)
            self.descriptionLabel.numberOfLines = flag ?? self.isExpand == false ? 0 : 2
            self.descriptionLabel.sizeToFit()
            self.updateContentViewFrame()
        }) { (finish) in
        }
        showMoreButton.setTitle(flag ?? self.isExpand ? Strings.showMore : Strings.showLess, forState: .Normal)
        isExpand = !(flag ?? isExpand)
    }

    private func playVideo(video: Video?) {
        guard let video = video else { return }
//        if indexPlayingVideo >= listVideos?.count { return }
        showDescription(true)
        moviePlayerVC?.videoIdentifier = video.id
        moviePlayerVC?.fetchVideo()
        loadDataForPlayingVideo(video)
    }

    private func loadRelatedVideo(video: Video?) {
        if let playingVideo = video {
            indexPlayingVideo = 0
            nextPageToken = nil
            listVideos?.removeAll()
            listVideos?.append(playingVideo)
            videosTableView.reloadData()
            indicator.startAnimating()
            handleLoadMore(playingVideo)
        }
    }

    // MARK: Static Methods
    static func tableViewHeight() -> CGFloat {
        return 457 * Ratio.widthIPhone6
    }

    // MARK - Public Method
    func configDataFirstInit(index: Int?, InListVideos listVideos: List<Video>?, isShowPlaylist: Bool) {
        self.isShowPlaylist = isShowPlaylist
        self.listVideos = listVideos
        indexPlayingVideo = index ?? 0
        if isFirstRunTime {
            videosTableView.reloadData()
            playVideo(listVideos?[indexPlayingVideo])
            videosTableView.removeGestureRecognizer(longPress)
            if isShowPlaylist {
                videosTableView.addGestureRecognizer(longPress)
            } else {
                history.removeAll()
                indicator.startAnimating()
                loadRelatedVideo(self.listVideos?[indexPlayingVideo])
            }
        }
    }

    // MARK:- IBAction
    @IBAction func didTapShowDecription(sender: AnyObject) {
        showDescription(nil)
    }
}

// MARK: - UITableviewDataSource, UITableViewDelegate
extension PlayerVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return descriptionLabel.height
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listVideos?.count ?? 0
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if !isShowPlaylist && indexPath.row == 0 { return AutoplayCell.getCellHeight() }
        return PlayerCell.getCellHeight()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !isShowPlaylist && indexPath.row == 0 {
            let autoplayCell = tableView.dequeue(AutoplayCell)
            autoplayCell.autoplay = { (isOn) in
                self.isAutoplay = isOn
            }
            return autoplayCell
        }
        let video = listVideos?[indexPath.row]
        let playerCell = tableView.dequeue(PlayerCell)
        playerCell.configCellAtIndex(indexPath.row, object: video)
        playerCell.addFavorite = addFavorite

        return playerCell
    }

    private func addFavorite(index: Int) -> Void {
        guard let video = listVideos?[index] else { return }
        moveToSelectedCell(indexPlayingVideo, isScroll: false)
        showAlertAddVideoToPlaylist(video)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPlayingVideo == indexPath.row { return }
        indexPlayingVideo = indexPath.row
        guard let video = listVideos?[indexPlayingVideo] else { return }
//        cell.backgroundColor = UIColor.blueColor()
        playVideo(video)
        if !isShowPlaylist {
            saveHistory(video)
            loadRelatedVideo(video)
        }
    }

//    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
//        cell.backgroundColor = UIColor.clearColor()
//    }

    // Action for cell
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return isShowPlaylist
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            deleteVideoAt(indexPath.row)
            isDeletedCell = true
        default:
            break
        }
    }
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        isDeletedCell = false
    }

    func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        if !isDeletedCell {
            let index = NSIndexPath(forRow: indexPlayingVideo, inSection: 0)
            guard let _ = tableView.cellForRowAtIndexPath(indexPath) else { return }
            tableView.selectRowAtIndexPath(index, animated: true, scrollPosition: .None)
        }
    }
}

extension PlayerVC: MoviePlayerVCDelegate {
    // Implement require method
    func playOtherVideo(action action: Actions) {
        switch action {
        case .NextVideo:
            playNextVideo(); break
        case .PreviousVideo:
            playPreviousVideo(); break
        case .PlaybackDidFinish:
            playVideoDidFinish(); break
        }
    }

    func closePlayerViewController() {
        moviePlayerVC?.hiddenControlView()
        if isFullScreen {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
            isFullScreen = !isFullScreen
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    func fullScreen(isFullscreen flag: Bool) {
        updateFrameWhenRotatedDevice(isLandsape: flag)
    }

    func setRepeatMode(mode: RepeatType) {
        self.repeatMode = mode
    }

    private func playVideoDidFinish() {
        if isShowPlaylist || (!isShowPlaylist && isAutoplay) {
            playNextVideo()
        }
    }

    private func playNextVideo() {
        guard let listVideos = listVideos else { return }
        if indexPlayingVideo == listVideos.count - 1 { return }
        indexPlayingVideo += 1
        let video = listVideos[indexPlayingVideo]
        if !isShowPlaylist {
            saveHistory(video)
            loadRelatedVideo(video)
        } else {
            moveToSelectedCell(indexPlayingVideo)
        }
        playVideo(video)
    }

    private func playPreviousVideo() {
        var video: Video?
        if isShowPlaylist {
            if indexPlayingVideo == 0 { return }
            indexPlayingVideo = indexPlayingVideo - 1
            video = listVideos?[indexPlayingVideo]
            moveToSelectedCell(indexPlayingVideo)
        } else {
            indexHistory -= 1
            if indexHistory >= 0 && indexHistory < history.count {
                video = history[indexHistory]
                history.removeAtIndex(indexHistory + 1)
                loadRelatedVideo(history[indexHistory])
            }
        }
        playVideo(video)
    }

    func releaseMemory() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if !isShowPlaylist {
            listVideos?.removeAll()
        }
        moviePlayerVC?.isDestroyed = true
        moviePlayerVC?.releaseObjectBeforeDeinit()
        moviePlayerVC = nil
    }
}

// MARK: Sort cell
extension PlayerVC {
    @objc private func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let statePress = gestureRecognizer.state
        var location = gestureRecognizer.locationInView(videosTableView)
        location.y = handleLocationWhenDragCell(location.y)
        guard let indexPath = videosTableView.indexPathForRowAtPoint(location),
            cell = videosTableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        else { return }
        switch statePress {
        case .Began:

            Path.initialIndexPath = indexPath
            MyView.cellSnapshot = snapshotOfCell(cell)

            var center = cell.center
            MyView.cellSnapshot!.center = center
            MyView.cellSnapshot!.alpha = 0.0
            videosTableView.addSubview(MyView.cellSnapshot!)

            UIView.animateWithDuration(0.25, animations: { () -> Void in
                center.y = location.y
                MyView.cellIsAnimating = true
                MyView.cellSnapshot!.center = center
                MyView.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                MyView.cellSnapshot!.alpha = 0.98
                cell.alpha = 0.0
                }, completion: nil)

        case .Changed:
            guard let cellSnapshot = MyView.cellSnapshot, firstIndex = Path.initialIndexPath?.row,
                initialIndexPath = Path.initialIndexPath else { return }

            cell.alpha = 0.0
            cellSnapshot.center.y = location.y

            if firstIndex != indexPath.row {
                if firstIndex == indexPlayingVideo {
                    indexPlayingVideo = indexPath.row
                }
                delegate?.swapVideo(initialIndexPath.row, secondIndex: indexPath.row)
                videosTableView.moveRowAtIndexPath(initialIndexPath, toIndexPath: indexPath)
                Path.initialIndexPath = indexPath
            }
            let contentY = videosTableView.contentOffset.y + videosTableView.frame.height
            if cellSnapshot.frame.origin.y < videosTableView.contentOffset.y {
                scrollToUp()
            } else if cellSnapshot.frame.origin.y + cellSnapshot.frame.height > contentY
            && videosTableView.contentOffset.y + videosTableView.frame.height < videosTableView.contentSize.height {
                scrollToDown()
            }

        default:
            // if MyView.cellIsAnimating {
            // MyView.cellNeedToShow = true
            // } else {
            // cell.hidden = false
            // cell.alpha = 0.0
            // }
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                MyView.cellSnapshot!.center = cell.center
                MyView.cellSnapshot!.transform = CGAffineTransformIdentity
                MyView.cellSnapshot!.alpha = 0.0
                cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                Path.initialIndexPath = nil
                MyView.cellSnapshot!.removeFromSuperview()
                MyView.cellSnapshot = nil
            })
        }
    }

    private func handleLocationWhenDragCell(originY: CGFloat) -> CGFloat {
        if originY <= contentView.height {
            return contentView.height + PlayerCell.getCellHeight() / 2
        } else if originY >= videosTableView.contentSize.height {
            return videosTableView.contentSize.height - 1
        }
        return originY
    }

    private func scrollToUp() {
        if videosTableView.contentOffset.y != 0 {
            let y = videosTableView.contentOffset.y - 5
            videosTableView.contentOffset.y = y > 0 ? y : 0
            if let cellSnapshot = MyView.cellSnapshot {
                if cellSnapshot.frame.origin.y < videosTableView.contentOffset.y {
                    scrollToUp()
                }
            }
        }
    }

    private func scrollToDown() {
        let y = videosTableView.contentOffset.y + 5
        if y + videosTableView.frame.height < videosTableView.contentSize.height {
            videosTableView.contentOffset.y = y
            if let cellSnapshot = MyView.cellSnapshot {
                let contentY = videosTableView.contentOffset.y + videosTableView.frame.height
                if cellSnapshot.frame.origin.y < videosTableView.contentOffset.y {
                    scrollToUp()
                } else if cellSnapshot.frame.origin.y + cellSnapshot.frame.height > contentY
                && videosTableView.contentOffset.y + videosTableView.frame.height < videosTableView.contentSize.height {
                    scrollToDown()
                }
            }
        }
    }

    private func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()

        let cellSnapshot: UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }

}

// MARK: Rotated
extension PlayerVC {
    @objc private func rotated() {
        switch UIDevice.currentDevice().orientation {
        case .Portrait:
            isFullScreen = false
        case .LandscapeLeft, .LandscapeRight, .PortraitUpsideDown:
            isFullScreen = true
        default: return
        }
        updateFrameWhenRotatedDevice(isLandsape: isFullScreen)
        moviePlayerVC?.updateIconFullScreen(isFullscreen: isFullScreen)
    }

    private func updateFrameWhenRotatedDevice(isLandsape flag: Bool) {
        guard let moviePlayerView = moviePlayerVC?.view else { return }
        moviePlayerView.removeFromSuperview()
        var value = 0
        if flag {
            self.view.addSubview(moviePlayerView)
            value = UIInterfaceOrientation.LandscapeLeft.rawValue

        } else {
            self.playVideoView.addSubview(moviePlayerView)
            value = UIInterfaceOrientation.Portrait.rawValue
        }
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        moviePlayerView.autoPinEdgesToSuperviewEdgesWith(0.0, top: 0.0, trailing: 0.0, bottom: 0.0)
    }

}

// MARK: Request API
extension PlayerVC {
    private func handleLoadMore(video: Video?) {
        if !isShowPlaylist {
            guard let video = video, listVideos = listVideos else { return }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            APIManager.sharedInstance.getVideosWith(nil,
                relatedVideoIdentifier: video.id,
                maxResults: limit,
                nextPageToken: nextPageToken) { (videos, nextPageToken, error) in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.videosTableView.infiniteScrollingView.stopAnimating()
                    self.indicator.stopAnimating()

                    if let videos = videos where error == nil {
                        self.nextPageToken = nextPageToken
                        listVideos.appendContentsOf(videos)

                        self.videosTableView.beginUpdates()
                        var indexPaths = [NSIndexPath]()
                        for row in (listVideos.count - videos.count)..<listVideos.count {
                            self.getDetailVideo(self.listVideos?[row], atIndex: row)
                            indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                        }
                        self.videosTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                        self.videosTableView.endUpdates()
                    }
            }
        } else {
            guard let _ = videosTableView.infiniteScrollingView else { return }
            videosTableView.infiniteScrollingView.stopAnimating()
        }
    }

    private func getDetailVideo(video: Video?, atIndex index: Int) {
        APIManager.sharedInstance.getDetailInfomation(video, atIndex: index) { (index, error) in
            guard let index = index else { return }
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let _ = self.videosTableView.cellForRowAtIndexPath(indexPath) {
                self.videosTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }

}
