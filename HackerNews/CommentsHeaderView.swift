//
//  CommentsHeaderView.swift
//  HackerNews
//
//  Created by Alex Choi on 5/31/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


class CommentsHeaderView: UIView {
    
    let titleLabel = Label()
    let detailLabel = Label()
    let linkLabel = TextView()
    let linkLabelTextViewSpacing = UIView()
    let textView = TextView()
    let bottomBorder = UIView()
    
    var widthConstraint: NSLayoutConstraint!
    var linkLabelTextViewSpacingHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for subview in [titleLabel, linkLabel, detailLabel, textView, bottomBorder, linkLabelTextViewSpacing] {
            if let label = subview as? UILabel {
                label.numberOfLines = 0
                label.textAlignment = .center
            }
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        
        bottomBorder.backgroundColor = UIColor.separatorColor()
        
        _ = addConstraints(withVisualFormats: [
            "V:|-15-[titleLabel]-10-[detailLabel]-10-[linkLabel][linkLabelTextViewSpacing][textView]-15-[bottomBorder(==1)]|",
            "H:|-15-[titleLabel]-15-|",
            "H:|-15-[detailLabel]-15-|",
            "H:|-15-[textView]-15-|",
            "H:|-15-[linkLabel]-15-|",
            "H:|[bottomBorder]|"], views: [
                "textView": textView,
                "titleLabel": titleLabel,
                "detailLabel": detailLabel,
                "linkLabel": linkLabel,
                "linkLabelTextViewSpacing": linkLabelTextViewSpacing,
                "bottomBorder": bottomBorder])
        
        widthConstraint = anchorWidthToConstant(999)
        linkLabelTextViewSpacingHeightConstraint = linkLabelTextViewSpacing.anchorHeightToConstant(999)
        
    }
    
    convenience init(story: Story) {
        self.init(frame: CGRect.zero)
        prepare(story)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(_ story: Story) {
        titleLabel.setText(story.title, attributes: TextAttributes.titleAttributes)
        if let URL = story.URL {
            linkLabel.attributedText = NSAttributedString(string: URL.absoluteString, attributes: merge(TextAttributes.URLAttributes(URL), TextAttributes.textAttributes, TextAttributes.centerAlignment))
        } else {
            linkLabel.text = nil
        }
        detailLabel.setText("Submitted by \(story.by) \((story.date as NSDate).timeAgoSinceNow())", attributes: TextAttributes.textAttributes)
        textView.attributedText = story.attributedText
        
        linkLabelTextViewSpacingHeightConstraint.constant = story.attributedText.length > 0 ? 10 : 0
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            widthConstraint.constant = superview.bounds.width
        }
    }
}
