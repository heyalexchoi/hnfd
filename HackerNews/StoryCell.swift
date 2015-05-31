//
//  TopStoriesCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import NYXImagesKit
import UIImage_Additions

protocol StoryCellDelegate: class {
    func cellDidSelectStoryArticle(cell: StoryCell)
    func cellDidSelectStoryComments(cell: StoryCell)
    func cellDidSwipeLeft(cell: StoryCell)
    func cellDidSwipeRight(cell: StoryCell)
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
    
    let pinnedImageView = UIImageView(image: UIImage.pushPin())
    
    let scoreBySpace = UIView()
    let byTimeSpace = UIView()
    
    let articleButton = UIButton()
    let commentsButton = UIButton()
    
    let leftSwipeRecognizer = UISwipeGestureRecognizer()
    let rightSwipeRecognizer = UISwipeGestureRecognizer()

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.backgroundColor()
        selectionStyle = .None
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        
        leftSwipeRecognizer.direction = .Left
        rightSwipeRecognizer.direction = .Right
        leftSwipeRecognizer.addTarget(self, action: "didSwipeLeft")
        rightSwipeRecognizer.addTarget(self, action: "didSwipeRight")
        contentView.addGestureRecognizer(leftSwipeRecognizer)
        contentView.addGestureRecognizer(rightSwipeRecognizer)
        
        titleLabel.numberOfLines = 0
        titleLabel.preferredMaxLayoutWidth = contentView.bounds.size.width - 60 // comments container width 40 + 5 + 15 padding
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
        
        pinnedImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        commentsContainer.addSubview(pinnedImageView)
        
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
        
        pinnedImageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(commentsContainer).offset(10)
            make.right.equalTo(commentsContainer).offset(-10)
        }
        
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
        byLabel.setText(story.by, attributes: TextAttributes.detailAttributes)
        commentsLabel.setText(String(story.descendants), attributes: TextAttributes.detailAttributes)
        scoreLabel.setText(String(story.score), attributes: TextAttributes.detailAttributes)
        timeLabel.setText(String(story.date.timeAgoSinceNow()), attributes: TextAttributes.detailAttributes)
        URLLabel.setText(story.URL?.absoluteString, attributes: TextAttributes.detailAttributes)
        pinnedImageView.hidden = !story.saved
    }
    
    func articleButtonDidPress() {
        delegate?.cellDidSelectStoryArticle(self)
    }
    
    func commentsButtonDidPress() {
        delegate?.cellDidSelectStoryComments(self)
    }
    
    func didSwipeLeft() {
        delegate?.cellDidSwipeLeft(self)
    }
    
    func didSwipeRight() {
        delegate?.cellDidSwipeRight(self)
    }
}
