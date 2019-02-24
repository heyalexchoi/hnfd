//
//  SavedStoriesViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 2/24/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import UIKit

class SavedStoriesViewController: StoriesViewController {
    
    convenience init() {
        self.init(type: .Pinned)
        self.title = "Saved"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStories()
    }
    
}

