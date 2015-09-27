//
//  CommentCell.swift
//  HackerNews
//
//  Created by Alex Choi on 4/18/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class CommentCell: UITableViewCell {
    
    class var identifier: String {
        return "CommentCellIdentifier"
    }
    
    let indentation = UIView()
    var indentationWidthConstraint: NSLayoutConstraint
    
    let byLabel = Label()
    let timeLabel = Label()
    let textView = TextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        indentationWidthConstraint = indentation.twt_addWidthConstraintWithConstant(15)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.backgroundColor()
        selectionStyle = .None
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        
        for view in [indentation, byLabel, timeLabel, textView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        textView.backgroundColor = UIColor.backgroundColor()
        textView.editable = false
        textView.scrollEnabled = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = .All
        
        contentView.twt_addConstraintsWithVisualFormatStrings([
            "H:|[indentation][byLabel]-30-[timeLabel]-(>=0)-|",
            "H:|[indentation][textView]-15-|",
            "V:|-15-[byLabel]-15-[textView]-15-|",
            "V:[timeLabel]-15-[textView]",
            "V:|[indentation]|"], views: [
                "byLabel": byLabel,
                "timeLabel": timeLabel,
                "textView": textView,
                "indentation": indentation])
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func estimatedHeight(width: CGFloat, attributedText: NSAttributedString, level: Int) -> CGFloat {
        let textBoundingRect = attributedText.boundingRectWithSize(CGSize(width: width - indentationWidthForLevel(level) - 15, height: CGFloat.max),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            context: nil)
        let textHeight = textBoundingRect.height
        let detailFont: UIFont = TextAttributes.textAttributes[NSFontAttributeName] as! UIFont
        let detailHeight = detailFont.lineHeight
        return 15 + detailHeight + 15 + textHeight + 15
    }
    
    func prepare(comment: Comment, level: Int) {
        indentationWidthConstraint.constant = indentationWidthForLevel(level)
        byLabel.text = comment.by
        timeLabel.text = comment.date.timeAgoSinceNow()
        textView.attributedText = comment.attributedText
    }
    
    func indentationWidthForLevel(level: Int) -> CGFloat {
        return CGFloat((level + 2) * 15)
    }
}
