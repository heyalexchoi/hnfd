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
    var commentsAllLoaded: Bool {
        return comments.filter { $0.comment == nil }.count > 0
    }
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
        
        getComments()
        
    }
    
    func getComments() {
        comments = story.kids.map { self.commentItemForID($0) }
        treeView.reloadData()
    }
    
    func commentItemForID(id: Int) -> CommentItem {
        let commentItem = CommentItem(id: id)
        apiClient.getComment(id, completion: { [weak self] (comment, error) -> Void in
            if let comment = comment,
                strong_self = self {
                    commentItem.comment = comment
                    commentItem.kids = comment.kids.map { strong_self.commentItemForID($0) }
                    if strong_self.commentsAllLoaded { strong_self.treeView.reloadData() }
            }
            })
        return commentItem
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
