//
//  MoviePlayerVC.swift
//  ATTube
//
//  Created by Quang Phù on 8/24/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVKit

protocol MoviePlayerVCDelegate {
    func playOtherVideo(action actions: Actions)
    func closePlayerViewController()
    func fullScreen(isFullscreen flag: Bool)
    func setRepeatMode(mode: RepeatType)
}

private enum Buttons: Int {
    case Previous = 1
    case Next
    case Play
}

enum Actions: Int {
    case NextVideo = 1
    case PreviousVideo
    case PlaybackDidFinish
}

enum RepeatType: Int {
    case None = 1
    case All
    case One

    var icon: UIImage? {
        switch self {
        case None: return UIImage(named: "NoneRepeat")
        case One: return UIImage(named: "RepeatOne")
        case All: return UIImage(named: "RepeatAll")
        }
    }

    func nextState() -> RepeatType {
        switch self {
        case None: return RepeatType(rawValue: 2)!
        case All: return RepeatType(rawValue: 3)!
        case One: return RepeatType(rawValue: 1)!
        }
    }
}

private extension Selector {
    static let updateTime = #selector(MoviePlayerVC.updateTime)
    static let hiddenControlView = #selector(MoviePlayerVC.hiddenControlView)
    static let moviePlayerNowPlayingMovieDidChange = #selector(MoviePlayerVC.moviePlayerNowPlayingMovieDidChange(_:))
    static let moviePlayerPlaybackDidChange = #selector(MoviePlayerVC.moviePlayerPlaybackDidChange(_:))
    static let moviePlayerPlayBackDidFinish = #selector(MoviePlayerVC.moviePlayerPlayBackDidFinish(_:))
}

class MoviePlayerVC: ViewController {

    // MARK:- IBOutlet
    @IBOutlet private weak var playerVideoView: UIView!
    @IBOutlet private weak var controlView: UIView!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var beginTimeLabel: UILabel!
    @IBOutlet private weak var sliderTime: UISlider!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var footerView: UIView!
    @IBOutlet private weak var fullScreenImageView: UIImageView!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var dismissButton: UIButton!
    @IBOutlet private weak var dismissVCImageView: UIImageView!
    @IBOutlet private weak var repeatButton: UIButton!
    @IBOutlet private weak var seperatorLabel: UILabel!

    // MARK:- Property
    private var youtubeVideoPlayer: XCDYouTubeVideoPlayerViewController?
    private var mediaPlayer: MPMoviePlayerController?
    private var timeUpdate: NSTimer?
    private var timeHiddenTool: NSTimer?
    private var isFullscreen = false
    private var isHiddenControlView = true
    private var repeatState = RepeatType(rawValue: 1)!
    var isDestroyed = false

    var videoIdentifier: String?
    var delegate: MoviePlayerVCDelegate?

    init(videoIdentifier: String?) {
        super.init(nibName: "MoviePlayerVC", bundle: nil)
        self.videoIdentifier = videoIdentifier

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Override function
    override func configUI() {
        let thumb = UIImage(named: "thumbSlider")?.imageWithImage(scaledToSize: CGSize(size: 14))
        sliderTime.setThumbImage(thumb, forState: .Normal)
        addNotification()
        footerView.addBlurBackground(.Light)
        controlView.hidden = isHiddenControlView
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if isHiddenControlView {
            setupTimerHiddenControl()
            controlView.hidden = false
        } else {
            hiddenControlView()
        }
        isHiddenControlView = !isHiddenControlView
    }

    // MARK:- Private method
    private func autoFontSize() {
        let helveticaFont = HelveticaFont()
        beginTimeLabel.font = helveticaFont.Light(14)
        endTimeLabel.font = helveticaFont.Light(14)
        seperatorLabel.font = helveticaFont.Light(14)
    }

    private func setupTimerUpdateSecond() {
        timeUpdate?.invalidate()
        timeUpdate = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: .updateTime,
            userInfo: nil, repeats: true)
    }

