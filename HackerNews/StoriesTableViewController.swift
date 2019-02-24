//
//  StoriesTableViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 2/23/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//


class StoriesTableViewController: UIViewController {
    
    fileprivate var stories = [Story]()
    fileprivate var pinnedStoryIds = [Int]()
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    fileprivate let prototypeCell = StoryCell(frame: CGRect.zero)
    fileprivate var cachedCellHeights = [Int: CGFloat]() // id: cell height
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundColor()
        tableView.backgroundColor = UIColor.backgroundColor()
        tableView.register(StoryCell.self, forCellReuseIdentifier: StoryCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView() // avoid empty cells
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        _ = view.addConstraints(withVisualFormats: [
            "H:|[tableView]|",
            "V:|[tableView]|"], views: [
                "tableView": tableView])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Interface

extension StoriesTableViewController {
    
    func loadStories(_ stories: [Story], appendStories: Bool, scrollToTop: Bool, showHUD: Bool) {
        
        ProgressHUD.hideAllHUDs(for: tableView, animated: true)
        tableView.pullToRefreshView?.stopAnimating()
        
        self.stories = appendStories ? self.stories + stories : stories
        
        tableView.reloadData()
        tableView.infiniteScrollingView?.stopAnimating()
        
        if scrollToTop {
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
        _ = DataSource.fullySync(stories: stories, timeout: 2)
    }
    
    func showHUD() {
        ProgressHUD.showAdded(to: tableView, animated: true)
    }
    
    func addInfiniteScroll(_ action: @escaping () -> Void) {
        tableView.addInfiniteScrolling { () -> Void in
            action()
        }
        tableView.pullToRefreshView.activityIndicatorViewStyle = .white
    }
    
    func addPullToRefresh(_ action: @escaping () -> Void) {
        tableView.addPullToRefresh { () -> Void in
            action()
        }
    }
}

extension StoriesTableViewController {
    
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

// MARK: - Cell heights
extension StoriesTableViewController {
    
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

extension StoriesTableViewController: UITableViewDataSource, UITableViewDelegate {
    
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

extension StoriesTableViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        let navigationController = self.navigationController ?? presentingViewController?.navigationController
        if story.kind == .Link
            && story.URLString != nil {
            navigationController?.pushViewController(ArticleViewController(story: story), animated: true)
        } else {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(_ cell: StoryCell) {
        guard let story = storyForCell(cell) else { return }
        let navigationController = self.navigationController ?? presentingViewController?.navigationController
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

extension StoriesTableViewController {
    
    fileprivate func addPinnedStory(id: Int) {
        SharedState.shared.addPinnedStory(id: id)
    }
    
    fileprivate func removePinnedStory(id: Int) {
        SharedState.shared.removePinnedStory(id: id)
    }
    
    fileprivate func isStoryPinned(id: Int) -> Bool {
        return SharedState.shared.isStoryIdPinned(id: id)
    }
}
