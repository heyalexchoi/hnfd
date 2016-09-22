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
            let attributedTitle = NSMutableAttributedString(string: title ?? "", attributes: TextAttributes.titleAttributes)
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
        
        label.anchorAllEdgesToView(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap() {
        tapHandler?()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview {
            frame = superview.frame
        }
    }
    
}
