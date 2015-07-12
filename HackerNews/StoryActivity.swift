//
//  StoryActivity.swift
//  HackerNews
//
//  Created by Alex Choi on 5/31/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class StoryActivity: UIActivity {
    
    var story: Story?
    
    func storyFromActivityItems(activityItems: [AnyObject]) -> Story? {
        return activityItems.filter { $0.isKindOfClass(Story.self) }.first as? Story
    }
    
    override func activityType() -> String? {
        return "HNFD.ActivityType.Story"
    }
    
    override func activityTitle() -> String? {
        return "Save"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage.pushPin()
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return storyFromActivityItems(activityItems) != nil
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        story = storyFromActivityItems(activityItems)
    }
    
    override func performActivity() {
        if let story = story {
            SavedStoriesController.sharedController.saveStory(story)
        }
    }
}
