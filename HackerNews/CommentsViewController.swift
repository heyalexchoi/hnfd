//
//  CommentsViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit
import RATreeView

class CommentsViewController: UIViewController {
    
    var story: Story {
        didSet {
            flattenedComments = flatten(story.children)
        }
    }
    
    var flattenedComments = [Comment]()
    let apiClient = HNAPIClient()
    let treeView = UITableView(frame: CGRectZero, style: .Plain)
    
    init(story: Story) {
        self.story = story
        super.init(nibName:nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = story.title
        
        treeView.rowHeight = UITableViewAutomaticDimension
        treeView.estimatedRowHeight = 200
        treeView.separatorInset = UIEdgeInsetsZero
        treeView.separatorColor = UIColor.separatorColor()
        treeView.backgroundColor = UIColor.backgroundColor()
        treeView.registerClass(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        treeView.dataSource = self
        treeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(treeView)
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[treeView]|",
            "V:|[treeView]|"], views: [
                "treeView": treeView])
        
        getFullStory()
        
    }
    
    func getFullStory() {
        ProgressHUD.showHUDAddedTo(view, animated: true)
        apiClient.getStory(story.id, completion: { [weak self] (story, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            if let error = error {
                println(error)
            } else if let story = story {
                self?.story = story
                self?.treeView.reloadData()
            }
            })
    }

    func flatten(comments: [Comment]) -> [Comment] {
        return comments.map { [ weak self] (comment) -> [Comment] in
            if let strong_self = self {
                return [comment] + strong_self.flatten(comment.children)
            }
                return [comment]
            }
            .flatMap { $0 }
    }
    
}

extension CommentsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flattenedComments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CommentCell.identifier, forIndexPath: indexPath) as! CommentCell
        let comment = flattenedComments[indexPath.row]
        cell.prepare(comment, level: comment.level)
        return cell
    }
}
