//
//  Comment.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON
import DTCoreText

class Comment: NSObject, NSCoding {
    
    let by: String
    let id: Int
    let kids: [Int]
    let parent: Int
    let text: String
    let attributedText: NSAttributedString
    let time: Int
    let children: [Comment]
    let deleted: Bool
    let level: Int
    let date: Date
    
    init(json: JSON, level: Int) {
        self.by = json["user"].stringValue
        self.id = json["id"].intValue
        self.parent = json["parent"].intValue // do i use this?
        self.kids = json["kids"].arrayValue.map { $0.intValue } // do i use this?
        self.time = json["time"].intValue
        let text = json["content"].stringValue
        self.text = text
        let data = text.data(using: String.Encoding.utf8)!
        self.attributedText = data.count > 0 ? NSAttributedString(htmlData: data, options: [DTUseiOS6Attributes: true, DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSAttributedString(string: "")
        self.deleted = json["deleted"].boolValue
        self.children = json["comments"].arrayValue.map { Comment(json: $0, level: level + 1) } .filter { !$0.deleted }
        self.level = level
        self.date = Date(timeIntervalSince1970: TimeInterval(self.time))
    }
    
    func toJSON() -> AnyObject {
        return [
            "user": by,
            "id": id,
            "parent": parent,
            "kids": kids,
            "time": time,
            "content": text,
            "deleted": deleted,
            "comments": children.map{$0.toJSON()},
            "level": level
        ] as NSDictionary
    }
    
    required convenience init(coder decoder: NSCoder) {
        let json: AnyObject = decoder.decodeObject(forKey: "json")! as AnyObject
        let level = json["level"] as! Int
        self.init(json:JSON(json), level:level)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(toJSON(), forKey: "json")
    }
}

