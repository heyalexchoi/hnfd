//
//  StoriesTitleView.swift
//  HackerNews
//
//  Created by Alex Choi on 5/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class StoriesTitleView: UIView {
    
    var title: String? {
        didSet {
            let attachment = NSTextAttachment()
            attachment.image = UIImage.downChevron()
            let attributedTitle = NSMutableAttributedString(string: title ?? "", attributes: convertToOptionalNSAttributedStringKeyDictionary(TextAttributes.titleAttributes))
            attributedTitle.append(NSAttributedString(string: "  "))
            attributedTitle.append(NSAttributedString(attachment: attachment))
            label.attributedText = attributedTitle
            label.tintColor = UIColor.textColor()
        }
    }
    let label = UILabel()
    var tapHandler: (() -> Void)?
    let tapRecognizer = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textAlignment = .center
        
        tapRecognizer.addTarget(self, action: #selector(StoriesTitleView.handleTap))
        addGestureRecognizer(tapRecognizer)
        addSubviewsWithAutoLayout(label)
        
        _ = label.anchorAllEdgesToView(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap() {
        tapHandler?()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            frame = superview.frame
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
