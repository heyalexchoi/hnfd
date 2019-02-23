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
    private var searchController: UISearchController!
    
    /// Secondary search results table view.
    private var resultsTableController: SearchResultsViewController!

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Search"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(storiesViewController)
        view.addSubviewsWithAutoLayout(storiesViewController.view)
        _ = storiesViewController.view.anchorAllEdgesToView(view)
        storiesViewController.didMove(toParentViewController: self)
        
        
        
        resultsTableController = SearchResultsViewController()
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.backgroundColor = UIColor.backgroundColor()
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.isTranslucent = false
        // lol fuck you apple
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
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

        search(query: "")
            .then { [weak self] (stories) -> Void in
                self?.items = stories
                self?.storiesViewController.loadStories(stories, appendStories: false, scrollToTop: false, showHUD: false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchViewController {
    
    func search(query: String) -> Promise<[Story]> {
        return Promise { (fulfill: @escaping ([Story]) -> Void, reject: @escaping (Error) -> Void) in
            let request = HNAlgoliaSearchRouter.search(query: query)
            _ = APIClient.request(request) { (result: Result<HNAlgoliaSearchResponseWrapper>) in
                guard let stories = result.value?.stories else {
                    reject(result.error!)
                    return
                }
                fulfill(stories)
            }
        }
    }
    
}

// MARK: - UITableViewDelegate


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
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        search(query: query)
        .then { (stories) -> Void in
            if let resultsController = searchController.searchResultsController as? SearchResultsViewController {
                resultsController.results = stories
                resultsController.tableView.reloadData()
            }
        }
    }
    
}
