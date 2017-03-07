//
//  CommentsViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit

struct CommentTreeDataSource {
    
    // MARK: - INTERFACE
    
    var commentsCount: Int {
        return flattenedTree.count
    }

    init(comments: [Comment] = []) {
        tree = comments.map { CommentNode(comment: $0) }
        flattenedTree = CommentTreeDataSource.flatten(tree: tree)
    }

    func comment(atIndex index: Int) -> Comment {
        return flattenedTree[index].comment
    }
    
    func isCommentExpanded(atIndex index: Int) -> Bool {
        return flattenedTree[index].isExpanded
    }
    
    mutating func setCommentIsExpanded(_ isExpanded: Bool, atIndex index: Int) {
        guard let treeItem = treeItemForFlattenedIndex(index: index) else {
            return
        }
        treeItem.isExpanded = isExpanded
        flattenedTree = flatten(tree: tree)
    }
    
    mutating func expandComment(atIndex index: Int) {
        setCommentIsExpanded(true, atIndex: index)
    }
    
    mutating func collapseComment(atIndex index: Int) {
        setCommentIsExpanded(false, atIndex: index)
    }
    
    // MARK: - PRIVATE
    
    private class CommentNode {
        
        var isExpanded = true
        let children: [CommentNode]
        let descendantIds: Set<Int>
        
        let comment: Comment
        
        init(comment: Comment) {
            self.comment = comment
            self.children = comment.children.map { CommentNode(comment: $0) }
            
            var descendantIds = Set<Int>()
            for child in children {
                descendantIds.insert(child.comment.id)
                descendantIds = descendantIds.union(child.descendantIds)
            }
            
            self.descendantIds = descendantIds
        }
        
        func hasDescendant(withId id: Int) -> Bool {
            return descendantIds.contains(id)
        }
        
        static func findRecursively(nodes: [CommentNode], id: Int) -> CommentNode? {
            for node in nodes {
                if node.comment.id == id {
                    return node
                }
                if node.hasDescendant(withId: id) {
                    return findRecursively(nodes: node.children, id: id)
                }
            }
            return nil
        }
    }
    
    private let tree: [CommentNode]
    private var flattenedTree: [CommentNode] // flattened representation of tree, excluding all descendants of any collapsed nodes

    private static func flatten(tree: [CommentNode]) -> [CommentNode] {
        return tree.map {(comment) -> [CommentNode] in
            guard comment.isExpanded else {
                return [comment]
            }
            return [comment] + flatten(tree: comment.children)
            }.flatMap { $0 }
    }
    
    private func flatten(tree: [CommentNode]) -> [CommentNode] {
        return CommentTreeDataSource.flatten(tree: tree)
    }
    
    private func treeItemForFlattenedIndex(index: Int) -> CommentNode? {
        let commentId = flattenedTree[index].comment.id
        return CommentNode.findRecursively(nodes: tree, id: commentId)
    }
}

class CommentsViewController: UIViewController {
    
    var story: Story {
        didSet {
            commentTreeDataSource = CommentTreeDataSource(comments: story.children)
        }
    }
    
    var commentTreeDataSource = CommentTreeDataSource()
    let treeView = UITableView(frame: CGRect.zero, style: .plain)
    let header: CommentsHeaderView
    let prototypeCell = CommentCell(frame: CGRect.zero)
    var cachedCellHeights = [String: CGFloat]() // key: height
    
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
        
        _ = view.addConstraints(withVisualFormats: [
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
        DataSource.getStory(story.id, refresh: refresh) { [weak self] (result) in
            ProgressHUD.hideAllHUDs(for: self?.view, animated: true)
            self?.treeView.pullToRefreshView.stopAnimating()
            guard let story = result.value else {
                ErrorController.showErrorNotification(result.error)
                return
            }
            self?.story = story
            self?.treeView.reloadData()
        }
    }

    func actionButtonDidPress() {
        var items: [Any] = [story]
        if let URL = story.URL {
            items.append(URL)
        }
        let storyActivity = StoryActivity()
        present(UIActivityViewController(activityItems: items, applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
    
    func goToArticle() {
        // TO DO: manage navigation stack so user can go back and forth between article and comments without making huge chain
        navigationController?.pushViewController(ArticleViewController(story: story), animated: true)
    }
    
    func cachedHeightForRowAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        guard let comment = comment(forIndexPath: indexPath) else {
            return 0
        }
        let isExpanded = isCommentExpanded(forIndexPath: indexPath)
        let cacheKey = "\(comment.id)_\(isExpanded)"
        
        if let cachedHeight = cachedCellHeights[cacheKey] {
            return cachedHeight
        }
        
        let estimatedHeight = prototypeCell.estimateHeight(attributedBodyText: comment.attributedText,
                                                           byText: comment.by,
                                                           date: comment.date,
                                                           level: comment.level,
                                                           isExpanded: isExpanded,
                                                           width: treeView.bounds.width)
        
        cachedCellHeights[cacheKey] = estimatedHeight
        return estimatedHeight
    }
    
    fileprivate func comment(forIndexPath indexPath: IndexPath) -> Comment? {
        return commentTreeDataSource.comment(atIndex: indexPath.row)
    }
    
    fileprivate func isCommentExpanded(forIndexPath indexPath: IndexPath) -> Bool {
        return commentTreeDataSource.isCommentExpanded(atIndex: indexPath.row)
    }
    
    fileprivate func setCommentIsExpanded(_ isExpanded: Bool, forIndexPath indexPath: IndexPath) {
        commentTreeDataSource.setCommentIsExpanded(isExpanded, atIndex: indexPath.row)
    }
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentTreeDataSource.commentsCount
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
        guard let comment = comment(forIndexPath: indexPath) else {
            return cell
        }
        
        cell.prepare(attributedBodyText: comment.attributedText,
                     byText: comment.by,
                     date: comment.date,
                     level: comment.level,
                     width: treeView.bounds.width,
                     isExpanded: isCommentExpanded(forIndexPath: indexPath),
                     textViewDelegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isExpanded = isCommentExpanded(forIndexPath: indexPath)
        setCommentIsExpanded(!isExpanded, forIndexPath: indexPath)
        tableView.reloadData()
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
