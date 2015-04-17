//
//  TopStoriesCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import Dollar
import Alamofire

class TopStoriesCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let byLabel = UILabel()
    let commentsLabel = UILabel()
    let scoreLabel = UILabel()
    let timeLabel = UILabel()
    let URLLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        $.each([titleLabel, byLabel, commentsLabel, scoreLabel, timeLabel, URLLabel]) { (label: UILabel) -> Void in
            label.textColor = UIColor.whiteColor()
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.contentView.addSubview(label)
        }
        
        contentView.twt_addConstraintsWithVisualFormatStrings([
            "H:|-15-[titleLabel]->=5-[commentsLabel]-15-|",
            "H:|-15-[scoreLabel]-5-[byLabel]-5-[timeLabel]",
            "H:|-15-[URLLabel]-15-|",
            "V:|-15-[titleLabel]-5-[byLabel]-5-[URLLabel]-5-|",
            "V:[titleLabel]-5-[scoreLabel]",
            "V:[titleLabel]-5-[timeLabel]",
            "V:|-15-[commentsLabel]"], views: [
                "titleLabel": titleLabel,
                "byLabel": byLabel,
                "commentsLabel": commentsLabel,
                "scoreLabel": scoreLabel,
                "timeLabel": timeLabel,
                "URLLabel": URLLabel])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(story: Story) {
        titleLabel.text = story.title
        byLabel.text = story.by
        commentsLabel.text = String(story.kids.count)
        scoreLabel.text = String(story.score)
        timeLabel.text = String(story.time)
        URLLabel.text = story.url.absoluteString
        
    }
}
