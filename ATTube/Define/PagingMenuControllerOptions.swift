//
//  Alert.swift
//  ATTube
//
//  Created by Quang Phù on 8/18/16.
//  Copyright © 2016 at. All rights reserved.
//

import Foundation
import PagingMenuController
import RealmSwift

private extension CGFloat {
    static let menuHeight: CGFloat = 48 * Ratio.widthIPhone6
    static let selectionIndicatorHeight: CGFloat = 4
}

var iBackgroundColor: UIColor { return Color.clear }
var iSelectedBackgroundColor: UIColor { return Color.clear }
var iHeight: CGFloat { return CGFloat.menuHeight }
var iFocusMode: MenuFocusMode {
    return .Underline(height: CGFloat.selectionIndicatorHeight, color: Color.yellow, horizontalPadding: 0, verticalPadding: 0)
}

private var pagingControllers: [UIViewController] {
    let homeVC = HomeVC.vc()
    let trendingVC = TrendingVC.vc()
    let favoriteVC = FavoriteVC.vc()
    homeVC.title = MenuItems.Home.rawValue
    trendingVC.title = MenuItems.Trending.rawValue
    favoriteVC.title = MenuItems.Favorite.rawValue
    return [homeVC, trendingVC, favoriteVC]
}

struct MenuItemHome: MenuItemViewCustomizable {
    var displayMode: MenuItemDisplayMode {
        return .Image(image: UIImage(assetIdentifier: .Home), selectedImage: UIImage(assetIdentifier: .HomeActive))
    }
}

struct MenuItemTrending: MenuItemViewCustomizable {
    var displayMode: MenuItemDisplayMode {
        return .Image(image: UIImage(assetIdentifier: .Trending), selectedImage: UIImage(assetIdentifier: .TrendingActive))
    }
}

struct MenuItemFavorite: MenuItemViewCustomizable {
    var displayMode: MenuItemDisplayMode {
        return .Image(image: UIImage(assetIdentifier: .Favorite), selectedImage: UIImage(assetIdentifier: .FavoriteActive))
    }
}

struct PagingMenuOptions: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    var menuControllerSet: MenuControllerSet {
        return .Single
    }

    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor = iBackgroundColor
        var selectedBackgroundColor = iSelectedBackgroundColor
        var height = iHeight
        var focusMode = iFocusMode

        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemTrending(), MenuItemFavorite()]
        }
    }
}

struct PagingMenuOptions1: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }

    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor = iBackgroundColor
        var selectedBackgroundColor = iSelectedBackgroundColor
        var height = iHeight
        var focusMode = iFocusMode

        var displayMode: MenuDisplayMode {
            return .Standard(widthMode: .Flexible, centerItem: false, scrollingMode: .PagingEnabled)
        }

        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemTrending(), MenuItemFavorite()]
        }
    }
}

struct PagingMenuOptions2: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    var menuControllerSet: MenuControllerSet {
        return .Single
    }

    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor = iBackgroundColor
        var selectedBackgroundColor = iSelectedBackgroundColor
        var height = iHeight
        var focusMode = iFocusMode

        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemTrending(), MenuItemFavorite()]
        }
    }
}
//
struct PagingMenuOptions3: PagingMenuControllerCustomizable {

    var componentType: ComponentType {
        return .All(menuOptions: MenuOptions(), pagingControllers: pagingControllers)
    }
    var lazyLoadingPage: LazyLoadingPage {
        return .Three
    }

    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor = iBackgroundColor
        var selectedBackgroundColor = iSelectedBackgroundColor
        var height = iHeight
        var focusMode = iFocusMode

        var displayMode: MenuDisplayMode {
            return .Infinite(widthMode: .Fixed(width: 200), scrollingMode: .ScrollEnabled)
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemTrending(), MenuItemFavorite()]
        }
    }
}
//
struct PagingMenuOptions4: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .MenuView(menuOptions: MenuOptions())
    }

    struct MenuOptions: MenuViewCustomizable {
        var backgroundColor = iBackgroundColor
        var selectedBackgroundColor = iSelectedBackgroundColor
        var height = iHeight
        var focusMode = iFocusMode

        var displayMode: MenuDisplayMode {
            return .SegmentedControl
        }

        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemTrending(), MenuItemFavorite()]
        }
    }
}
//
struct PagingMenuOptions5: PagingMenuControllerCustomizable {
    var componentType: ComponentType {
        return .MenuView(menuOptions: MenuOptions())
    }

    struct MenuOptions: MenuViewCustomizable {
        var displayMode: MenuDisplayMode {
            return .Infinite(widthMode: .Flexible, scrollingMode: .PagingEnabled)
        }
        var focusMode: MenuFocusMode {
            return .RoundRect(radius: 12, horizontalPadding: 8, verticalPadding: 8, selectedColor: UIColor.lightGrayColor())
        }
        var itemsOptions: [MenuItemViewCustomizable] {
            return [MenuItemHome(), MenuItemTrending(), MenuItemFavorite()]
        }
    }
}

//struct PagingMenuOptions6: PagingMenuControllerCustomizable {
//    var componentType: ComponentType {
//        return .PagingController(pagingControllers: pagingControllers)
//    }
//    var defaultPage: Int {
//        return 1
//    }
//}
