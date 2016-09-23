//
//  Video.swift
//  ATTube
//
//  Created by Asiantech1 on 8/10/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class Video: Object, Mappable {
    dynamic var id: String?
    dynamic var channelID: String?
    dynamic var title: String?
    dynamic var describe: String?
    dynamic var defaultThumbnailURL: String?
    dynamic var mediumThumbnailURL: String?
    dynamic var highThumbnailURL: String?
    dynamic var duration: String?
    dynamic var viewCount: String?

    let owners = LinkingObjects(fromType: Playlist.self, property: "videos")

    override static func primaryKey() -> String? {
        return "id"
    }

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.id <- map["id"]
        if self.id == nil {
            self.id <- map["id.videoId"]
        }
        self.channelID <- map["channelId"]
        self.title <- map["snippet.title"]
        self.describe <- map["snippet.description"]
        self.defaultThumbnailURL <- map["snippet.thumbnails.default.url"]
        self.mediumThumbnailURL <- map["snippet.thumbnails.medium.url"]
        self.highThumbnailURL <- map["snippet.thumbnails.high.url"]
        self.duration <- map["contentDetails.duration"]
        self.viewCount <- map["statistics.viewCount"]
    }
}
