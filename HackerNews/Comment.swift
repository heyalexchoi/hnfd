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
        self.by = json["by"].stringValue
        self.id = json["_id"].intValue
        self.parent = json["parent"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.time = json["time"].intValue
        let text = json["text"].stringValue
        self.text = text
        let data = text.data(using: String.Encoding.utf8)!
        self.attributedText = data.count > 0 ? NSAttributedString(htmlData: data, options: [DTUseiOS6Attributes: true, DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSAttributedString(string: "")
        self.deleted = json["deleted"].boolValue
        self.children = json["children"].arrayValue.map { Comment(json: $0, level: level + 1) } .filter { !$0.deleted }
        self.level = level
        self.date = Date(timeIntervalSince1970: TimeInterval(self.time))
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
            "children": children.map{$0.toJSON()},
            "level": level
        ]
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

