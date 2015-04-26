//
//  ViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController {
    
    var stories = [Story]()
    let apiClient = HNAPIClient()
    
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Top Stories"
        tableView.backgroundColor = UIColor.backgroundColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.registerClass(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.dataSource = self
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
        
        getTopStories(false)
    }
    
    func refresh() {
        getTopStories(true)
    }
    
    func getTopStories(refresh: Bool) {
        if !refresh { ProgressHUD.showHUDAddedTo(view, animated: true) }
        apiClient.getTopStories(25, offset: 0) { [weak self] (stories, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.refreshControl.endRefreshing()
            if let stories = stories {
                self?.stories = stories
                self?.tableView.reloadData()
            } else {
                UIAlertView(title: "Error getting top stories",
                    message: error?.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK")
            }
        }
    }
    
    func storyForIndexPath(indexPath: NSIndexPath) -> Story {
        return stories[indexPath.item]
    }
    
}

extension StoriesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryCell.identifier, forIndexPath: indexPath) as! StoryCell
        cell.delegate = self
        cell.prepare(storyForIndexPath(indexPath))
        return cell
    }

}

extension StoriesViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(cell: StoryCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let story = storyForIndexPath(indexPath)
        if story.type == .Story,
        let URL = story.URL {
            navigationController?.pushViewController(ReadabilityViewContoller(articleURL:URL), animated: true)
        } else {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(cell: StoryCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let story = storyForIndexPath(indexPath)
        navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
    }
}

