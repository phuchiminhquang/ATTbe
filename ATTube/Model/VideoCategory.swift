//
//  VideoCategory.swift
//  ATTube
//
//  Created by Quang Phù on 8/31/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class VideoCategory: Object, Mappable {
    dynamic var id: String?
    dynamic var title: String?

    override static func primaryKey() -> String? {
        return "id"
    }

    required convenience init?(_ map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.id <- map["id"]
        self.title <- map["snippet.title"]
    }
}
