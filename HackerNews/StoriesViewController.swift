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
    
    func storyForIndexPath(indexPath: NSIndexPath) -> Story? {
        return storyItemForIndexPath(indexPath).story
    }
    
    func setStoryForIndexPath(story: Story, indexPath: NSIndexPath) {
        stories[indexPath.item].story = story
    }
    
}

extension StoriesViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryCell.identifier, forIndexPath: indexPath) as!   StoryCell
        cell.delegate = self
        let storyItem = storyItemForIndexPath(indexPath)
        
        if let story = storyItem.story {
            cell.prepare(story)
        } else {
            apiClient.getStory(storyItem.id, completion: { [weak self] (story, error) -> Void in
                if let story = story {
                    self?.setStoryForIndexPath(story, indexPath: indexPath)
                    UIView.performWithoutAnimation({ () -> Void in
                        self?.collectionView.reloadItemsAtIndexPaths([indexPath])
                    })
                }
                })
        }
        
        return cell
    }
}

extension StoriesViewController: StoryCellDelegate {
    
    func cellDidSelectStoryArticle(cell: StoryCell) {
        let indexPath = collectionView.indexPathForCell(cell)!
        let story = storyItemForIndexPath(indexPath).story
        if let URL = story?.URL {
            navigationController?.pushViewController(ReadabilityViewContoller(articleURL:URL), animated: true)
        }
    }
    
    func cellDidSelectStoryComments(cell: StoryCell) {
        let indexPath = collectionView.indexPathForCell(cell)!
        if let story = storyItemForIndexPath(indexPath).story {
            navigationController?.pushViewController(CommentsViewController(story: story), animated: true)
        }
    }
}

