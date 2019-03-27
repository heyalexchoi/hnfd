//
//  TabBarController.swift
//  HackerNews
//
//  Created by Alex Choi on 3/26/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

class TabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let newsNavigationController = UINavigationController(rootViewController: StoriesViewController(type: .News))
        // let newestNavigationController = UINavigationController(rootViewController: StoriesViewController(type: .Newest))
        let showNavigationController = UINavigationController(rootViewController: StoriesViewController(type: .Show))
        let askNavigationController = UINavigationController(rootViewController: StoriesViewController(type: .Ask))
        // let jobNavigationController = UINavigationController(rootViewController: StoriesViewController(type: .Job))
        let savedNavigationController = UINavigationController(rootViewController: SavedStoriesViewController())
        let searchNavigationController = UINavigationController(rootViewController: SearchViewController())
        viewControllers = [
            newsNavigationController,
            askNavigationController,
            //                newestNavigationController,
            showNavigationController,
            //                jobNavigationController,
            savedNavigationController,
            searchNavigationController]
        
        tabBar.tintColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
