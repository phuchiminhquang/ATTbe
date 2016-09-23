//
//  SearchHistory.swift
//  ATTube
//
//  Created by Quang Phù on 9/19/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import RealmSwift

class SearchHistory: Object {
    dynamic var searchKey: String? = nil
    dynamic var date: NSDate? = nil

    override static func primaryKey() -> String? {
        return "searchKey"
    }

    convenience init(searchKey: String, date: NSDate) {
        self.init()
        self.searchKey = searchKey
        self.date = date
    }
}
