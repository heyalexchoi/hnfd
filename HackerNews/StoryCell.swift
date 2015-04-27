//
//  TopStoriesCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

protocol StoryCellDelegate: class {
    func cellDidSelectStoryArticle(cell: StoryCell)
    func cellDidSelectStoryComments(cell: StoryCell)
}

class StoryCell: UITableViewCell {
    
    weak var delegate: StoryCellDelegate?
    class var identifier: String {
        return "StoryCellIdentifier"
    }
    
    let articleContainer = UIView()
    let commentsContainer = UIView()
    
    let titleLabel = Label()
    let scoreLabel = Label()
    let byLabel = Label()
    let timeLabel = Label()
    let URLLabel = Label()
    let commentsLabel = Label()
    
    let scoreBySpace = UIView()
    let byTimeSpace = UIView()
    
    let articleButton = UIButton()
    let commentsButton = UIButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.backgroundColor()
        selectionStyle = .None
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        
        for label in [titleLabel, byLabel, scoreLabel, timeLabel, URLLabel] {
            label.setTranslatesAutoresizingMaskIntoConstraints(false)
            articleContainer.addSubview(label)
        }
        
        scoreBySpace.setTranslatesAutoresizingMaskIntoConstraints(false)
        articleContainer.addSubview(scoreBySpace)
        byTimeSpace.setTranslatesAutoresizingMaskIntoConstraints(false)
        articleContainer.addSubview(byTimeSpace)
        
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
            "V:|-15-[titleLabel]-5-[scoreLabel]-5-[URLLabel]-15-|",
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
            "V:|[articleContainer]|",
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
    
    func prepare(story: Story) {
        titleLabel.text = story.title
        byLabel.text = story.by
        commentsLabel.text = String(story.descendants)
        scoreLabel.text = String(story.score)
        timeLabel.text = String(story.date.timeAgoSinceNow())
        URLLabel.text = story.URL?.absoluteString
    }
    
    func articleButtonDidPress() {
        delegate?.cellDidSelectStoryArticle(self)
    }
    
    func commentsButtonDidPress() {
        delegate?.cellDidSelectStoryComments(self)
    }
}
