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

    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    let prototypeCell = StoryCell(frame: CGRect.zero)
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
        tableView.register(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // avoid empty cells
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.addPullToRefresh { [weak self] () -> Void in
            self?.getStories(refresh: true)
        }
        tableView.pullToRefreshView.activityIndicatorViewStyle = .white
        
        _ = view.addConstraints(withVisualFormats: [
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
        
        getStories(refresh: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }    
}

// MARK: - Stories

extension StoriesViewController {
    
    func loadStories(result: Result<[Story]>, refresh: Bool, scrollToTop: Bool, showHUD: Bool) {
        
        ProgressHUD.hideAllHUDs(for: tableView, animated: true)
        tableView.pullToRefreshView.stopAnimating()
        
        guard let stories = result.value else {
            ErrorController.showErrorNotification(result.error)
            return
        }
        
        if refresh {
            self.stories = [Story]()
        }
        
        title = storiesType.title
        self.stories += stories
        
        tableView.reloadData()
        
        if scrollToTop {
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
        for story in stories {
            DataSource.fullySync(story: story, storyHandler: { [weak self] (storyResult) in
                if let story = storyResult.value {
                    self?.reload(story: story)
                }
                }, articleHandler: { [weak self] (articleResult) in
                    if let article = articleResult.value {
                        self?.reload(article: article)
                    }
            })
        }
    }
    
    func getStories(refresh: Bool = false, scrollToTop: Bool = false, showHUD: Bool = false) {
        if showHUD {
            ProgressHUD.showAdded(to: tableView, animated: true)
        }
        guard storiesType != .Pinned else {
            DataSource.getPinnedStories(limit: 0, offset: 0, refresh: refresh) { [weak self] (result: Result<[Story]>) -> Void in
                self?.loadStories(result: result, refresh: refresh, scrollToTop: scrollToTop, showHUD: showHUD)
            }
            return
        }
        DataSource.getStories(storiesType, refresh: refresh) { [weak self] (result: Result<[Story]>) -> Void in
            self?.loadStories(result: result, refresh: refresh, scrollToTop: scrollToTop, showHUD: showHUD)
        }
    }
    
    func story(forArticle article: ReadabilityArticle) -> Story? {
        return stories.first(where: { (story) -> Bool in
            return story.URLString == article.URLString
        })
    }
    
    func reload(article: ReadabilityArticle) {
        if let story = story(forArticle: article) {
            reload(story: story)
        }
    }
    
    func reload(story: Story) {
        if let indexPath = indexPath(for: story) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func storyForIndexPath(_ indexPath: IndexPath) -> Story {
        return stories[indexPath.item]        
    }
    
    func storyForCell(_ cell: StoryCell) -> Story? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        return storyForIndexPath(indexPath)
    }
    
    func indexPath(for story: Story) -> IndexPath? {
        guard let index = stories.index(where: { $0.id == story.id }) else {
            return nil
        }
        
        return IndexPath(item: index, section: 0)
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
    
    func menuDidFinishSelection(_ type: StoriesType) {
        storiesType = type
        title = type.title
        getStories(refresh: true, scrollToTop: true, showHUD: true)
        menu.close()
    }
    
    func toggleMenu() {
        if menu.isOpen {
            menu.close()
        } else {
            menu.show(in: view)
        }
    }
}

// MARK: - Cell heights
extension StoriesViewController {
    
    func cachedHeightForRowAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        let story = storyForIndexPath(indexPath)
        if let cachedHeight = cachedCellHeights[story.id] {
            return cachedHeight
        }
        let estimatedHeight = prototypeCell.estimateHeight(story: story , width: tableView.bounds.width)
        cachedCellHeights[story.id] = estimatedHeight
        return estimatedHeight
    }
    
}

extension StoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryCell.identifier, for: indexPath) as! StoryCell
        cell.delegate = self
        cell.prepare(story: storyForIndexPath(indexPath), width: tableView.bounds.width)
        return cell
    }
}

extension StoriesViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        if story.kind == .Story
            && story.URLString != nil {
                navigationController?.pushViewController(ReadabilityViewContoller(story: story), animated: true)
        } else {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
    }
    
    func cellDidSwipeLeft(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        DataSource.removePinnedStory(id: story.id)
        guard let indexPath = indexPath(for: story) else { return }
        tableView.reloadRows(at: [indexPath], with: .left)
    }
    
    func cellDidSwipeRight(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        DataSource.addPinnedStory(id: story.id)
        guard let indexPath = indexPath(for: story) else { return }
        tableView.reloadRows(at: [indexPath], with: .right)
    }
}
