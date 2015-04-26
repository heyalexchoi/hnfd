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
    /*! Wrapper for interfacing between RATreeView and structs, since RATreeView won't take Swift structs,
    and relies on objective c == operator */
    class CommentWrapper: NSObject {
        let comment: Comment
        let children: [CommentWrapper]
        init(comment: Comment) {
            self.comment = comment
            self.children = comment.children.map { CommentWrapper(comment: $0) }
        }
    }
    
    var story: Story
    let apiClient = HNAPIClient()
    let treeView = RATreeView()
    var wrappedComments = [CommentWrapper]()
    
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
                self?.wrappedComments = story.children.map { CommentWrapper(comment: $0) }
                self?.treeView.reloadData()
                self?.wrappedComments.map { (wrappedComment) -> Void in
                    self?.treeView.expandRowForItem(wrappedComment, expandChildren: true, withRowAnimation: RATreeViewRowAnimationNone)
                }
            }
        })
    }
    
}

extension CommentsViewController: RATreeViewDataSource {
    
    func treeView(treeView: RATreeView!, numberOfChildrenOfItem item: AnyObject!) -> Int {
        if item == nil {
            return wrappedComments.count
        } else if let wrappedComment = item as? CommentWrapper {
            return wrappedComment.children.count
        }
        
        println("this isnt supposed to happen. item: \(item)")
        return 0
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
        if item == nil {
            return wrappedComments[index]
        } else if let wrappedComment = item as? CommentWrapper {
            return wrappedComment.children[index]
        }
        println("this isnt supposed to happen. item: \(item)")
        return nil
    }
    
}

extension CommentsViewController: RATreeViewDelegate {
    
    func treeView(treeView: RATreeView!, didSelectRowForItem item: AnyObject!) {
        treeView.deselectRowForItem(item, animated: false)
    }
    
}
