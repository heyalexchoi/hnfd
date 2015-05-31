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
    let cache = Cache.sharedCache()
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    let limit = 25
    var offset = 0
    
    let titleView = StoriesTitleView()
    let menu = REMenu()
    
    var savedStories: [Story] = {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(StoriesType.Saved.rawValue) as? NSData {
            if var loadedStories = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Story] {
                loadedStories = NSOrderedSet(array: loadedStories).array as! [Story]
                return loadedStories
            }
        }
        return [Story]()
        }()
    
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
    
    func refresh() {
        getStories(true)
    }
    
    func getStories(refresh: Bool) {
        if stories.count < 1 { ProgressHUD.showHUDAddedTo(view, animated: true) }
        if refresh { offset = 0 }
        
        if storiesType == .Saved {
            stories = savedStories
            tableView.reloadData()
            ProgressHUD.hideHUDForView(view, animated: true)
            tableView.pullToRefreshView.stopAnimating()
            tableView.infiniteScrollingView.stopAnimating()
            return
        }
        
        task?.cancel()
        task = apiClient.getStories(storiesType, limit:limit, offset: offset) { [weak self] (stories, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.tableView.pullToRefreshView.stopAnimating()
            self?.tableView.infiniteScrollingView.stopAnimating()
            self?.title = self?.storiesType.title
            if let stories = stories,
                strong_self = self {
                    stories.map { (story) -> Void in
                        if let index = find(strong_self.savedStories, story) {
                            story.saved = true
                            strong_self.savedStories[index] = story
                            strong_self.fetchAffiliatedStoryData(story)
                        }
                    }
                    self?.stories = refresh ? stories : self!.stories + stories
                    self?.offset = self!.offset + self!.limit
                    self?.tableView.reloadData()
            } else {
                UIAlertView(title: "Stories Error",
                    message: error?.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            }.task
    }
    
    func storyForIndexPath(indexPath: NSIndexPath) -> Story {
        return stories[indexPath.item]
    }
    
    func indexPathForStory(story: Story) -> NSIndexPath {
        return NSIndexPath(forRow: find(stories, story)!, inSection: 0)
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
    
    // MARK: - SAVED STORIES
    
    func saveStory(story: Story) {
        if story.saved { return }
        story.saved = true
        savedStories.insert(story, atIndex: 0)
        syncSavedStories()
        tableView.reloadRowsAtIndexPaths([indexPathForStory(story)], withRowAnimation: .Right)
        fetchAffiliatedStoryData(story)
    }
    
    func unsaveStory(story: Story) {
        if !story.saved { return }
        tableView.beginUpdates()
        let indexPath = indexPathForStory(story)
        story.saved = false
        savedStories = savedStories.filter { $0 != story }
        syncSavedStories()
        if storiesType == .Saved {
            stories = savedStories
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        } else {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
        tableView.endUpdates()
    }
    
    func syncSavedStories() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(savedStories)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: StoriesType.Saved.rawValue)
    }
    
    func fetchAffiliatedStoryData(story: Story) {
        cache.articleForStory(story, completion: nil)
        cache.fullStoryForStory(story, preference: .FetchRemoteDataAndUpdateCache, completion: nil)
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
    
    func storyForCell(cell: StoryCell) -> Story {
        let indexPath = tableView.indexPathForCell(cell)!
        return storyForIndexPath(indexPath)
    }
    
    func cellDidSelectStoryArticle(cell: StoryCell) {
        let story = storyForCell(cell)
        if story.type == .Story
            && story.URL != nil
            && !story.URL!.absoluteString!.isEmpty {
                navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
        } else {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(cell: StoryCell) {
        navigationController?.pushViewController(CommentsViewController(story: storyForCell(cell)), animated: true)
    }
    
    func cellDidSwipeLeft(cell: StoryCell) {
        unsaveStory(storyForCell(cell))
    }
    
    func cellDidSwipeRight(cell: StoryCell) {
        saveStory(storyForCell(cell))
    }
}
