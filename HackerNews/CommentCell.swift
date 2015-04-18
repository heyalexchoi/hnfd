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
        
        selectionStyle = .None
        contentView.backgroundColor = UIColor.backgroundColor()
        
        for view in [indentation, byLabel, timeLabel, textView] {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            contentView.addSubview(view)
        }
        
        textView.backgroundColor = UIColor.backgroundColor()
        textView.userInteractionEnabled = false
        textView.scrollEnabled = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.textContainer.lineFragmentPadding = 0
        
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
    
    func prepare(commentItem: CommentItem, level: Int) {
        indentationWidthConstraint.constant = CGFloat((level + 2) * 15)
        if let comment = commentItem.comment {
            byLabel.text = comment.by
            timeLabel.text = String(comment.time)
            let attributedText = NSMutableAttributedString(attributedString: comment.attributedText)
            attributedText.addAttributes(TextAttributes.textAttributes, range: NSRange(location: 0, length: attributedText.length))
            textView.attributedText = attributedText
        }
    }
}
