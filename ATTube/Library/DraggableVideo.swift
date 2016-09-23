//
//  DraggableVideo.swift
//  ATTube
//
//  Created by Quang Phù on 9/8/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import AICustomViewControllerTransition

class DraggalbeVideo {
    private var thumbnailContainer: UIView!
    private let customTransitioningDelegate = InteractiveTransitioningDelegate()
    private var parentVC: UIViewController!
    lazy var videoPlayerViewController: PlayerVC? = {
        let vc = PlayerVC()

        vc.modalPresentationStyle = .Custom
        vc.transitioningDelegate = self.customTransitioningDelegate
        vc.handlePan = { (panGestureRecozgnizer) in
            let translatedPoint = panGestureRecozgnizer.translationInView(self.parentVC.view)
            if panGestureRecozgnizer.state == .Began {
                self.customTransitioningDelegate.beginDismissing(viewController: vc)
                self.lastVideoPlayerOriginY = vc.view.frame.origin.y
            } else if panGestureRecozgnizer.state == .Changed {
                let x = (self.lastVideoPlayerOriginY + translatedPoint.y) / self.thumbnailContainer.frame.origin.y
                let ratio = max(min(x, 1), 0)
                self.lastPanRatio = ratio
                self.customTransitioningDelegate.updateInteractiveTransition(self.lastPanRatio)
            } else if panGestureRecozgnizer.state == .Ended {
                let completed = (self.lastPanRatio > self.panRatioThreshold) || (self.lastPanRatio < -self.panRatioThreshold)
                self.customTransitioningDelegate.finalizeInteractiveTransition(isTransitionCompleted: completed)
            }
        }
        return vc
    }()

    private let panRatioThreshold: CGFloat = 0.3
    private var lastPanRatio: CGFloat = 0.0
    private var lastVideoPlayerOriginY: CGFloat = 0.0
    private var videoPlayerInitialFrame: CGRect?

    init(rootViewController: UIViewController) {
        self.parentVC = rootViewController
        thumbnailContainer = UIView()

        updateThumbnailFrame()

    }

    func updateThumbnailFrame() {
        let screenSize = UIScreen.mainScreen().bounds.size
        let width = 180 * Ratio.widthIPhone6
        let height = 100 * Ratio.widthIPhone6
        thumbnailContainer.frame = CGRect(
            x: screenSize.width - (width + 5), y: screenSize.height - (height + 5),
            width: width, height: height)
    }

    func draggbleProgress() {
        customTransitioningDelegate.transitionPresent = { [weak self](fromViewController: UIViewController, toViewController: UIViewController,
            containerView: UIView, transitionType: TransitionType,
            completion: () -> Void) in
            guard let weakSelf = self else {
                return
            }
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
            guard let videoPlayerViewController = toViewController as? PlayerVC else { return }
            if case .Simple = transitionType {
                if weakSelf.videoPlayerInitialFrame != nil {
                    videoPlayerViewController.view.frame = weakSelf.videoPlayerInitialFrame!
                    weakSelf.videoPlayerInitialFrame = nil
                } else {
                    videoPlayerViewController.view.frame = CGRect(origin: CGPoint(x: 0, y: videoPlayerViewController.view.height),
                        size: containerView.bounds.size)
                }
            }
            weakSelf.thumbnailContainer.border(color: Color.clear, width: 1)
            UIView.animateWithDuration(defaultTransitionAnimationDuration, animations: {
                videoPlayerViewController.view.transform = CGAffineTransformIdentity
                videoPlayerViewController.view.frame = containerView.bounds
                videoPlayerViewController.backgroundView.alpha = 1.0
                }, completion: { (finished) in
                completion()
                videoPlayerViewController.view.userInteractionEnabled = true
            })

        }
        customTransitioningDelegate.transitionDismiss = {
            [weak self](
                fromViewController: UIViewController, toViewController: UIViewController,
                containerView: UIView, transitionType: TransitionType,
                completion: () -> Void) in
            guard let weakSelf = self else {
                return
            }

            guard let videoPlayerViewController = fromViewController as? PlayerVC else { return }
            UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
            let dx = weakSelf.thumbnailContainer.bounds.width / videoPlayerViewController.playVideoView.bounds.width
            let dy = weakSelf.thumbnailContainer.bounds.height / videoPlayerViewController.playVideoView.bounds.height
            let finalTransform = CGAffineTransformMakeScale(dx, dy)
            var finalSize: CGSize?

            UIView.animateWithDuration(defaultTransitionAnimationDuration, animations: {
                videoPlayerViewController.view.transform = finalTransform
                finalSize = videoPlayerViewController.view.frame.size
                videoPlayerViewController.view.frame = CGRect(origin: weakSelf.thumbnailContainer.frame.origin,
                    size: weakSelf.thumbnailContainer.bounds.size)
                videoPlayerViewController.backgroundView.alpha = 0.0
                }, completion: { (finished) in
                completion()

                videoPlayerViewController.view.userInteractionEnabled = false

//                var thumbnailRect = videoPlayerViewController.view.frame
//                thumbnailRect.origin = CGPoint.zero

                videoPlayerViewController.view.frame = CGRect(origin: CGPoint.zero, size: finalSize!)

                weakSelf.thumbnailContainer.addSubview(videoPlayerViewController.view)
                AppDelegate.appDelegate?.window?.addSubview(weakSelf.thumbnailContainer)
                AppDelegate.appDelegate?.window?.bringSubviewToFront(weakSelf.thumbnailContainer)
                weakSelf.thumbnailContainer.border(color: Color.gray, width: 1)
                if weakSelf.videoPlayerViewController!.isAutoRelease {
                    self?.releaseMemory({
                        AppDelegate.appDelegate?.dragVideo = nil
                    })
                }
            })
        }
        transitionPercent()
    }

