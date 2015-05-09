//
//  TextView.swift
//  HackerNews
//
//  Created by Alex Choi on 5/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


class TextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var text: String? {
        didSet {
            if let text = text {
                let attributedString = NSAttributedString(string: text, attributes: TextAttributes.textAttributes)
                attributedText = attributedString
            }
        }
    }
}
