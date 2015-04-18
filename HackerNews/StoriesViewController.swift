//
//  ViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController {
    
    var stories = [StoryItem]()
    let apiClient = HNAPIClient()
    
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
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
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
        
        getTopStories()
    }
    
    func getTopStories() {
        ProgressHUD.showHUDAddedTo(view, animated: true)
        apiClient.getTopStories { [weak self] (stories, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            if let stories = stories {
                self?.stories += stories
                self?.tableView.reloadData()
            } else {
                UIAlertView(title: "Error getting top stories",
                    message: error?.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK")
            }
        }
    }
    
    func storyItemForIndexPath(indexPath: NSIndexPath) -> StoryItem {
        return stories[indexPath.item]
    }
    
    func storyForIndexPath(indexPath: NSIndexPath) -> Story? {
        return storyItemForIndexPath(indexPath).story
    }
    
    func setStoryForIndexPath(story: Story, indexPath: NSIndexPath) {
        stories[indexPath.item].story = story
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
        let storyItem = storyItemForIndexPath(indexPath)
        
        if let story = storyItem.story {
            cell.prepare(story)
        } else {
            apiClient.getStory(storyItem.id, completion: { [weak self] (story, error) -> Void in
                if let story = story {
                    self?.setStoryForIndexPath(story, indexPath: indexPath)
                    self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
                })
        }
        
        return cell
    }

}

extension StoriesViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(cell: StoryCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        if let story = storyItemForIndexPath(indexPath).story {
            if story.type == .Story && !story.URL.absoluteString!.isEmpty {
                navigationController?.pushViewController(ReadabilityViewContoller(articleURL:story.URL), animated: true)
            } else {
                navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
            }
        }
    }
    
    func cellDidSelectStoryComments(cell: StoryCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        if let story = storyItemForIndexPath(indexPath).story {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
}

