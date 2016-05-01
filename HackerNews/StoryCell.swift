
//
//  TopStoriesCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import AutolayoutExtensions

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
        leftSwipeRecognizer.addTarget(self, action: #selector(StoryCell.didSwipeLeft))
        rightSwipeRecognizer.addTarget(self, action: #selector(StoryCell.didSwipeRight))
        contentView.addGestureRecognizer(leftSwipeRecognizer)
        contentView.addGestureRecognizer(rightSwipeRecognizer)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        
        for label in [titleLabel, byLabel, scoreLabel, timeLabel, URLLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            articleContainer.addSubview(label)
        }
        
        scoreBySpace.translatesAutoresizingMaskIntoConstraints = false
        articleContainer.addSubview(scoreBySpace)
        
        byTimeSpace.translatesAutoresizingMaskIntoConstraints = false
        articleContainer.addSubview(byTimeSpace)
        
        commentsLabel.translatesAutoresizingMaskIntoConstraints = false
        commentsContainer.addSubview(commentsLabel)
        
        pinnedImageView.translatesAutoresizingMaskIntoConstraints = false
        commentsContainer.addSubview(pinnedImageView)
        
        articleContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(articleContainer)
        
        commentsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(commentsContainer)
        
        articleButton.addTarget(self, action: #selector(StoryCell.articleButtonDidPress), forControlEvents: .TouchUpInside)
        articleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(articleButton)
        
        commentsButton.addTarget(self, action: #selector(StoryCell.commentsButtonDidPress), forControlEvents: .TouchUpInside)
        commentsButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(commentsButton)
        
        articleContainer.addConstraintsWithVisualFormatStrings([
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
        
        commentsLabel.anchorCenterToCenterOfView(commentsContainer)
        
        pinnedImageView.anchorTopToTopEdgeOfView(commentsContainer, constant: 10)
        pinnedImageView.anchorRightToRightEdgeOfView(commentsContainer, constant: -10)
        
        contentView.backgroundColor = UIColor.backgroundColor()        
        articleContainer.anchorCenterYToCenterYOfView(contentView)
        contentView.addConstraintsWithVisualFormatStrings([
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
    
    func estimatedHeight(width: CGFloat, title: String) -> CGFloat {
        let attributedTitle = NSAttributedString(string: title, attributes: titleLabel.defaultTextAttributes)
        let titleBoundingRect = attributedTitle.boundingRectWithSize(CGSize(width: width - 60, height: CGFloat.max),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            context: nil)
        let titleHeight = titleBoundingRect.height
        let detailFont: UIFont = TextAttributes.detailAttributes[NSFontAttributeName] as! UIFont
        let detailHeight = detailFont.lineHeight
        return 15 + titleHeight + 5 + detailHeight + 5 + detailHeight + 15
    }
    
    func prepare(story: Story) {
        titleLabel.text = story.title
        byLabel.setText("by \(story.by)", attributes: TextAttributes.detailAttributes)
        commentsLabel.setText("\(story.descendants) comments", attributes: TextAttributes.detailAttributes)
        scoreLabel.setText("\(story.score) points", attributes: TextAttributes.detailAttributes)
        timeLabel.setText(String(story.date.timeAgoSinceNow()), attributes: TextAttributes.detailAttributes)
        URLLabel.setText(story.URL?.absoluteString, attributes: TextAttributes.detailAttributes)
//        pinnedImageView.hidden = !story.saved
        pinnedImageView.hidden = true
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
