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
    let date: NSDate
    
    init(json: JSON, level: Int) {
        self.by = json["by"].stringValue
        self.id = json["_id"].intValue
        self.parent = json["parent"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.time = json["time"].intValue
        let text = json["text"].stringValue
        self.text = text
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)!
        self.attributedText = data.length > 0 ? NSAttributedString(HTMLData: data, options: [DTUseiOS6Attributes: true, DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSAttributedString(string: "")
        self.deleted = json["deleted"].boolValue
        self.children = json["children"].arrayValue.map { Comment(json: $0, level: level + 1) } .filter { !$0.deleted }
        self.level = level
        self.date = NSDate(timeIntervalSince1970: NSTimeInterval(self.time))
    }
    
    func toJSON() -> AnyObject {
        return [
            "by": by,
            "_id": id,
            "parent": parent,
            "kids": kids,
            "time": time,
            "text": text,
            "deleted": deleted,
            "children": children,
            "level": level
        ]
    }
    
    required convenience init(coder decoder: NSCoder) {
        let json: AnyObject = decoder.decodeObjectForKey("json")!
        let level = json["level"] as! Int
        self.init(json:JSON(json), level:level)
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(toJSON(), forKey: "json")
    }
}

