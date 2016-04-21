//
//  DataSource.swift
//  HackerNews
//
//  Created by Alex Choi on 4/7/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation

struct DataSource {
    
    let readabilityAPIClient = ReadabilityAPIClient()
    let hnAPIClient = HNAPIClient()
}

extension DataSource {
    
    // MARK: - Stories
    
    // TO DO: wrap in some kind of request / operation type thing?
    func getStories(type: StoriesType, limit: Int, offset: Int, completion: (stories: [Story]?, error: NSError?) -> Void) {

        hnAPIClient.getStories(type, limit: limit, offset: offset) { (stories, error) in
        
            completion(stories: stories, error: error)
            
        }
    }
}

extension DataSource {
    
    // MARK: - Articles
    
    func articleForStory(story: Story, completion: ((article: ReadabilityArticle?, error: NSError?) -> Void)) {
        guard let URL = story.URL else {
            let error = NSError(domain: errorDomain,
                                code: 420,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Story has no URL, so there is no article to get"])
            completion(article: nil, error: error)
            return
        }
        readabilityAPIClient.getParsedArticleForURL(URL, completion: completion)
    }
    
}
