//
//  SearchResultsViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 2/22/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {

    var page = 0 // max page currently loaded (vs page to fetch next)
    fileprivate let storiesViewController = StoriesTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(storiesViewController)
        view.addSubviewsWithAutoLayout(storiesViewController.view)
        _ = storiesViewController.view.anchorAllEdgesToView(view)
        storiesViewController.didMove(toParent: self)
    }
    
    func loadStories(_ stories: [Story], appendStories: Bool, scrollToTop: Bool, showHUD: Bool) {
        storiesViewController.loadStories(stories, appendStories: appendStories, scrollToTop: scrollToTop, showHUD: showHUD)
    }
    
    func addInfiniteScroll(_ action: @escaping () -> Void) {
        storiesViewController.addInfiniteScroll(action)
    }
}
