//
//  HNLabel.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class Label: UILabel {
    
    let defaultTextAttributes = TextAttributes.textAttributes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var text: String? {
        didSet {
            if let text = text {
                let attributedString = NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(defaultTextAttributes))
                attributedText = attributedString
            } else {
                attributedText = nil
            }
        }
    }
    
    func setText(_ string: String?, attributes: [String: AnyObject]) {
        if let string = string {
            attributedText = NSAttributedString(string: string, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
        } else {
            attributedText = nil
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
