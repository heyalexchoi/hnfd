//
//  SearchViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 2/22/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
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
        
        tableView.register(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.backgroundColor = UIColor.backgroundColor()
        
        resultsTableController = SearchResultsViewController()
        
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        
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

        

        // Do any additional setup after loading the view.
        let request = HNAlgoliaSearchRouter.search(query: "")
        _ = APIClient.request(request) { [weak self] (result: Result<HNAlgoliaSearchResponseWrapper>) in
            guard let stories = result.value?.stories else {
                return
            }
            self?.items = stories
            self?.tableView.reloadData()
        }
    }
    
    var items: [Story] = []
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
//        // Update the filtered array based on the search text.
//        let searchResults = products
//
//        // Strip out all the leading and trailing spaces.
//        let whitespaceCharacterSet = CharacterSet.whitespaces
//        let strippedString =
//            searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
//        let searchItems = strippedString.components(separatedBy: " ") as [String]
//
//        // Build all the "AND" expressions for each value in searchString.
//        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
//            findMatches(searchString: searchString)
//        }
//
//        // Match up the fields of the Product object.
//        let finalCompoundPredicate =
//            NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
//
//        let filteredResults = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
//
//        // Apply the filtered results to the search results table.
//        if let resultsController = searchController.searchResultsController as? ResultsTableController {
//            resultsController.filteredProducts = filteredResults
//            resultsController.tableView.reloadData()
//        }
    }
    
}
