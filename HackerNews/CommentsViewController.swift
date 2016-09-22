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
    let treeView = UITableView(frame: CGRect.zero, style: .plain)
    let header: CommentsHeaderView
    let prototypeCell = CommentCell(frame: CGRect.zero)
    var cachedCellHeights = [Int: CGFloat]() // id: cell height
    
    init(story: Story) {
        self.story = story
        header = CommentsHeaderView(story: story)
        super.init(nibName:nil, bundle: nil)
        title = "Comments"
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if story.URL != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(CommentsViewController.actionButtonDidPress))
        }
        
        treeView.separatorInset = UIEdgeInsets.zero
        treeView.separatorColor = UIColor.separatorColor()
        treeView.backgroundColor = UIColor.backgroundColor()
        treeView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        treeView.dataSource = self
        treeView.delegate = self
        treeView.tableFooterView = UIView() // avoid empty cells
        treeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(treeView)
        
        treeView.addPullToRefresh { [weak self] () -> Void in
            self?.getFullStory(true)
        }
        
        header.linkLabel.delegate = self
        
        view.addConstraintsWithVisualFormatStrings([
            "H:|[treeView]|",
            "V:|[treeView]|"], views: [
                "treeView": treeView])
        
        getFullStory(false)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        treeView.tableHeaderView = header
        header.frame = CGRect(origin: CGPoint.zero, size: header.systemLayoutSizeFitting(UILayoutFittingCompressedSize))
    }
    
    func getFullStory(_ refresh: Bool) {
        if !refresh { ProgressHUD.showAdded(to: view, animated: true) }
        DataSource.getStory(story.id, refresh: refresh) { [weak self] (story, error) in
            ProgressHUD.hideAllHUDs(for: self?.view, animated: true)
            self?.treeView.pullToRefreshView.stopAnimating()
            if let error = error {
                ErrorController.showErrorNotification(error)
            } else if let story = story {
                self?.story = story
                self?.treeView.reloadData()
            }
        }
    }
    
    func flatten(_ comments: [Comment]) -> [Comment] {
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
        present(UIActivityViewController(activityItems: items, applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
    
    func goToArticle() {
        // TO DO: manage navigation stack so user can go back and forth between article and comments without making huge chain
        navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
    }
    
    func cachedHeightForRowAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        let comment = flattenedComments[(indexPath as NSIndexPath).row]
        if let cachedHeight = cachedCellHeights[comment.id] {
            return cachedHeight
        }
        let estimatedHeight = prototypeCell.estimatedHeight(treeView.bounds.width, attributedText: comment.attributedText, level: comment.level)
        cachedCellHeights[comment.id] = estimatedHeight
        return estimatedHeight
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flattenedComments.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        let comment = flattenedComments[(indexPath as NSIndexPath).row]
        cell.textView.delegate = self
        cell.prepare(comment, level: comment.level)
        return cell
    }
}

extension CommentsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL == story.URL {
            goToArticle()
        } else {
            presentWebViewController(URL)
        }        
        return false
    }
    
}
