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
    
    let byLabel = Label()
    let timeLabel = Label()
    let textView = TextView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.backgroundColor()
        
        for view in [byLabel, timeLabel, textView] {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            contentView.addSubview(view)
        }
        
        textView.backgroundColor = UIColor.backgroundColor()
        textView.userInteractionEnabled = false
        textView.scrollEnabled = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.textContainer.lineFragmentPadding = 0
        
        contentView.twt_addConstraintsWithVisualFormatStrings([
            "H:|-15-[byLabel]-30-[timeLabel]-(>=0)-|",
            "H:|-15-[textView]-15-|",
            "V:|-15-[byLabel]-15-[textView]-15-|",
            "V:[timeLabel]-15-[textView]"], views: [
                "byLabel": byLabel,
                "timeLabel": timeLabel,
                "textView": textView])
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(commentItem: CommentItem) {
        if let comment = commentItem.comment {
            byLabel.text = comment.by
            timeLabel.text = String(comment.time)
            textView.text = comment.text
        }
    }
}
