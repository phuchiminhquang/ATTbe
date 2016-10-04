//
//  Strings.swift
//  ATTube
//
//  Created by Asiantech1 on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation

struct Strings {

    // MARK - Title for view controller
    static let homeTitle = "HOME"
    static let trendingTitle = "TRENDING"
    static let favoriteTitle = "FAVORITE"
    static let playlistTitle = "PLAYLISTS"

    static let pushPlayerVC = "pushPlayerVC"

    static let VNCode = "VN"
    static let baseURLString = "https://www.googleapis.com/youtube/v3"
    static let key = "AIzaSyDSiZgWjra0czA4qY1K2oKcEqPDu6J_wwM"

    static let videoType = "video"
    static let channelType = "channel"
    static let playlistType = "playlist"

    static let trendingPart = "snippet,contentDetails,statistics"
    static let trendingChart = "mostPopular"

    static let searchPart = "snippet"
    static let searchVideoDefinition = "high"

    static let yes = "Yes"
    static let confirm = "Confirm"
    static let cancel = "Cancel"
    static let filter = "Filter"
    static let addPlaylist = "My Playlist"
    static let messagePlaylist = "Choose playlist you want"
    static let addNew = "Create new"
    static let playlistNamePlaceHolder = "Playlist name"

    static let warning = "Warning"
    static let success = "Success"
    static let error = "Error"
    static let warningMessage = "The video is existed in playlist"
    static let successMessage = "The video has added"
    static let networkFailedMessage = "Can not connect to network"
    static let fetchVideoFailedMessage = "Can not load this video"

    static let showMore = "Show more"
    static let showLess = "Show less"

    static let notificationAddPlaylist = "Add Playlist"

    static let mpMoviePlayerNowPlayingMovieDidChange = "MPMoviePlayerNowPlayingMovieDidChangeNotification"
    static let mpMoviePlayerLoadStateDidChange = "MPMoviePlayerLoadStateDidChangeNotification"
    static let mpMoviePlayerPlaybackStateDidChange = "MPMoviePlayerPlaybackStateDidChangeNotification"
    static let mpMoviePlayerPlaybackDidFinish = "MPMoviePlayerPlaybackDidFinishNotification"
    static let refreshListTrending = "RefreshListTrendingNotification"

    static let undefinedTime = "--:--"

    static let filterCategoryNotification = "filterCategory"

}
