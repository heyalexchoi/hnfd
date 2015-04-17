//
//  TopStoriesCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import Alamofire

protocol StoryCellDelegate: class {
    func cellDidSelectStoryArticle(cell: StoryCell, story: Story)
    func cellDidSelectStoryComments(cell: StoryCell, story: Story)
}

class StoryCell: UICollectionViewCell {
    
    var story: Story?
    weak var delegate: StoryCellDelegate?
    class var identifier: String {
        return "StoryCellIdentifier"
    }
    
    let articleContainer = UIView()
    let commentsContainer = UIView()
    
    let titleLabel = UILabel()
    let scoreLabel = UILabel()
    let byLabel = UILabel()
    let timeLabel = UILabel()
    let URLLabel = UILabel()
    let commentsLabel = UILabel()
    
    let scoreBySpace = UIView()
    let byTimeSpace = UIView()
    
    let articleButton = UIButton()
    let commentsButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .ByWordWrapping
        
        for label in [titleLabel, byLabel, scoreLabel, timeLabel, URLLabel] {
            label.textColor = UIColor.textColor()
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            articleContainer.addSubview(label)
        }
        
        scoreBySpace.setTranslatesAutoresizingMaskIntoConstraints(false)
        articleContainer.addSubview(scoreBySpace)
        byTimeSpace.setTranslatesAutoresizingMaskIntoConstraints(false)
        articleContainer.addSubview(byTimeSpace)
        
        commentsLabel.textColor = UIColor.textColor()
        commentsLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        commentsContainer.addSubview(commentsLabel)
        
        articleContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(articleContainer)
        
        commentsContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(commentsContainer)
        
        articleButton.addTarget(self, action: "articleButtonDidPress", forControlEvents: .TouchUpInside)
        articleButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(articleButton)
        
        commentsButton.addTarget(self, action: "commentsButtonDidPress", forControlEvents: .TouchUpInside)
        commentsButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(commentsButton)
        
        articleContainer.twt_addConstraintsWithVisualFormatStrings([
            "H:|[titleLabel]|",
            "H:|[scoreLabel][scoreBySpace(==byTimeSpace)][byLabel][byTimeSpace][timeLabel]|",
            "H:|[URLLabel]|",
            "V:|[titleLabel]-5-[scoreLabel]-5-[URLLabel]|",
            "V:[titleLabel]-5-[byLabel]",
            "V:[titleLabel]-5-[timeLabel]"], views: [
                "titleLabel": titleLabel,
                "scoreLabel": scoreLabel,
                "byLabel": byLabel,
                "timeLabel": timeLabel,
                "URLLabel": URLLabel,
                "scoreBySpace": scoreBySpace,
                "byTimeSpace": byTimeSpace])
        
        commentsContainer.twt_addHorizontalCenteringConstraintWithView(commentsLabel)
        commentsContainer.twt_addVerticalCenteringConstraintWithView(commentsLabel)
        
        contentView.backgroundColor = UIColor.backgroundColor()
        contentView.twt_addVerticalCenteringConstraintWithView(articleContainer)
        contentView.twt_addConstraintsWithVisualFormatStrings([
            "H:|-15-[articleContainer]-5-[commentsContainer(==40)]|",
            "V:|[commentsContainer]|",
            "H:|[articleButton][commentsButton(==commentsContainer)]|",
            "V:|[articleButton]|",
            "V:|[commentsButton]|"], views: [
                "commentsContainer": commentsContainer,
                "articleContainer": articleContainer,
            "articleButton": articleButton,
            "commentsButton": commentsButton])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for label in [titleLabel, byLabel, commentsLabel, scoreLabel, timeLabel, URLLabel] {
            label.text = nil
        }
        story = nil
    }
    
    func prepare(story: Story) {
        titleLabel.text = story.title
        byLabel.text = story.by
        commentsLabel.text = String(story.kids.count)
        scoreLabel.text = String(story.score)
        timeLabel.text = String(story.time)
        URLLabel.text = story.URL.absoluteString
        self.story = story
    }
    
    func articleButtonDidPress() {
        if let story = story {
            delegate?.cellDidSelectStoryArticle(self, story: story)
        }
    }
    
    func commentsButtonDidPress() {
        if let story = story {
            delegate?.cellDidSelectStoryComments(self, story: story)
        }
    }
}
