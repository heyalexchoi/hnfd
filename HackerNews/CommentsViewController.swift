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
    let prototypeCell = CommentCell(frame: CGRectZero)
    var cachedCellHeights = [Int: CGFloat]() // id: cell height
    
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
        
        treeView.separatorInset = UIEdgeInsetsZero
        treeView.separatorColor = UIColor.separatorColor()
        treeView.backgroundColor = UIColor.backgroundColor()
        treeView.registerClass(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        treeView.dataSource = self
        treeView.delegate = self
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
        var items: [AnyObject] = [story]
        if let URL = story.URL {
            items.append(URL)
        }
        let storyActivity = StoryActivity()
        presentViewController(UIActivityViewController(activityItems: items, applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
    
    func goToArticle() {
        // TO DO: manage navigation stack so user can go back and forth between article and comments without making huge chain
        navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
    }
    
    func cachedHeightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        let comment = flattenedComments[indexPath.row]
        if let cachedHeight = cachedCellHeights[comment.id] {
            return cachedHeight
        }
        let estimatedHeight = prototypeCell.estimatedHeight(treeView.bounds.width, attributedText: comment.attributedText, level: comment.level)
        cachedCellHeights[comment.id] = estimatedHeight
        return estimatedHeight
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flattenedComments.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
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
        if URL == story.URL {
            goToArticle()
        } else {
            presentViewController(UINavigationController(rootViewController: WebViewController(url: URL)), animated: true, completion: nil)
        }        
        return false
    }
    
}