    func transitionPercent () {
        customTransitioningDelegate.transitionPercentPresent = { [weak self](fromViewController: UIViewController,
            toViewController: UIViewController, percentage: CGFloat, containerView: UIView) in
            guard let weakSelf = self, videoPlayerViewController = toViewController as? PlayerVC else {
                return
            }

            if weakSelf.videoPlayerInitialFrame != nil {
                weakSelf.videoPlayerViewController!.view.frame = weakSelf.videoPlayerInitialFrame!
                weakSelf.videoPlayerInitialFrame = nil
            }
            let startXScale = weakSelf.thumbnailContainer.bounds.width / containerView.bounds.width
            let startYScale = weakSelf.thumbnailContainer.bounds.height * 3 / containerView.bounds.height
            let xScale = startXScale + ((1 - startXScale) * percentage)
            let yScale = startYScale + ((1 - startYScale) * percentage)
            toViewController.view.transform = CGAffineTransformMakeScale(xScale, yScale)
            let startXPos = weakSelf.thumbnailContainer.frame.origin.x
            let startYPos = weakSelf.thumbnailContainer.frame.origin.y
            let horizontalMove = startXPos - (startXPos * percentage)
            let verticalMove = startYPos - (startYPos * percentage)
            var finalRect = toViewController.view.frame
            finalRect.origin.x = horizontalMove
            finalRect.origin.y = verticalMove
            toViewController.view.frame = finalRect
            videoPlayerViewController.backgroundView.alpha = percentage
        }

        customTransitioningDelegate.transitionPercentDismiss = { [weak self](fromViewController: UIViewController,
            toViewController: UIViewController, percentage: CGFloat, containerView: UIView) in

            guard let weakSelf = self else {
                return
            }
            let videoPlayerViewController = fromViewController as? PlayerVC
            let videoPlayerBounds = videoPlayerViewController!.view.bounds
            let finalXScale = weakSelf.thumbnailContainer.bounds.width / videoPlayerBounds.width
            let finalYScale = weakSelf.thumbnailContainer.bounds.height / videoPlayerBounds.height
            let xScale = 1 - (percentage * (1 - finalXScale))
            let yScale = 1 - (percentage * (1 - finalYScale))
            videoPlayerViewController!.view.transform = CGAffineTransformMakeScale(xScale, yScale)
            let finalXPos = weakSelf.thumbnailContainer.frame.origin.x
            let finalYPos = weakSelf.thumbnailContainer.frame.origin.y
            var finalRect = videoPlayerViewController!.view.frame
            finalRect.origin.x = min(weakSelf.thumbnailContainer.frame.origin.x * percentage, finalXPos)
            finalRect.origin.y = min(weakSelf.thumbnailContainer.frame.origin.y * percentage, finalYPos)
            videoPlayerViewController!.view.frame = finalRect
            videoPlayerViewController!.backgroundView.alpha = 1 - percentage
        }

    }

    func addActionToView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentFromThumbnailAction))
        thumbnailContainer.addGestureRecognizer(tap)
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePresentPan))
//        thumbnailContainer.addGestureRecognizer(pan)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(exitPLayerVideo))
        thumbnailContainer.addGestureRecognizer(panGesture)
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(removePlayerVideo))
//        swipeLeft.direction = .Left
//        thumbnailContainer.addGestureRecognizer(swipeLeft)
    }

    @objc private func presentFromThumbnailAction(sender: UITapGestureRecognizer? = nil) {
        videoPlayerInitialFrame = thumbnailContainer.convertRect(videoPlayerViewController!.view.frame, toView: parentVC!.view)
        videoPlayerViewController!.removeFromParentViewController()
        let topVC = UIApplication.topViewControllerWithRootViewController(AppDelegate.appDelegate?.window?.rootViewController)
        topVC!.presentViewController(videoPlayerViewController!, animated: true, completion: nil)
//        UIApplication.topViewController()!.presentViewController(videoPlayerViewController!, animated: true, completion: nil)
    }

