//
//  HNLabel.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class Label: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var text: String? {
        didSet {
            if let text = text {
                let attributedString = NSAttributedString(string: text, attributes: TextAttributes.textAttributes)
                attributedText = attributedString
            } else {
                text = nil
            }
        }
    }
    
    func setText(string: String?, attributes: [String: NSObject]) {
        if let string = string {
            attributedText = NSAttributedString(string: string, attributes: attributes)
        } else {
            text = nil
        }
    }
}
