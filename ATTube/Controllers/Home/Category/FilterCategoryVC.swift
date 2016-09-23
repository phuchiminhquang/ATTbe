//
//  CategoryVC.swift
//  ATTube
//
//  Created by Quang Phù on 9/3/16.
//  Copyright © 2016 at. All rights reserved.
//

import UIKit
import RealmSwift

private enum Buttons: Int {
    case AllCategory = 1
    case Filter
}

class FilterCategoryVC: ViewController {

    @IBOutlet private weak var blurView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var filterButton: UIButton!

    private var categories: Results<VideoCategory>?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    override func configUI() {
        blurView.addBlurBackground(.Dark)
        tableView.registerNib(FilterCategoryCell)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func loadData() {
        categories = RealmManager.getVideoCategories()
    }

    private func convertResultToArray(object: Results<VideoCategory>?) -> [VideoCategory]? {
        guard let object = object else { return nil }
        var categories: [VideoCategory] = []
        for item in object {
            categories.append(item)
        }
        return categories
    }

    private func getAllSelectedCategory() -> [VideoCategory]? {
        guard let indexPaths = tableView.indexPathsForSelectedRows,
            categories = categories else { return nil }
        var object: [VideoCategory] = []
        for index in indexPaths {
            object.append(categories[index.row])
        }
        return object
    }

    @IBAction func didTapDoneButton(sender: UIButton) {
        guard let buttonItem = Buttons.init(rawValue: sender.tag) else { return }
        var selectedCategories: [VideoCategory]?
        switch buttonItem {
        case .AllCategory:
            selectedCategories = convertResultToArray(categories)
            break
        case .Filter:
            selectedCategories = getAllSelectedCategory()
            break
        }
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRect(origin: CGPoint(x: 0, y: UIScreen.currentDevice.height), size: self.view.bounds.size)
        }) { (finish) in
            if finish {
                NSNotificationCenter.defaultCenter().postNotificationName(Strings.filterCategoryNotification, object: selectedCategories)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }

    }
}

// MARK: UITableViewDataSource, Delegate
extension FilterCategoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let category = categories?[indexPath.row]
        let categoryCell = tableView.dequeue(FilterCategoryCell)
        categoryCell.configCellAtIndex(indexPath.row, object: category)
        return categoryCell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView.indexPathsForSelectedRows?.isEmpty) != nil {
            filterButton.setTitle(Strings.filter, forState: .Normal)
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.indexPathsForSelectedRows?.count == nil {
            filterButton.setTitle(Strings.cancel, forState: .Normal)
        }
        print(tableView.indexPathsForSelectedRows?.count)
    }
}
