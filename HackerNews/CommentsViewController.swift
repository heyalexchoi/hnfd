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
    
    let story: Story
    var comments = [CommentItem]() // top level comments
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
        
        treeView.layoutMargins = UIEdgeInsetsZero
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
        
        getAllData()
        
    }
    
    func getAllData() {
        story.kids.map { [ weak self] (id) -> Void in
            let commentItem = (CommentItem(id: id))
            self?.comments.append(commentItem)
            self?.apiClient.getComment(id, completion: { (comment, error) -> Void in
                if let comment = comment {
                    commentItem.comment = comment
                    self?.treeView.reloadRowsForItems([commentItem], withRowAnimation: RATreeViewRowAnimationNone)
                    self?.getAllOfCommentItemsDescendants(commentItem)
                }
            })
        }
    }
    
    func getAllOfCommentItemsDescendants(commentItem: CommentItem) {
        if let comment = commentItem.comment {
            comment.kids.map { [weak self] (kidID: Int) -> Void in
                self?.apiClient.getComment(kidID, completion: { (kid, error) -> Void in
                    if let kid = kid {
                        let kidItem = CommentItem(id: kid.id)
                        kidItem.comment = kid
                        commentItem.kids.append(kidItem)
                        self?.getAllOfCommentItemsDescendants(kidItem)
//                        self?.treeView.reloadRowsForItems([kidItem], withRowAnimation: RATreeViewRowAnimationNone)
                    }
                })
            }
        }
    }

}

extension CommentsViewController: RATreeViewDataSource {
    
    func treeView(treeView: RATreeView!, numberOfChildrenOfItem item: AnyObject!) -> Int {
        if let item = item as? CommentItem {
            return item.kids.count
        }
        return comments.count
    }
    
    func treeView(treeView: RATreeView!, cellForItem item: AnyObject!) -> UITableViewCell! {
        let cell = treeView.dequeueReusableCellWithIdentifier(CommentCell.identifier) as! CommentCell
        if let item = item as? CommentItem {
            let level = treeView.levelForCellForItem(item)
            cell.prepare(item, level: level)
        }
        
        return cell
    }
    
    func treeView(treeView: RATreeView!, child index: Int, ofItem item: AnyObject!) -> AnyObject! {
        if let item = item as? CommentItem {
            return item.kids[index]
        }
        return comments[index]
    }
    
}
