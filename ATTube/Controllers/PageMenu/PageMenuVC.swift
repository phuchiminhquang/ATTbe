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

enum MenuItems: String {
    case Home = "HOME"
    case Trending = "TRENDING"
    case Favorite = "FAVORITE"
}

class PageMenuVC: ViewController {

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
    // MARK - Property

    private var controllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK - Init UI & Data
    override func configUI() {

        navigationController?.navigationBar.hidden = true
        let options = PagingMenuOptions()
        let pagingMenuController = PagingMenuController(options: options)
        pagingMenuController.delegate = self
        addChildViewController(pagingMenuController)
        menuBarView.addSubview(pagingMenuController.view)
        pagingMenuController.view.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        pagingMenuController.didMoveToParentViewController(self)
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
}
extension PageMenuVC: PagingMenuControllerDelegate {
    func willMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {

    }
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        titleLabel.text = menuController.title
        guard let menuItem = MenuItems.init(rawValue: titleLabel.text!) else { return }
        switch menuItem {
        case .Home:
            filterView.hidden = false
            break
        case .Trending, .Favorite:
            filterView.hidden = true
        }
    }
}

//extension PageMenuVC: PlayerVCDelegate {
//    func playVideo(index: Int?, InListVideos listVideos: List<Video>?, isShowPlaylist: Bool) {
//        guard let video = listVideos?[index!] else { return }
//        dragVideo?.prensetDetailVideoController(video)
//    }
//}
