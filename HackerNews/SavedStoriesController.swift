//
//  SavedStoriesController.swift
//  HackerNews
//
//  Created by alexchoi on 7/6/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


class SavedStoriesController {
    
    static let sharedController = SavedStoriesController()
    let cache = Cache.sharedCache()
    
    var savedStories: [Story] = {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(StoriesType.Saved.rawValue) as? NSData {
            if var loadedStories = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Story] {
                loadedStories = NSOrderedSet(array: loadedStories).array as! [Story]
                return loadedStories
            }
        }
        return [Story]()
        }()
    
    func fetchAffiliatedStoryData(story: Story) {
        cache.articleForStory(story, completion: nil)
        cache.fullStoryForStory(story, preference: .FetchRemoteDataAndUpdateCache, completion: nil)
    }
    
    func updateAllSavedStories() {
        // this should probably be queued or something. cpu goes nuts when i do this
        for story in savedStories {
            fetchAffiliatedStoryData(story)
        }
    }
    
    // filter fetched stories through this method to update saved stories and properly mark fetched stories
    func filterStories(stories: [Story]) -> [Story] {
        return stories.map { [weak self] (story) -> Story in
            if let strong_self = self {
                if let index = find(strong_self.savedStories, story) {
                    story.saved = true
                    strong_self.savedStories[index] = story
                    strong_self.fetchAffiliatedStoryData(story)
                }
            }
            return story
        }
    }
    
    // MARK: - SAVED STORIES
    
    func saveStory(story: Story) -> Bool {
        if story.saved { return false }
        story.saved = true
        savedStories.insert(story, atIndex: 0)
        syncSavedStories()
        fetchAffiliatedStoryData(story)
        return true
    }
    
    func unsaveStory(story: Story) {
        if !story.saved { return }
        story.saved = false
        savedStories = savedStories.filter { $0 != story }
        syncSavedStories()
    }
    
    func syncSavedStories() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(savedStories)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: StoriesType.Saved.rawValue)
    }
}
