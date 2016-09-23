//
//  APIManager.swift
//  ATTube
//
//  Created by Asiantech1 on 8/9/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

typealias APIComplete = (videos: [Video]?, nextPageToken: String?, error: NSError?) -> Void
typealias LoadVideoCategoriesComplete = (videoCategories: [VideoCategory]?, error: NSError?) -> Void
typealias UpdateVideoComplete = (index: Int?, error: NSError?) -> Void

enum Router: URLRequestConvertible {
    static var OAuthToken: String?

    case Trending(maxResults: Int, regionCode: String, nextPageToken: String?)
    case Search(searchKey: String?, videoIdentifier: String?, maxResults: Int, nextPageToken: String?)
    case DetailInformation(videoIdentifier: String?)
    case Category(regionCode: String)
    case VideoCategoryID(region: String, catID: String, limit: Int, nextPage: String?)

    var method: Alamofire.Method {
        switch self {
        case .Trending:
            return .GET
        case .Search:
            return .GET
        case .DetailInformation:
            return .GET
        case .Category:
            return .GET
        case .VideoCategoryID:
            return .GET
        }

    }

    var path: String {
        switch self {
        case .Trending:
            return "/videos"
        case .Search:
            return "/search"
        case .DetailInformation:
            return "/videos"
        case .Category:
            return "/videoCategories"
        case .VideoCategoryID:
            return "/videos"

        }

    }

    var parameter: [String: AnyObject] {
        var parameters = [String: AnyObject]()
        parameters["key"] = Strings.key

        switch self {

        case .Trending(let maxResults, let regionCode, let nextPageToken):
            parameters["part"] = Strings.trendingPart
            parameters["chart"] = Strings.trendingChart
            parameters["maxResults"] = maxResults
            parameters["regionCode"] = regionCode
            if let nextPageToken = nextPageToken {
                parameters["pageToken"] = nextPageToken
            }
            return parameters
        case .Search(let searchKey, let videoIdentifier, let maxResults, let nextPageToken):
            parameters["part"] = Strings.searchPart
            parameters["chart"] = Strings.trendingChart
            parameters["type"] = Strings.videoType
            parameters["videoDefinition"] = Strings.searchVideoDefinition
            parameters["maxResults"] = maxResults
            if let searchKey = searchKey {
                parameters["q"] = searchKey
            }
            if let nextPageToken = nextPageToken {
                parameters["pageToken"] = nextPageToken
            }
            if let videoIdentifier = videoIdentifier {
                parameters["relatedToVideoId"] = videoIdentifier
            }
            return parameters
        case .DetailInformation(let videoIdentifier):
            parameters["part"] = Strings.trendingPart
            parameters["id"] = videoIdentifier
            return parameters

        case .Category(let regionCode):
            parameters["part"] = Strings.searchPart
            parameters["regionCode"] = regionCode
            return parameters

        case .VideoCategoryID(let regionCode, let categoryID, let limit, let nextPageToken):
            parameters["part"] = Strings.trendingPart
            parameters["regionCode"] = regionCode
            parameters["videoCategoryId"] = categoryID
            parameters["chart"] = Strings.trendingChart
            parameters["maxResults"] = limit
            if let nextPageToken = nextPageToken {
                parameters["pageToken"] = nextPageToken
            }
            return parameters

        }
    }

    // MARK: URLRequestConvertible
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Strings.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue

        if let token = Router.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        switch self {
        case .Trending, .Search, .DetailInformation, .Category, .VideoCategoryID:
//            print(Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameter).0)
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameter).0
        }
    }
}

class APIManager {

    private var searchRequest: Alamofire.Request?

