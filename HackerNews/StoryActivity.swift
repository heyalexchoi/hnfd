//
//  StoryActivity.swift
//  HackerNews
//
//  Created by Alex Choi on 5/31/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class StoryActivity: UIActivity {
    
    var story: Story?
    
    func storyFromActivityItems(_ activityItems: [AnyObject]) -> Story? {
        return activityItems.filter { $0.isKind(of: Story.self) }.first as? Story
    }
    
    override var activityType : UIActivityType? {        
        return UIActivityType("HNFD.ActivityType.Story")
    }
    
    override var activityTitle : String? {
        return "Save"
    }
    
    override var activityImage : UIImage? {
        return UIImage.pushPin()
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return storyFromActivityItems(activityItems as [AnyObject]) != nil
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        story = storyFromActivityItems(activityItems as [AnyObject])
    }
    
    override func perform() {
//        if let story = story {
////            SavedStoriesController.sharedController.saveStory(story)
////            TO DO: mark the story as pinned
//        }
    }
}
