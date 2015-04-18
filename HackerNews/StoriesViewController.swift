//
//  ViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController {
    
    var stories = [StoryItem]()
    let apiClient = HNAPIClient()
    
    let collectionView: UICollectionView
    let layout: UICollectionViewFlowLayout
    
    init() {
        layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        super.init(nibName:nil, bundle: nil)
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 100)
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 0.5
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Top Stories"
        
        collectionView.backgroundColor = UIColor.separatorColor()
        collectionView.registerClass(StoryCell.self, forCellWithReuseIdentifier: StoryCell.identifier)
        collectionView.dataSource = self
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(collectionView)
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[collectionView]|",
            "V:|[collectionView]|"], views: [
                "collectionView": collectionView])
        
        getTopStories()
    }
    
    func getTopStories() {
        ProgressHUD.showHUDAddedTo(view, animated: true)
        apiClient.getTopStories { [weak self] (stories, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            if let stories = stories {
                self?.stories += stories
                self?.collectionView.reloadData()
            } else {
                UIAlertView(title: "Error getting top stories",
                    message: error?.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK")
            }
        }
    }
    
    func storyItemForIndexPath(indexPath: NSIndexPath) -> StoryItem {
        return stories[indexPath.item]
    }
    
}

extension StoriesViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryCell.identifier, forIndexPath: indexPath) as!   StoryCell
        cell.delegate = self
        cell.prepare(storyItemForIndexPath(indexPath))
        
        return cell
    }
}

extension StoriesViewController: StoryCellDelegate {

    func cellDidSelectStoryArticle(cell: StoryCell, story: Story) {
        navigationController?.pushViewController(ReadabilityViewContoller(articleURL: story.URL), animated: true)
    }
    
    func cellDidSelectStoryComments(cell: StoryCell, story: Story) {
        navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
    }
}

