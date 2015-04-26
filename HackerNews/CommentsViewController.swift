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
    
    var story: Story

    let apiClient = HNAPIClient()
    
    let treeView = RATreeView()
    
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
        
        treeView.expandsChildRowsWhenRowExpands = true
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
    
}

extension CommentsViewController: RATreeViewDataSource {
    /*! Wrapper for interfacing between RATreeView and structs, since RATreeView won't take Swift structs */
    class CommentWrapper: NSObject {
        let comment: Comment
        init(comment: Comment) {
            self.comment = comment
        }
    }
    
    func treeView(treeView: RATreeView!, numberOfChildrenOfItem item: AnyObject!) -> Int {
        if let comment = item as? Comment {
            return comment.children.count
        }
        return story.children.count
    }
    
    func treeView(treeView: RATreeView!, cellForItem item: AnyObject!) -> UITableViewCell! {
        let cell = treeView.dequeueReusableCellWithIdentifier(CommentCell.identifier) as! CommentCell
        if let wrappedComment = item as? CommentWrapper {
            let level = treeView.levelForCellForItem(wrappedComment)
            cell.prepare(wrappedComment.comment, level: level)
        }
        
        return cell
    }
    
    func treeView(treeView: RATreeView!, child index: Int, ofItem item: AnyObject!) -> AnyObject! {
        if let wrappedComment = item as? CommentWrapper {
            let comment = wrappedComment.comment.children[index]
            let wrapped = CommentWrapper(comment: comment)
            return wrapped
        }
        let comment = story.children[index]
        return CommentWrapper(comment: comment)
    }
    
}
