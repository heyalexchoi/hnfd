//
//  StoriesTitleView.swift
//  HackerNews
//
//  Created by Alex Choi on 5/9/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import NYXImagesKit
import UIImage_Additions

class StoriesTitleView: UIView {
    
    var title: String? {
        didSet {
            let attachment = NSTextAttachment()
            let downChevron = UIImage.add_imageNamed("down_chevron", tintColor: UIColor.textColor(), style: ADDImageTintStyleKeepingAlpha).scaleToFitSize(CGSize(width: 15, height: 15))
            attachment.image = downChevron
            let attributedTitle = NSMutableAttributedString(string: title ?? "", attributes: TextAttributes.titleAttributes)
            attributedTitle.appendAttributedString(NSAttributedString(string: "  "))
            attributedTitle.appendAttributedString(NSAttributedString(attachment: attachment))
            label.attributedText = attributedTitle
            label.tintColor = UIColor.textColor()
        }
    }
    let label = UILabel()
    var tapHandler: (() -> Void)?
    let tapRecognizer = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textAlignment = .Center
        
        tapRecognizer.addTarget(self, action: "handleTap")
        addGestureRecognizer(tapRecognizer)
        addSubview(label)
        
        label.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap() {
        tapHandler?()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        frame = superview!.frame
    }
    
}
