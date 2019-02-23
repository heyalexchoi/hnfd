//
//  TableViewControllerSharedComponent.swift
//  HackerNews
//
//  Created by Alex Choi on 2/23/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import UIKit

struct TableViewControllerSharedComponent {
    
    static func viewDidLoad(tableViewController: UITableViewController) {
        tableViewController.navigationController?.navigationBar.prefersLargeTitles = true
        tableViewController.navigationController?.navigationBar.largeTitleTextAttributes = TextAttributes.largeTitleAttributes
        tableViewController.navigationController?.view.backgroundColor = UIColor.backgroundColor()
        tableViewController.navigationController?.navigationBar.barTintColor = UIColor.backgroundColor()
        tableViewController.view.backgroundColor = UIColor.backgroundColor()
        
        tableViewController.tableView.register(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableViewController.tableView.backgroundColor = UIColor.backgroundColor()
    }
}
