//
//  ViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import UIKit
import Dollar


class StoriesViewController: UIViewController {
    
    struct StoryItem {
        let id: Int
        var story: Story?
    }
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
        apiClient.getTopStories { [weak self] (ids, error) -> Void in
            if let ids = ids {
                $.each(ids) { self?.stories.append(StoryItem(id: $0, story: nil)) }
                self?.collectionView.reloadData()
            } else {
                println("error getting top story ids")
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
        let storyItem = storyItemForIndexPath(indexPath)
        
        if let story = storyItem.story {
            cell.prepare(story)
        } else {
            apiClient.getStory(storyItem.id, completion: { [weak self] (story, error) -> Void in
                self?.stories[indexPath.item] = StoryItem(id: storyItem.id, story: story)
                self?.collectionView.reloadItemsAtIndexPaths([indexPath])
                })
        }
        
        return cell
    }
}

extension StoriesViewController: StoryCellDelegate {

    func cellDidSelectStoryArticle(cell: StoryCell, story: Story) {
        //
    }
    
    func cellDidSelectStoryComments(cell: StoryCell, story: Story) {
        //
    }
}

