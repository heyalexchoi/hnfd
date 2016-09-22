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
        indentationWidthConstraint = indentation.anchorWidthToConstant(15)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.backgroundColor()
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        
        for view in [indentation, byLabel, timeLabel, textView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        textView.backgroundColor = UIColor.backgroundColor()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = .all
        
        contentView.addConstraintsWithVisualFormatStrings([
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
    
    func estimatedHeight(_ width: CGFloat, attributedText: NSAttributedString, level: Int) -> CGFloat {
        let textBoundingRect = attributedText.boundingRect(with: CGSize(width: width - indentationWidthForLevel(level) - 15, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        let textHeight = textBoundingRect.height
        let detailFont: UIFont = TextAttributes.textAttributes[NSFontAttributeName] as! UIFont
        let detailHeight = detailFont.lineHeight
        return 15 + detailHeight + 15 + textHeight + 15
    }
    
    func prepare(_ comment: Comment, level: Int) {
        indentationWidthConstraint.constant = indentationWidthForLevel(level)
        byLabel.text = comment.by
        timeLabel.text = (comment.date as NSDate).timeAgoSinceNow()
        textView.attributedText = comment.attributedText
    }
    
    func indentationWidthForLevel(_ level: Int) -> CGFloat {
        return CGFloat((level + 2) * 15)
    }
}
