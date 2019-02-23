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
    
    fileprivate var stories = [Story]()
    fileprivate var pinnedStoryIds = [Int]()
    fileprivate var storiesType: StoriesType = .Top

    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    fileprivate let prototypeCell = StoryCell(frame: CGRect.zero)
    fileprivate var cachedCellHeights = [Int: CGFloat]() // id: cell height
    
    fileprivate let titleView = StoriesTitleView()
    fileprivate let menu = REMenu()
    
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
            self?.getStories()
        }
        tableView.pullToRefreshView.activityIndicatorViewStyle = .white
        
        _ = view.addConstraints(withVisualFormats: [
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
        
        getStories(showHUD: true)
        loadPinnedStories()
        tableView.addInfiniteScroll { (tableView) -> Void in
            // update table view
            
            // finish infinite scroll animation
            tableView.finishInfiniteScroll()
        }
    }
}

// MARK: - Stories

extension StoriesViewController {
    
    fileprivate func loadStories(_ stories: [Story], scrollToTop: Bool, showHUD: Bool) {
        
        ProgressHUD.hideAllHUDs(for: tableView, animated: true)
        tableView.pullToRefreshView.stopAnimating()

        title = storiesType.title
        self.stories = stories
        
        tableView.reloadData()
        
        if scrollToTop {
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
        _ = DataSource.fullySync(stories: stories, timeout: 2)
    }
    
    fileprivate func getStories(scrollToTop: Bool = false, showHUD: Bool = false) {
        if showHUD {
            ProgressHUD.showAdded(to: tableView, animated: true)
        }
        // // wa wa wee waa
        let limit = 25
        let offset = 0
        DataSource.getStories(withType: storiesType, limit: limit, offset: offset)
        .then { (stories) -> Void in
            self.loadStories(stories, scrollToTop: scrollToTop, showHUD: showHUD)
        }
        .catch { (error) in
            ErrorController.showErrorNotification(error)
        }
    }
    
    fileprivate func story(forArticle article: MercuryArticle) -> Story? {
        return stories.first(where: { (story) -> Bool in
            return story.URLString == article.URLString
        })
    }
    
    fileprivate func reload(article: MercuryArticle) {
        if let story = story(forArticle: article) {
            reload(story: story)
        }
    }
    
    fileprivate func reload(story: Story) {
        if let indexPath = indexPath(for: story) {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    fileprivate func storyForIndexPath(_ indexPath: IndexPath) -> Story {
        return stories[indexPath.item]        
    }
    
    fileprivate func storyForCell(_ cell: StoryCell) -> Story? {
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        return storyForIndexPath(indexPath)
    }
    
    fileprivate func indexPath(for story: Story) -> IndexPath? {
        guard let index = stories.index(where: { $0.id == story.id }) else {
            return nil
        }
        
        return IndexPath(item: index, section: 0)
    }
}

// MARK: - Menu

extension StoriesViewController {
    
    fileprivate func setupMenu() {
        menu.items = StoriesType.allValues.map { (type) -> REMenuItem in
            return REMenuItem(title: type.title, image: nil, highlightedImage: nil, action: { [weak self] (_) -> Void in
                self?.menuDidFinishSelection(type)
                })
        }
    }
    
    fileprivate func menuDidFinishSelection(_ type: StoriesType) {
        storiesType = type
        title = type.title
        getStories(scrollToTop: true, showHUD: true)
        menu.close()
    }
    
    fileprivate func toggleMenu() {
        if menu.isOpen {
            menu.close()
        } else {
            menu.show(in: view)
        }
    }
}

// MARK: - Cell heights
extension StoriesViewController {
    
    fileprivate func cachedHeightForRowAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        let story = storyForIndexPath(indexPath)
        if let cachedHeight = cachedCellHeights[story.id] {
            return cachedHeight
        }
        let estimatedHeight = prototypeCell.estimateHeight(story: story, isPinned: isStoryPinned(id: story.id), width: tableView.bounds.width)
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
        let story = storyForIndexPath(indexPath)
        cell.prepare(story: story, isPinned: isStoryPinned(id: story.id), width: tableView.bounds.width)
        return cell
    }
}

extension StoriesViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        if story.kind == .Story
            && story.URLString != nil {
                navigationController?.pushViewController(ArticleViewController(story: story), animated: true)
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
        removePinnedStory(id: story.id)
        guard let indexPath = indexPath(for: story) else { return }
        tableView.reloadRows(at: [indexPath], with: .left)
    }
    
    func cellDidSwipeRight(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        addPinnedStory(id: story.id)
        guard let indexPath = indexPath(for: story) else { return }
        tableView.reloadRows(at: [indexPath], with: .right)
    }
}

extension StoriesViewController {
    
    fileprivate func loadPinnedStories() {
        DataSource.getPinnedStoryIds { [weak self] (ids) in
            self?.pinnedStoryIds = ids
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func addPinnedStory(id: Int) {
        if let pinnedIdIndex = index(forPinnedStoryId: id) {
            pinnedStoryIds.remove(at: pinnedIdIndex)
        }
        pinnedStoryIds.append(id)
        DataSource.addPinnedStory(id: id)
    }

    fileprivate func removePinnedStory(id: Int) {
        if let pinnedIdIndex = index(forPinnedStoryId: id) {
            pinnedStoryIds.remove(at: pinnedIdIndex)
        }
        DataSource.removePinnedStory(id: id)
    }
    
    fileprivate func isStoryPinned(id: Int) -> Bool {
        return pinnedStoryIds.contains(id)
    }
    
    fileprivate func index(forPinnedStoryId id: Int) -> Int? {
        return pinnedStoryIds.index(where: { $0 == id })
    }
}