//    @objc private func handlePresentPan(panGestureRecozgnizer: UIPanGestureRecognizer) {
//        guard videoPlayerViewController.parentViewController != nil || customTransitioningDelegate.isPresenting else {
//            return
//        }
//        let translatedPoint = panGestureRecozgnizer.translationInView(parentVC.view)
//        if panGestureRecozgnizer.state == .Began {
//            videoPlayerInitialFrame = thumbnailContainer.convertRect(videoPlayerViewController.view.frame, toView: parentVC.view)
//            videoPlayerViewController.removeFromParentViewController()
//            customTransitioningDelegate.beginPresenting(viewController: videoPlayerViewController, fromViewController: parentVC)
//            videoPlayerInitialFrame = thumbnailContainer.convertRect(videoPlayerViewController.view.frame, toView: parentVC.view)
//            lastVideoPlayerOriginY = videoPlayerInitialFrame!.origin.y
//
//        } else if panGestureRecozgnizer.state == .Changed {
//            let ratio = max(min(((lastVideoPlayerOriginY + translatedPoint.y) / CGRectGetMinY(thumbnailContainer.frame)), 1), 0)
//            lastPanRatio = 1 - ratio
//            customTransitioningDelegate.updateInteractiveTransition(lastPanRatio)
//        } else if panGestureRecozgnizer.state == .Ended {
//            let completed = lastPanRatio > panRatioThreshold || lastPanRatio < -panRatioThreshold
//            customTransitioningDelegate.finalizeInteractiveTransition(isTransitionCompleted: completed)
//        }
//    }

    @objc private func exitPLayerVideo(panGesture: UIPanGestureRecognizer) {

        let screenSize = UIScreen.mainScreen().bounds.size
        let width = 180 * Ratio.widthIPhone6
        let height = 100 * Ratio.widthIPhone6
        videoPlayerInitialFrame = CGRect(x: screenSize.width - (width + 5), y: screenSize.height - (height + 5), width: width, height: height)

        switch panGesture.state {
        case .Began:
            break
        case .Changed:
            let translation = panGesture.translationInView(thumbnailContainer)
            thumbnailContainer.center = CGPoint(x: thumbnailContainer.center.x + translation.x,
                y: thumbnailContainer.center.y)
            let percentAlpha = thumbnailContainer.center.x / UIScreen.mainScreen().bounds.size.width
            thumbnailContainer.alpha = percentAlpha
            panGesture.setTranslation(CGPoint.zero, inView: thumbnailContainer)
        case .Ended:
            let velocity = panGesture.velocityInView(thumbnailContainer)
            print("velocity \(thumbnailContainer.center)")
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            let slideFactor = 0.1 * slideMultiplier

            if thumbnailContainer.center.x > UIScreen.mainScreen().bounds.width / 2 {
                UIView.animateWithDuration(Double(slideFactor * 2),
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: { self.thumbnailContainer.frame = self.videoPlayerInitialFrame!
                        self.thumbnailContainer.alpha = 1.0
                    },
                    completion: nil)
            } else {
                parentVC.view.userInteractionEnabled = false
                UIView.animateWithDuration(Double(slideFactor * 2),
                    delay: 0,
                    options: UIViewAnimationOptions.CurveEaseOut,
                    animations: { self.thumbnailContainer.frame = CGRect(
                        origin: CGPoint(x: -self.thumbnailContainer.bounds.width, y: self.thumbnailContainer.frame.origin.y),
                        size: self.thumbnailContainer.bounds.size) },
                    completion: { (finish) in
                        self.releaseMemory({
                            AppDelegate.appDelegate?.dragVideo = nil
                            self.parentVC.view.userInteractionEnabled = true
                        })
                })
            }
        default:
            break
        }
    }

    func presentPlayerVC(index: Int?, InListVideos listVideos: List<Video>?, isShowPlaylist: Bool) {
        if videoPlayerViewController!.parentViewController != nil {
            videoPlayerInitialFrame = thumbnailContainer.convertRect(self.videoPlayerViewController!.view.frame, toView: parentVC.view)
            self.videoPlayerViewController!.removeFromParentViewController()
        }
        videoPlayerViewController!.configDataFirstInit(index, InListVideos: listVideos, isShowPlaylist: isShowPlaylist)
        parentVC.presentViewController(videoPlayerViewController!, animated: true, completion: nil)
    }

    func prensetDetailVideoController(video: Video) {
        if videoPlayerViewController!.parentViewController != nil {
            videoPlayerInitialFrame = thumbnailContainer.convertRect(self.videoPlayerViewController!.view.frame, toView: parentVC.view)
            self.videoPlayerViewController!.removeFromParentViewController()
        }

        let listVideos = List<Video>()
        listVideos.append(video)
        videoPlayerViewController!.configDataFirstInit(0, InListVideos: listVideos, isShowPlaylist: false)
        parentVC.presentViewController(videoPlayerViewController!, animated: true, completion: nil)
    }
}

extension DraggalbeVideo {
    func releaseMemory(finish: () -> Void) {
        videoPlayerViewController!.releaseMemory()
        videoPlayerViewController = nil
        thumbnailContainer.removeFromSuperview()
        finish()
    }
}
