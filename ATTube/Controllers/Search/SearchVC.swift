//
//  SearchVC.swift
//  ATTube
//
//  Created by Asiantech1 on 8/1/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import MapKit
import SVPullToRefresh
import RealmSwift

private enum TableViewType: Int {
    case History = 1
    case Result
}

class SearchVC: ViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchResultTableView: UITableView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet weak var searchHistoryTableview: UITableView!

    private var searchKey = ""
    private var nextPageToken: String?
    private var isLoadMore = true
    private var limit = 10
    private var searchVideos: [Video] = []
    private var searchHistory: Results<SearchHistory>?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK - Init UI & Data
    override func configUI() {
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = Color.yellow
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.keyboardAppearance = .Dark

        searchResultTableView.userInteractionEnabled = false
        searchResultTableView.registerNib(PlayerCell)
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self

        view.bringSubviewToFront(searchHistoryTableview)

        // setup pull-to-refresh
        searchResultTableView.addPullToRefreshWithActionHandler {
            self.loadVideo(isRefresh: true)
        }

        // setup infinite scrolling
        searchResultTableView.addInfiniteScrollingWithActionHandler {
            self.loadVideo(isRefresh: false)
        }
        configPullToRefreshView()
    }

    override func loadData() {
        searchHistory = RealmManager.getSearchHistory()
    }

    // MARK:- Private function
    private func autoFontSize() {
        let helvetical = HelveticaFont()
        messageLabel.font = helvetical.Regular(19)
    }

    private func configPullToRefreshView() {
        searchResultTableView.pullToRefreshView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        searchResultTableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
    }

    private func loadVideo(isRefresh refresh: Bool) {
        if searchKey != "" {
            messageLabel.hidden = true
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            if refresh {
                nextPageToken = nil
                self.searchVideos.removeAll()
                self.searchResultTableView.reloadData()
            }

            APIManager.sharedInstance.getVideosWith(searchKey, relatedVideoIdentifier: nil,
                maxResults: limit,
                nextPageToken: nextPageToken) { (videos, nextPageToken, error) in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.searchResultTableView.pullToRefreshView.stopAnimating()
                    self.searchResultTableView.infiniteScrollingView.stopAnimating()
                    self.searchResultTableView.userInteractionEnabled = true

                    guard let videos = videos where error == nil else { return }
                    self.nextPageToken = nextPageToken
                    self.searchVideos.appendContentsOf(videos)

//                    self.searchResultTableView.reloadData()
                    self.searchResultTableView.beginUpdates()
                    var indexPaths: [NSIndexPath] = [NSIndexPath]()
                    for row in (self.searchVideos.count - videos.count)..<self.searchVideos.count {
                        self.getDetailVideo(self.searchVideos[row], atIndex: row)
                        indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                    }
                    self.searchResultTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                    self.searchResultTableView.endUpdates()

            }
        } else {
            self.searchResultTableView.pullToRefreshView.stopAnimating()
            self.searchResultTableView.infiniteScrollingView.stopAnimating()
        }
    }

    private func getDetailVideo(video: Video, atIndex index: Int) {
        APIManager.sharedInstance.getDetailInfomation(video, atIndex: index) { (index, error) in
            guard let index = index else { return }
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let _ = self.searchResultTableView.cellForRowAtIndexPath(indexPath) {
                self.searchResultTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }

    private func clearData() {
        APIManager.sharedInstance.cancel()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        searchKey = ""

        searchVideos.removeAll()
        searchResultTableView.reloadData()

        searchHistoryTableview.hidden = false
        messageLabel.hidden = false

        searchResultTableView.userInteractionEnabled = false
    }

    private func addFavorite(index: Int) -> Void {
        let video = searchVideos[index]
        showAlertAddVideoToPlaylist(video)
    }

    // MARK: - IBAciton
    @IBAction private func dismissViewController(sender: UIButton) {
        clearData()
        view.endEditing(true)
        navigationController?.popViewControllerAnimated(true)
    }

    deinit {

    }

}

// MARK:- UITableViewDataSource, UITableViewDelegate
extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = TableViewType(rawValue: tableView.tag) else { return 0 }
        switch type {
        case .History:
            return searchHistory?.count ?? 0
        case .Result:
            return searchVideos.count
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let type = TableViewType(rawValue: tableView.tag) else { return 0 }
        switch type {
        case .History:
            return 40
        case .Result:
            return PlayerCell.getCellHeight()
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        guard let type = TableViewType(rawValue: tableView.tag) else { return UITableViewCell() }
        switch type {
        case .History:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "HistoryCell")
            cell.textLabel?.text = searchHistory?[indexPath.row].searchKey
            cell.textLabel?.textColor = UIColor.RGB(197, 197, 197)
            let helveticaFont = HelveticaFont()
            cell.textLabel?.font = helveticaFont.Regular(15)
            cell.backgroundColor = Color.black20
            cell.selectionStyle = .None
            return cell
        case .Result:
            let video = searchVideos[indexPath.row]
            let cell = tableView.dequeue(PlayerCell)
            cell.addFavorite = addFavorite
            cell.configCellAtIndex(indexPath.row, object: video)
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let type = TableViewType(rawValue: tableView.tag) else { return }
        switch type {
        case .History:
            let key = searchHistory?[indexPath.row].searchKey ?? ""
            clearData()
            self.searchKey = key
            searchBar.text = self.searchKey
            searchHistoryTableview.hidden = true
            loadVideo(isRefresh: true)
        case .Result:
            let video = searchVideos[indexPath.row]
            let listVideos = List<Video>()
            listVideos.append(video)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            RealmManager.saveHistory(self.searchKey, finished: {
                self.searchHistoryTableview.reloadData()
            })
            view.endEditing(true)
            let drag = AppDelegate.appDelegate?.getDraggableVideo()
            drag?.presentPlayerVC(nil, InListVideos: listVideos, isShowPlaylist: false)
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        if searchBar.text == "" {
            searchHistoryTableview.hidden = false
        }
        return true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchKey = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        clearData()
        searchHistoryTableview.hidden = true
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        searchKey = searchText
        if searchText == "" {
            view.bringSubviewToFront(searchHistoryTableview)
            clearData()
        } else {
            searchHistoryTableview.hidden = true
//            searchResultTableView.userInteractionEnabled = true
            loadVideo(isRefresh: true)
        }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        RealmManager.saveHistory(self.searchKey, finished: {
            self.searchHistoryTableview.reloadData()
        })
    }
}
