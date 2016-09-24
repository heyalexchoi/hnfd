
//
//  TopStoriesCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import AutolayoutExtensions

protocol StoryCellDelegate: class {
    func cellDidSelectStoryArticle(_ cell: StoryCell)
    func cellDidSelectStoryComments(_ cell: StoryCell)
    func cellDidSwipeLeft(_ cell: StoryCell)
    func cellDidSwipeRight(_ cell: StoryCell)
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
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        
        leftSwipeRecognizer.direction = .left
        rightSwipeRecognizer.direction = .right
        leftSwipeRecognizer.addTarget(self, action: #selector(StoryCell.didSwipeLeft))
        rightSwipeRecognizer.addTarget(self, action: #selector(StoryCell.didSwipeRight))
        contentView.addGestureRecognizer(leftSwipeRecognizer)
        contentView.addGestureRecognizer(rightSwipeRecognizer)
        
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
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
        
        articleButton.addTarget(self, action: #selector(StoryCell.articleButtonDidPress), for: .touchUpInside)
        articleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(articleButton)
        
        commentsButton.addTarget(self, action: #selector(StoryCell.commentsButtonDidPress), for: .touchUpInside)
        commentsButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(commentsButton)
        
        _ = articleContainer.addConstraints(withVisualFormats: [
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
        
        _ = commentsLabel.anchorCenterToCenterOfView(commentsContainer)
        
        _ = pinnedImageView.anchorTopToTopEdgeOfView(commentsContainer, constant: 10)
        _ = pinnedImageView.anchorRightToRightEdgeOfView(commentsContainer, constant: -10)
        
        contentView.backgroundColor = UIColor.backgroundColor()        
        _ = articleContainer.anchorCenterYToCenterYOfView(contentView)
        _ = contentView.addConstraints(withVisualFormats: [
            "H:|-15-[articleContainer]-5-[commentsContainer(==40)]|",
            "V:|[commentsContainer]|",
            "H:|[articleButton][commentsButton(==commentsContainer)]|",
            "V:|[articleContainer]|",
            "V:|[articleButton]|",
            "V:|[commentsButton]|"],
                                       views: [
                                        "commentsContainer": commentsContainer,
                                        "articleContainer": articleContainer,
                                        "articleButton": articleButton,
                                        "commentsButton": commentsButton])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func estimatedHeight(_ width: CGFloat, title: String) -> CGFloat {
        let attributedTitle = NSAttributedString(string: title, attributes: titleLabel.defaultTextAttributes)
        let titleBoundingRect = attributedTitle.boundingRect(with: CGSize(width: width - 60, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        let titleHeight = titleBoundingRect.height
        let detailFont: UIFont = TextAttributes.detailAttributes[NSFontAttributeName] as! UIFont
        let detailHeight = detailFont.lineHeight
        return 15 + titleHeight + 5 + detailHeight + 5 + detailHeight + 15
    }
    
    func prepare(_ story: Story) {
        titleLabel.text = story.title
        byLabel.setText("by \(story.by)", attributes: TextAttributes.detailAttributes)
        commentsLabel.setText("\(story.descendants) comments", attributes: TextAttributes.detailAttributes)
        scoreLabel.setText("\(story.score) points", attributes: TextAttributes.detailAttributes)
        timeLabel.setText(String((story.date as NSDate).timeAgoSinceNow()), attributes: TextAttributes.detailAttributes)
        URLLabel.setText(story.URL?.absoluteString, attributes: TextAttributes.detailAttributes)
//        pinnedImageView.hidden = !story.saved
        pinnedImageView.isHidden = true
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