    private func setupTimerHiddenControl() {
        timeHiddenTool?.invalidate()
        timeHiddenTool = NSTimer.scheduledTimerWithTimeInterval(3.0,
            target: self,
            selector: .hiddenControlView,
            userInfo: nil, repeats: false)

    }

    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: .moviePlayerNowPlayingMovieDidChange,
            name: Strings.mpMoviePlayerNowPlayingMovieDidChange,
            object: nil)

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: .moviePlayerPlaybackDidChange,
            name: Strings.mpMoviePlayerPlaybackStateDidChange,
            object: nil)
    }

    private func addPlaybackDidFinishNotification() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: .moviePlayerPlayBackDidFinish,
            name: Strings.mpMoviePlayerPlaybackDidFinish,
            object: mediaPlayer)
    }

    private func deletePlaybackDidFinishNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: Strings.mpMoviePlayerPlaybackDidFinish,
            object: mediaPlayer
        )
    }

    private func configControlViewPlayblackFinished() {
        beginTimeLabel.text = Strings.undefinedTime
        endTimeLabel.text = Strings.undefinedTime
        sliderTime.value = 0
    }

    private func animationLoading(isLoad flag: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = flag
        flag ? indicator?.startAnimating() : indicator?.stopAnimating()
    }

    private func playVideoWithStreamURL(streamURL streamURL: NSURL?) {
        deletePlaybackDidFinishNotification()
        destroyMediaPlayer()
        if !isDestroyed {
            mediaPlayer = MPMoviePlayerController(contentURL: streamURL)
            guard let mediaPlayer = mediaPlayer else { return }
            mediaPlayer.controlStyle = .None
            mediaPlayer.play()
            view.addSubview(mediaPlayer.view)
            mediaPlayer.view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            view.bringSubviewToFront(controlView)
            view.bringSubviewToFront(indicator)
            addPlaybackDidFinishNotification()
        }
    }

    private func destroyMediaPlayer() {
        if let _ = mediaPlayer {
            mediaPlayer?.stop()
            mediaPlayer?.view.removeFromSuperview()
            mediaPlayer = nil
        }
    }

    // MARK:- Implement Selector Method
    @objc private func updateTime() {
        guard let mediaPlayer = mediaPlayer else { return }
        let second = mediaPlayer.currentPlaybackTime
        if !second.isNaN {
            let currentTime = HandleTime.convertIntervalTime(Int(second))
            var hour = currentTime.hour
            var min = NSString(format: "%02d", currentTime.minute)
            var sec = NSString(format: "%02d", currentTime.second)
            beginTimeLabel.text = hour == 0 ? "\(min):\(sec)" : "\(hour):\(min):\(sec)"

            let remainingTime = HandleTime.convertIntervalTime(Int(mediaPlayer.duration))
            hour = remainingTime.hour
            min = NSString(format: "%02d", remainingTime.minute)
            sec = NSString(format: "%02d", remainingTime.second)
            endTimeLabel.text = hour == 0 ? "\(min):\(sec)" : "\(hour):\(min):\(sec)"

            sliderTime.value = Float(second) / Float(mediaPlayer.duration)
        }
    }

    // MARK:- Public Method
    func hiddenControlView() {
        self.controlView.hidden = true
        self.isHiddenControlView = true
    }

    func fetchVideo() {
        if !Reachability.isConnectedToNetwork() {
            MessageManager.sharedInstance.show(messageType: .Warning,
                title: Strings.warning,
                subTitle: Strings.networkFailedMessage,
                finished: nil)
            return
        }
        animationLoading(isLoad: true)
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(videoIdentifier) {
            (video: XCDYouTubeVideo?, error: NSError?) in
            if error != nil {
                self.animationLoading(isLoad: false)
                MessageManager.sharedInstance.show(messageType: .Error,
                    title: Strings.error,
                    subTitle: String(error),
                    finished: nil)
            }
            if let streamURL = video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
            video?.streamURLs[XCDYouTubeVideoQuality.HD720.rawValue] ??
            video?.streamURLs[XCDYouTubeVideoQuality.Medium360.rawValue] ??
            video?.streamURLs[XCDYouTubeVideoQuality.Small240.rawValue] {
                self.playVideoWithStreamURL(streamURL: streamURL)
            } else {
                MessageManager.sharedInstance.show(messageType: .Warning,
                    title: Strings.warning,
                    subTitle: Strings.fetchVideoFailedMessage, finished: nil)
            }
        }
    }

    func releaseObjectBeforeDeinit() {
        animationLoading(isLoad: false)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        destroyMediaPlayer()
    }

    func updateIconFullScreen(isFullscreen flag: Bool) {
        fullScreenImageView.highlighted = flag
//        dismissButton.hidden = flag
//        dismissVCImageView.hidden = flag
    }

    // MARK:- IBOutlet
    @IBAction private func didTapCloseButton(sender: UIButton) {
        delegate?.closePlayerViewController()
    }

    @IBAction private func didTapFullScreenButton(sender: UIButton) {
        isFullscreen = !isFullscreen
        updateIconFullScreen(isFullscreen: isFullscreen)
        delegate?.fullScreen(isFullscreen: isFullscreen)
    }

    @IBAction private func didTapChangeStateVideoButton(sender: UIButton) {
        guard let buttonItem = Buttons(rawValue: sender.tag) else {
            return
        }
        switch buttonItem {
        case .Next:
            delegate?.playOtherVideo(action: .NextVideo); break
        case .Previous:
            delegate?.playOtherVideo(action: .PreviousVideo); break
        case .Play:
            guard let mediaPlayer = mediaPlayer else { return }
            switch mediaPlayer.playbackState {
            case .Playing: mediaPlayer.pause(); break
            case .Paused: mediaPlayer.play(); break
            default: break
            }
        }
    }

    @IBAction func playbackAtSliderTime(sender: UISlider) {
        guard let mediaPlayer = mediaPlayer else { return }

        mediaPlayer.currentPlaybackTime = Double(Double(sliderTime.value) * mediaPlayer.duration)
        let secondPlay = NSInteger(Double(sliderTime.value) * mediaPlayer.duration % 60)
        let stringsSecond = NSString(format: "%02d", NSInteger(secondPlay))
        let min = NSInteger(Double(sliderTime.value) * Double(mediaPlayer.duration) / 60) % 60
        beginTimeLabel.text = "\(min):\(stringsSecond)"
        setupTimerUpdateSecond()
    }
}