    class var sharedInstance: APIManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: APIManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APIManager()
        }
        return Static.instance!
    }

    func getTrendingVideos(maxResults: Int, regionCode: String, nextPageToken: String?, completionHanlder: APIComplete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // do your task
            Alamofire.request(Router.Trending(maxResults: maxResults, regionCode: regionCode, nextPageToken: nextPageToken))
                .responseJSON(completionHandler: { (response) in
                    self.executeResponse(response, completionHanlder: completionHanlder)
            })
        }
    }

    func getVideosWith(searchKey: String?, relatedVideoIdentifier: String?, maxResults: Int, nextPageToken: String?, completionHanlder: APIComplete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // do your task
            self.searchRequest?.cancel()
            self.searchRequest = Alamofire.request(Router.Search(searchKey: searchKey,
                videoIdentifier: relatedVideoIdentifier,
                maxResults: maxResults,
                nextPageToken: nextPageToken))
                .responseJSON(completionHandler: { (response) in
                    self.executeResponse(response, isLoadDetail: true, completionHanlder: completionHanlder)
            })
        }
    }

    func getDetailInfomation(video: Video?, atIndex index: Int, completionHanlder: UpdateVideoComplete?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Alamofire.request(Router.DetailInformation(videoIdentifier: video?.id)).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success:
                    if let JSON = response.result.value as? NSDictionary {
                        if let items = JSON["items"] as? NSArray {
                            for item in items {
                                if let contenDetails = item["contentDetails"] as? NSDictionary {
                                    video?.duration = contenDetails["duration"] as? String
                                }
                                if let statistics = item["statistics"] as? NSDictionary {
                                    video?.viewCount = statistics["viewCount"] as? String
                                }
                            }
                        }
                    }
                    completionHanlder?(index: index, error: nil)
                case .Failure(let error):
                    completionHanlder?(index: nil, error: error)
                }
            })
        }
    }

    private func executeResponse(response: Response<AnyObject, NSError>, isLoadDetail: Bool = false, completionHanlder: APIComplete) {
        switch response.result {
        case .Success:
            var videos: [Video] = []
            if let JSON = response.result.value as? NSDictionary {
                let nextPageToken = JSON["nextPageToken"] as? String
                if let items = JSON["items"] as? NSArray {
                    for item in items {
                        if let video = Mapper<Video>().map(item) {
//                            if isLoadDetail { getDetailInfomation(video, completionHanlder: nil) }
                            videos.append(video)
                        }
                    }
                    completionHanlder(videos: videos, nextPageToken: nextPageToken, error: nil)
                }
            }
        case .Failure(let error):
            completionHanlder(videos: nil, nextPageToken: nil, error: error)
        }
    }

    func cancel() {
        searchRequest?.cancel()
    }

    // MARK: - get video from category id
    func getCategories(regionCode: String, completionHanlder: LoadVideoCategoriesComplete?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Alamofire.request(Router.Category(regionCode: regionCode)).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .Success:
                    var videoCategories: [VideoCategory] = []
                    if let JSON = response.result.value as? NSDictionary {
                        if let items = JSON["items"] as? NSArray {

                            for item in items {
                                if let videoCategory = Mapper<VideoCategory>().map(item) {
                                    videoCategories.append(videoCategory)
                                }
                            }
                            completionHanlder?(videoCategories: videoCategories, error: nil)
                        }
                    }
                case .Failure(let error):
                    completionHanlder?(videoCategories: nil, error: error)
                }
            })
        }
    }

    func getVideosFromCategoryID(regionCode region: String, id: String, limit: Int, nextPage: String?, completionHanlder: APIComplete?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Alamofire.request(Router.VideoCategoryID(
                region: region,
                catID: id,
                limit: limit,
                nextPage: nextPage)).responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .Success:
                        var videos: [Video] = []
                        if let JSON = response.result.value as? NSDictionary {
                            let nextPageToken = JSON["nextPageToken"] as? String
                            if let items = JSON["items"] as? NSArray {
                                for item in items {
                                    if let video = Mapper<Video>().map(item) {
                                        videos.append(video)
                                    }
                                }
//                                dispatch_async(dispatch_get_main_queue()) {
                                if videos.count > 0 {
                                    completionHanlder?(videos: videos, nextPageToken: nextPageToken, error: nil)
                                } else {
                                    completionHanlder?(videos: nil, nextPageToken: nextPageToken, error: nil)
                                }
//                                }
                            }
                        }
                    case .Failure(let error):
                        completionHanlder?(videos: nil, nextPageToken: nil, error: error)
                    }
            })
        }
    }
}
