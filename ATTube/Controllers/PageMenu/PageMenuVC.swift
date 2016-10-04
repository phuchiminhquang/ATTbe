//
//  PageMenuVC.swift
//  ATTube
//
//  Created by Asiantech1 on 8/2/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import SwiftUtils
import RealmSwift
import PureLayout
import PagingMenuController
import PageMenu

private extension CGFloat {
    static let menuHeight: CGFloat = 44
    static let menuItemWidth: CGFloat = kScreenSize.width / 3
    static let selectionIndicatorHeight: CGFloat = 4
    static let pageMenuHeight: CGFloat = 603 * Ratio.widthIPhone6
}

enum MenuItems: Int {
    case Home = 0
    case Trending = 1
    case Favorite = 2
}

//enum MenuItems: String {
//    case Home = "HOME"
//    case Trending = "TRENDING"
//    case Favorite = "FAVORITE"
//}

class PageMenuVC: ViewController {
    var checkInt: Int? {
        didSet {
            checkInt = 2
        }
    }
    class var sharedInstance: PageMenuVC {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PageMenuVC? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PageMenuVC()
        }
        return Static.instance!
    }

    // MARK - Oulet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var menuBarView: UIView!

    @IBOutlet private weak var homeIconButton: UIButton!
    @IBOutlet private weak var trendingIconButton: UIButton!
    @IBOutlet private weak var playlistIconButton: UIButton!

    // MARK - Property
    private var pageMenu: CAPSPageMenu?
    private var controllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(checkInt)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK - Init UI & Data
    override func configUI() {
        homeIconButton.selected = true
        navigationController?.navigationBar.hidden = true

        let homeVC = HomeVC.vc()
        let trendingVC = TrendingVC.vc()
        let favoriteVC = FavoriteVC.vc()

        homeVC.title = ""
        trendingVC.title = ""
        favoriteVC.title = ""

        controllers.append(homeVC)
        controllers.append(trendingVC)
        controllers.append(favoriteVC)

        let parameters: [CAPSPageMenuOption] = [
                .MenuItemSeparatorWidth(0),
                .MenuItemSeparatorPercentageHeight(0.1),
                .SelectionIndicatorColor(Color.yellow),
                .MenuItemSeparatorColor(Color.clear),
                .ScrollMenuBackgroundColor(Color.clear),
                .ViewBackgroundColor(Color.clear),
                .BottomMenuHairlineColor(Color.clear),
                .MenuMargin(0),
                .MenuItemWidth(CGFloat.menuItemWidth),
                .MenuHeight(CGFloat.menuHeight),
                .SelectionIndicatorHeight(CGFloat.selectionIndicatorHeight)
        ]

//        let yPageMenu = menuBarView.height + menuBarView.originY - CGFloat.menuHeight + CGFloat.selectionIndicatorHeight
        let yPageMenu = menuBarView.originY

        let pageMenuSize = CGSize(width: view.width, height: .pageMenuHeight)
        pageMenu = CAPSPageMenu(viewControllers: controllers,
            frame: CGRect(origin: CGPoint(x: 0, y: yPageMenu), size: pageMenuSize),
            pageMenuOptions: parameters)
        pageMenu?.delegate = self

        if let menuView = pageMenu?.view {
            view.addSubview(menuView)
        }

//        let options = PagingMenuOptions()
//        let pagingMenuController = PagingMenuController(options: options)
//        pagingMenuController.delegate = self
//        addChildViewController(pagingMenuController)
//        menuBarView.addSubview(pagingMenuController.view)
//        pagingMenuController.view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//        pagingMenuController.didMoveToParentViewController(self)
    }

    override func loadData() { }

    // MARK: - IBAction
    @IBAction private func showSearchVC(sender: UIButton) {
        let search = SearchVC.vc()
        navigationController?.pushViewController(search, animated: true)
    }

    @IBAction func didTapFilterCategory(sender: UIButton) {
        let categoryVC = FilterCategoryVC.vc()
        categoryVC.view.frame = CGRect(origin: CGPoint(x: 0, y: UIScreen.currentDevice.height), size: view.bounds.size)
        view.addSubview(categoryVC.view)
        UIView.animateWithDuration(0.3, animations: {
            self.view.userInteractionEnabled = false
            categoryVC.view.frame = self.view.frame
        }) { (finish) in
            if finish {
                self.view.userInteractionEnabled = true
                self.addChildViewController(categoryVC)
            }
        }
    }

    // Mark - Private function
    private func moveToMenuItemAt(index: Int) {
        guard let menuItem = MenuItems(rawValue: index) else {
            return
        }
        switch menuItem {
        case .Home:
            homeIconButton.selected = true
            trendingIconButton.selected = false
            playlistIconButton.selected = false
            titleLabel.text = Strings.homeTitle
        case .Trending:
            homeIconButton.selected = false
            trendingIconButton.selected = true
            playlistIconButton.selected = false
            titleLabel.text = Strings.trendingTitle
        case .Favorite:
            homeIconButton.selected = false
            trendingIconButton.selected = false
            playlistIconButton.selected = true
            titleLabel.text = Strings.playlistTitle

        }
    }

}

//extension PageMenuVC: PagingMenuControllerDelegate {
//    func willMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
//
//    }
//    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
//        titleLabel.text = menuController.title
//        guard let menuItem = MenuItems.init(rawValue: titleLabel.text!) else { return }
//        switch menuItem {
//        case .Home:
//            filterView.hidden = false
//            break
//        case .Trending, .Favorite:
//            filterView.hidden = true
//        }
//    }
//}

extension PageMenuVC: CAPSPageMenuDelegate {

    func willMoveToPage(controller: UIViewController, index: Int) {
    }

    func didMoveToPage(controller: UIViewController, index: Int) {
        moveToMenuItemAt(index)
    }
}

//extension PageMenuVC: PlayerVCDelegate {
//    func playVideo(index: Int?, InListVideos listVideos: List<Video>?, isShowPlaylist: Bool) {
//        guard let video = listVideos?[index!] else { return }
//        dragVideo?.prensetDetailVideoController(video)
//    }
//}
