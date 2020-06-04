//
//  SearchViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 2/22/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import UIKit
import PromiseKit

class SearchViewController: UIViewController {
    
    let storiesViewController = StoriesTableViewController()
    var items: [Story] = []
    /// Search controller to help us with filtering.
    fileprivate var searchController: UISearchController!
    
    /// Secondary search results table view.
    fileprivate var resultsTableController: SearchResultsViewController!
    
    fileprivate var query: String {
        return searchController.searchBar.text ?? ""
    }

    fileprivate var page = 0 // max page currently loaded (vs page to fetch next)
    
    fileprivate let throttler = Throttler(minimumDelay: 0.3)
    
    fileprivate var lastQuery = (term: "", page: 0)

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Search"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // could do big title but it looks kinda dumb with big 'search' right above search bar that also says 'search'
        // i would prefer that the search bar replace the navigation item / bar title view
        // so that the search bar was in the same place to begin with as it ends up when its activated (right at the top)
        // already sunk a LOT of time into trying lots of different things
        // doesn't seem like there's an obvious way to do it through cocoa apis
        // best bet if i ever end up caring enough to do it is probably a fake navigation bar
//        viewController.navigationController?.navigationBar.prefersLargeTitles = true
//        viewController.navigationController?.navigationBar.largeTitleTextAttributes = TextAttributes.largeTitleAttributes
        navigationController?.view.backgroundColor = UIColor.backgroundColor()
        navigationController?.navigationBar.barTintColor = UIColor.backgroundColor()

        view.backgroundColor = UIColor.backgroundColor()
        
        addChild(storiesViewController)
        view.addSubviewsWithAutoLayout(storiesViewController.view)
        _ = storiesViewController.view.anchorAllEdgesToView(view)
        storiesViewController.didMove(toParent: self)
        
        resultsTableController = SearchResultsViewController()
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.backgroundColor = UIColor.backgroundColor()
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.isTranslucent = false
        
        // without this, the search bar background is black??? this makes it white again and then corrects the corner radius back to how it is supposed to look
        // lol fuck you apple
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = .white
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        // For iOS 11 and later, place the search bar in the navigation bar.
        navigationItem.searchController = searchController
        
        // Make the search bar always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // The default is true.
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        
        /** Search presents a view controller by applying normal view controller presentation semantics.
         This means that the presentation moves up the view controller hierarchy until it finds the root
         view controller or one that defines a presentation context.
         */
        
        /** Specify that this view controller determines how the search controller is presented.
         The search controller should be presented modally and match the physical size of this view controller.
         */
        definesPresentationContext = true
        
        storiesViewController.addInfiniteScroll { [weak self] in
            guard let self = self else {
                return
            }
            self.loadMostPopular(page: self.page + 1, appendStories: true, showHUD: false)
        }
        
        resultsTableController.addInfiniteScroll { [weak self] in
            guard let self = self else {
                return
            }
            self.searchAndUpdateUI(page: self.resultsTableController.page + 1, shouldAppend: true, shouldScrollToTop: false, shouldShowHUD: false)
        }
        
        loadMostPopular(page: 0, appendStories: false, showHUD: true)
    }
    
    func loadMostPopular(page: Int, appendStories: Bool, showHUD: Bool) {
        search(query: "", page: page)
            .done { [weak self] (stories) -> Void in
                self?.items = stories
                self?.storiesViewController.loadStories(stories, appendStories: appendStories, scrollToTop: false, showHUD: showHUD)
                self?.page = page
        }
    }
    
}

extension SearchViewController {
    
    func search(query: String, page: Int) -> Promise<[Story]> {
        return Promise { seal in
            let request = HNAlgoliaSearchRouter.search(query: query, page: page, perPage: 10)
            _ = APIClient.request(request) { [weak self] (result: Result<HNAlgoliaSearchResponseWrapper, Error>) in
                switch result {
                case .success(let searchResponse):
                    seal.fulfill(searchResponse.stories)
                    self?.lastQuery = (term: query, page: page)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: - UISearchControllerDelegate

// Use these delegate functions for additional control over the search controller.

extension SearchViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
}

// MARK: - UISearchResultsUpdating

extension SearchViewController: UISearchResultsUpdating {
    
    @objc func searchAndUpdateUI(page: Int, shouldAppend: Bool = false, shouldScrollToTop: Bool = false, shouldShowHUD: Bool = false) {
        
        print("--- query: \(query)")
        search(query: query, page: page)
            .done { [weak self] (stories) -> Void in
                self?.resultsTableController.loadStories(stories, appendStories: shouldAppend, scrollToTop: shouldScrollToTop, showHUD: shouldShowHUD)
                self?.resultsTableController.page = page
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard (term: query, page: resultsTableController.page) != lastQuery else {
            return
        }
        
        throttler.throttle { [weak self] in
            self?.searchAndUpdateUI(page: 0, shouldAppend: false, shouldScrollToTop: true, shouldShowHUD: true)
        }
    
    }
    
}
