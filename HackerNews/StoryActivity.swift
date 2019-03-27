//
//  StoryActivity.swift
//  HackerNews
//
//  Created by Alex Choi on 5/31/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class StoryActivity: UIActivity {
    
    var story: Story?
    
    func storyFromActivityItems(_ activityItems: [Any]) -> Story? {
        return activityItems.filter { type(of: $0) == Story.self }.first as? Story
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
        return storyFromActivityItems(activityItems) != nil
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        story = storyFromActivityItems(activityItems)
    }
    
    override func perform() {
        guard let story = story else {
            return
        }
        SharedState.shared.addPinnedStory(id: story.id)
        NotificationCenter.default.post(name: .onStorySaved, object: story)
    }
}
