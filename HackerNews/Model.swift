//
//  Model.swift
//  HackerNews
//
//  Created by alexchoi on 4/15/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON

struct Story {
    let by: String
    let descendants: Int
    let id: Int
    let kids: [Int]
    let score: Int
    let time: Int
    let title: String
    let url: NSURL
    init(json: JSON) {
        self.by = json["by"].stringValue
        self.descendants = json["descendants"].intValue
        self.id = json["id"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.score = json["score"].intValue
        self.time = json["time"].intValue
        self.title = json["title"].stringValue
        self.url = json["url"].URL ?? NSURL(string: "https://www.google.com")!
    }
}

extension Story: Printable {
    var description: String {
        return "\ntitle:\(title) \nurl:\(url) \nby:\(by) id:\(id) \ndescendants:\(descendants) \nkids:\(kids)"
    }
}