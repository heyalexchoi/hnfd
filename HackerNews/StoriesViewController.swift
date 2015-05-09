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
    
    var task: NSURLSessionTask?
    var stories = [Story]()
    var storiesType: StoriesType = .Top
    let apiClient = HNAPIClient()
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    let limit = 25
    var offset = 0
    
    let titleView = StoriesTitleView()
    let menu = REMenu()
    
    override var title: String? {
        didSet {
            titleView.title = title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenu()

        navigationItem.titleView = titleView
        titleView.tapHandler = { [weak self] () -> Void in
            self?.toggleMenu()
        }
        
        tableView.backgroundColor = UIColor.backgroundColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.registerClass(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.dataSource = self
        tableView.tableFooterView = UIView() // avoid empty cells
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        
        tableView.addPullToRefreshWithActionHandler { [weak self] () -> Void in
            self?.getStories(true)
        }
        tableView.pullToRefreshView.activityIndicatorViewStyle = .White
        
        tableView.addInfiniteScrollingWithActionHandler { [weak self] () -> Void in
            self?.getStories(false)
        }
        tableView.infiniteScrollingView.activityIndicatorViewStyle = .White
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
        
        getStories(false)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func refresh() {
        getStories(true)
    }
    
    func getStories(refresh: Bool) {
        if stories.count < 1 { ProgressHUD.showHUDAddedTo(view, animated: true) }
        if refresh { offset = 0 }
        task?.cancel()
        task = apiClient.getStories(storiesType, limit:limit, offset: offset) { [weak self] (stories, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.tableView.pullToRefreshView.stopAnimating()
            self?.tableView.infiniteScrollingView.stopAnimating()
            self?.title = self?.storiesType.title
            if let stories = stories {
                self?.stories = refresh ? stories : self!.stories + stories
                self?.offset = self!.offset + self!.limit
                self?.tableView.reloadData()
                /*
                let data = NSKeyedArchiver.archivedDataWithRootObject(stories)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: "stories")
                
                if let data = NSUserDefaults.standardUserDefaults().objectForKey("stories") as? NSData {
                if let loadedStories = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Story] {
                self?.stories = loadedStories
                self?.tableView.reloadData()
                }
                }
                */
                
            } else {
                UIAlertView(title: "Error getting top stories",
                    message: error?.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK")
            }
            }.task
    }
    
    func storyForIndexPath(indexPath: NSIndexPath) -> Story {
        return stories[indexPath.item]
    }
    
    // MARK: - Menu
    
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
        getStories(true)
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

extension StoriesViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
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
        let indexPath = tableView.indexPathForCell(cell)!
        let story = storyForIndexPath(indexPath)
        if story.type == .Story
            && story.URL != nil
            && !story.URL!.absoluteString!.isEmpty {
                navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
        } else {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(cell: StoryCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let story = storyForIndexPath(indexPath)
        navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
    }
}
