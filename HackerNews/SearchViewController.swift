//
//  SearchViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 2/22/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import UIKit
import PromiseKit

class SearchViewController: UITableViewController {
    
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
        
        TableViewControllerSharedComponent.viewDidLoad(tableViewController: self)
        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.largeTitleTextAttributes = TextAttributes.largeTitleAttributes
//        navigationController?.view.backgroundColor = UIColor.backgroundColor()
//        navigationController?.navigationBar.barTintColor = UIColor.backgroundColor()
//        view.backgroundColor = UIColor.backgroundColor()
        
//        tableView.register(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
//        tableView.backgroundColor = UIColor.backgroundColor()
        
        resultsTableController = SearchResultsViewController()
        
        resultsTableController.tableView.delegate = self
        
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
                self?.tableView.reloadData()
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

extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedProduct: Product
//
//        // Check to see which table view cell was selected.
//        if tableView === self.tableView {
//            selectedProduct = products[indexPath.row]
//        } else {
//            selectedProduct = resultsTableController.filteredProducts[indexPath.row]
//        }
//
//        // Set up the detail view controller to show.
//        let detailViewController = DetailViewController.detailViewControllerForProduct(selectedProduct)
//
//        navigationController?.pushViewController(detailViewController, animated: true)
//
//        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

// MARK: - UITableViewDataSource

extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.identifier, for: indexPath) as! StoryCell
        cell.prepare(story: items[indexPath.row], isPinned: false, width: tableView.bounds.width)
        return cell
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
