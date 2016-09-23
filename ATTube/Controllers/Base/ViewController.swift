//
//  ViewController.swift
//  ATTube
//
//  Created by AsianTech on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        configUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK - Init UI & Data
    func configUI() {
    }

    func loadData() {
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func showAlertAddVideoToPlaylist(video: Video) {
        var playlistNames: [String] = []
        let playlists = RealmManager.getAllPlaylist()
        if let playlists = playlists {
            for item in playlists {
                playlistNames.append(item.title)
            }
        }
        Alert.sharedInstance.showActionSheet(self,
            title: Strings.addPlaylist,
            message: Strings.messagePlaylist,
            options: playlistNames) { (index, isCreate) in
                if isCreate {
                    Alert.sharedInstance.inputTextAlert(self, title: Strings.addNew, message: "", confirmHandler: { (text) in
                        if text != "" {
                            self.addVideo(video: video, intoPlaylist: text)
                        }
                    })
                } else {
                    guard let playlists = playlists, index = index else {
                        return
                    }
                    self.addVideo(video: video, intoPlaylist: playlists[index].title)
                }
        }
    }

    private func addVideo(video video: Video, intoPlaylist playlistName: String) {
        RealmManager.addVideo(video: video, intoPlaylistName: playlistName, finished: { (success, error) in
            if success {
                MessageManager.sharedInstance.show(messageType: .Success, title: Strings.success, subTitle: Strings.successMessage, finished: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(Strings.notificationAddPlaylist, object: nil)
            } else {

                MessageManager.sharedInstance.show(messageType: .Warning, title: Strings.warning, subTitle: Strings.warningMessage, finished: nil)
            }
        })
    }
}
