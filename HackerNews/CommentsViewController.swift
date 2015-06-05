//
//  CommentsViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit


class CommentsViewController: UIViewController {
    
    var story: Story {
        didSet {
            flattenedComments = flatten(story.children)
        }
    }
    
    var flattenedComments = [Comment]()
    let cache = Cache.sharedCache()
    let treeView = UITableView(frame: CGRectZero, style: .Plain)
    let header: CommentsHeaderView
    
    init(story: Story) {
        self.story = story
        header = CommentsHeaderView(story: story)
        super.init(nibName:nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let URL = story.URL {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonDidPress")
        }
        
        treeView.rowHeight = UITableViewAutomaticDimension
        treeView.estimatedRowHeight = 200
        treeView.separatorInset = UIEdgeInsetsZero
        treeView.separatorColor = UIColor.separatorColor()
        treeView.backgroundColor = UIColor.backgroundColor()
        treeView.registerClass(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        treeView.dataSource = self
        treeView.tableFooterView = UIView() // avoid empty cells
        treeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(treeView)
        
        treeView.addPullToRefreshWithActionHandler { [weak self] () -> Void in
            self?.getFullStory(true)
        }
        
        header.linkLabel.delegate = self
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[treeView]|",
            "V:|[treeView]|"], views: [
                "treeView": treeView])
        
        getFullStory(false)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        treeView.tableHeaderView = header
        header.frame = CGRect(origin: CGPointZero, size: header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize))
    }
    
    func getFullStory(refresh: Bool) {
        if !refresh { ProgressHUD.showHUDAddedTo(view, animated: true) }
        cache.fullStoryForStory(story, preference: refresh ? .FetchRemoteDataAndUpdateCache : .ReturnCacheDataElseLoad) { [weak self] (story, error) -> Void in
            ProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            self?.treeView.pullToRefreshView.stopAnimating()
            if let error = error {
                UIAlertView(title: "Comments Error",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            } else if let story = story {
                self?.story = story
                self?.treeView.reloadData()
            }
        }
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
    
    func actionButtonDidPress() {
        if let URL = story.URL {
            presentViewController(UIActivityViewController(activityItems: [URL], applicationActivities: nil), animated: true, completion: nil)
        }
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
        cell.textView.delegate = self
        cell.prepare(comment, level: comment.level)
        return cell
    }
}

extension CommentsViewController: UITextViewDelegate {

    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        presentViewController(UINavigationController(rootViewController: WebViewController(url: URL)), animated: true, completion: nil)
        return false
    }
    
}
