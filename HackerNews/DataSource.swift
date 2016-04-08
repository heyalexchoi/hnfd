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
    
    // TO DO: wrap in some kind of request / operation type thing?
    func getStories(type: StoriesType, limit: Int, offset: Int, completion: (stories: [Story]?, error: NSError?) -> Void) {
        hnAPIClient.getStories(type, limit: limit, offset: offset, completion: completion)
    }
    
}