// MARK: Playback Notification
extension MoviePlayerVC {
    @objc private func moviePlayerNowPlayingMovieDidChange(notification: NSNotification) {
        print("moviePlayerNowPlayingMovieDidChange")
        animationLoading(isLoad: false)
    }

    @objc private func moviePlayerPlayBackDidFinish(notification: NSNotification) {
        configControlViewPlayblackFinished()
        delegate?.playOtherVideo(action: .PlaybackDidFinish)
    }

    @objc private func moviePlayerPlaybackDidChange(notification: NSNotification) {
        guard let mediaPlayer = mediaPlayer else { return }
        let state: MPMoviePlaybackState = mediaPlayer.playbackState
        switch state {

        case MPMoviePlaybackState.Stopped: print("stopped"); break

        case MPMoviePlaybackState.Interrupted: print("Interrupted"); break

        case MPMoviePlaybackState.SeekingForward: print("SeekingForward");break

        case MPMoviePlaybackState.SeekingBackward: print("SeekingBackward");break

        case MPMoviePlaybackState.Paused:
            print("paused")
            playButton.selected = true
            break

        case MPMoviePlaybackState.Playing:
            print("playing")
            playButton.selected = false
            setupTimerUpdateSecond()
            setupTimerHiddenControl()
            break
        }
    }
}

// MARK: Hanlde Repeat
extension MoviePlayerVC {

    @IBAction func didTapRepeatButton(sender: UIButton) {
        let nextRepeatState = repeatState.nextState()
        repeatButton.setBackgroundImage(nextRepeatState.icon, forState: .Normal)
        repeatState = nextRepeatState
    }
}
