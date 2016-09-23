//
//  Playlist.swift
//  ATTube
//
//  Created by Quang Phù on 8/18/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {

    dynamic var title = ""
    let videos = List<Video>()

    required convenience init(name: String) {
        self.init()
        self.title = name
    }

//    func addVideo(video: Video, finished: RealmComplete?) {
//        for item in videos {
//            if video.id == item.id {
//                finished?(success: false, error: nil)
//                return
//            }
//        }
//        RealmManager.addVideo(video: video, into: videos, finished: finished)
//    }

    func deleteVideoByIndex(index: Int, finished: RealmComplete?) {
        return RealmManager.deleteVideoByIndex(index, inPlaylist: self, finished: finished)
    }

    func swapVideo(index1: Int, index2: Int) -> Bool {
        return RealmManager.swapVideo(videos, between: index1, and: index2)
    }

    func del(finished: RealmComplete) {
        RealmManager.deletePlaylist(playlist: self, finished: finished)
    }
}
