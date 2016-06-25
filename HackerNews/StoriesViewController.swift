//
//  ViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit
import REMenu

class StoriesViewController: UIViewController {
    
    var stories = [Story]()
    var storiesType: StoriesType = .Top

    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    let prototypeCell = StoryCell(frame: CGRectZero)
    var cachedCellHeights = [Int: CGFloat]() // id: cell height
    
    let titleView = StoriesTitleView()
    let menu = REMenu()
    
    override var title: String? {
        didSet {
            titleView.title = title
        }
    }

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenu()
        
        navigationItem.titleView = titleView
        titleView.tapHandler = { [weak self] () -> Void in
            self?.toggleMenu()
        }
        
        tableView.backgroundColor = UIColor.backgroundColor()
        tableView.registerClass(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // avoid empty cells
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.addPullToRefreshWithActionHandler { [weak self] () -> Void in
            self?.getStories(refresh: true)
        }
        tableView.pullToRefreshView.activityIndicatorViewStyle = .White
        
        view.addConstraintsWithVisualFormatStrings([
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
        
        getStories(refresh: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

// MARK: - Stories

extension StoriesViewController {
    
    func getStories(refresh refresh: Bool = false, scrollToTop: Bool = false) {
        
        if !refresh {
            ProgressHUD.showHUDAddedTo(view, animated: true)
        }

        DataSource.getStories(storiesType, refresh: refresh) { [weak self] (stories, error) -> Void in
            
            ProgressHUD.hideAllHUDsForView(self?.view, animated: true)
            self?.tableView.pullToRefreshView.stopAnimating()
            
            guard let stories = stories else {
                ErrorController.showErrorNotification(error)
                return
            }
            
            if refresh {
                self?.stories = [Story]()
            }
            
            self?.title = self?.storiesType.title
            self?.stories += stories
            
            self?.tableView.reloadData()
            
            if scrollToTop {
                self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
        }
    }
    
    func storyForIndexPath(indexPath: NSIndexPath) -> Story {
        return stories[indexPath.item]
    }
    
    func indexPathForStory(story: Story) -> NSIndexPath {
        return NSIndexPath(forRow: stories.indexOf(story)!, inSection: 0)
    }
    
    func storyForCell(cell: StoryCell) -> Story {
        let indexPath = tableView.indexPathForCell(cell)!
        return storyForIndexPath(indexPath)
    }

}

// MARK: - Menu

extension StoriesViewController {
    
    func setupMenu() {
        menu.items = StoriesType.allValues.map { (type) -> REMenuItem in
            return REMenuItem(title: type.title, image: nil, highlightedImage: nil, action: { [weak self] (_) -> Void in
                self?.menuDidFinishSelection(type)
                })
        }
    }
    
    func menuDidFinishSelection(type: StoriesType) {
        storiesType = type
        title = type.title
        getStories(refresh: true, scrollToTop: true)
        menu.close()
    }
    
    func toggleMenu() {
        if menu.isOpen {
            menu.close()
        } else {
            menu.showInView(view)
        }
    }
}

// MARK: - Cell heights
extension StoriesViewController {
    
    func cachedHeightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        let story = storyForIndexPath(indexPath)
        if let cachedHeight = cachedCellHeights[story.id] {
            return cachedHeight
        }
        let estimatedHeight = prototypeCell.estimatedHeight(tableView.bounds.width, title: storyForIndexPath(indexPath).title)
        cachedCellHeights[story.id] = estimatedHeight
        return estimatedHeight
    }
    
}

extension StoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryCell.identifier, forIndexPath: indexPath) as! StoryCell
        cell.delegate = self
        cell.prepare(storyForIndexPath(indexPath))
        return cell
    }
}

extension StoriesViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(cell: StoryCell) {
        let story = storyForCell(cell)
        if story.type == .Story
            && story.URLString != nil {
                navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
        } else {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(cell: StoryCell) {
        navigationController?.pushViewController(CommentsViewController(story: storyForCell(cell)), animated: true)
    }
    
    func cellDidSwipeLeft(cell: StoryCell) {
        // TO DO: unpin
        tableView.reloadRowsAtIndexPaths([indexPathForStory(storyForCell(cell))], withRowAnimation: .Left)
    }
    
    func cellDidSwipeRight(cell: StoryCell) {
       // TO DO: pin
        tableView.reloadRowsAtIndexPaths([indexPathForStory(storyForCell(cell))], withRowAnimation: .Right)
    }
}
