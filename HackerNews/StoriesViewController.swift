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
    
    let limit = 25
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Top Stories"
        tableView.backgroundColor = UIColor.backgroundColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.registerClass(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // avoid empty cells
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        
        tableView.addPullToRefreshWithActionHandler { [weak self] () -> Void in
            self?.getTopStories(true)
        }
        tableView.pullToRefreshView.activityIndicatorViewStyle = .White
        
        tableView.addInfiniteScrollingWithActionHandler { [weak self] () -> Void in
            self?.getTopStories(false)
        }
        tableView.infiniteScrollingView.activityIndicatorViewStyle = .White
        
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
        if stories.count < 1 { ProgressHUD.showHUDAddedTo(view, animated: true) }
        if refresh { offset = 0 }
        apiClient.getTopStories(limit, offset: offset) { [weak self] (stories, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.tableView.pullToRefreshView.stopAnimating()
            self?.tableView.infiniteScrollingView.stopAnimating()
            if let stories = stories {
                self?.stories = refresh ? stories : self!.stories + stories
                self?.offset = self!.offset + self!.limit
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
        if story.type == .Story
        && story.URL != nil {
            navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
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

