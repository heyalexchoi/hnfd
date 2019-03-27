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
    
    fileprivate let indentation = UIView()
    fileprivate var indentationWidthConstraint: NSLayoutConstraint
    fileprivate let textViewHeightConstraint: NSLayoutConstraint
    
    fileprivate let expandedLabel = Label()
    fileprivate let byLabel = Label()
    fileprivate let timeLabel = Label()
    fileprivate let textView = TextView()
    
    fileprivate let textViewRightPadding: CGFloat = 15
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        indentationWidthConstraint = indentation.anchorWidthToConstant(15)
        textViewHeightConstraint = textView.anchorHeightToConstant(0)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.backgroundColor()
        selectionStyle = .none
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        
        for view in [indentation, expandedLabel, byLabel, timeLabel, textView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
        }
        
        textView.backgroundColor = UIColor.backgroundColor()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = .all
        
        _ = timeLabel.anchorCenterYToCenterYOfView(byLabel)
        _ = expandedLabel.anchorCenterYToCenterYOfView(byLabel)
        
        _ = contentView.addConstraints(withVisualFormats: [
            "H:|[indentation][expandedLabel]-5-[byLabel]-30-[timeLabel]-(>=0)-|",
            "H:|[indentation][textView]-15-|",
            "V:|-15-[byLabel]-15-[textView]-\(textViewRightPadding)-|",
            "V:|[indentation]|"], views: [
                "byLabel": byLabel,
                "expandedLabel": expandedLabel,
                "timeLabel": timeLabel,
                "textView": textView,
                "indentation": indentation])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func estimateHeight(attributedBodyText: NSAttributedString, byText: String, date: Date, level: Int, isExpanded: Bool, width: CGFloat) -> CGFloat {
        prepare(attributedBodyText: attributedBodyText, byText: byText, date: date, level: level, width: width, isExpanded: isExpanded, textViewDelegate: nil)
        return contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
    func prepare(attributedBodyText: NSAttributedString,
                 byText: String,
                 date: Date,
                 level: Int,
                 width: CGFloat,
                 isExpanded: Bool,
                 textViewDelegate: UITextViewDelegate?) {
        
        let indentationWidth = indentationWidthForLevel(level)
        indentationWidthConstraint.constant = indentationWidth
        expandedLabel.attributedText = isExpandedAttributedText(isExpanded: isExpanded)
        byLabel.text = byText
        timeLabel.text = (date as NSDate).timeAgoSinceNow()
        textView.attributedText = attributedBodyText
        textView.delegate = textViewDelegate
        
        let textViewWidth = width - textViewRightPadding - indentationWidth
        textViewHeightConstraint.constant = isExpanded ? textView.sizeThatFits(CGSize(width: textViewWidth, height: 99999)).height : 0
    }
    
    fileprivate func indentationWidthForLevel(_ level: Int) -> CGFloat {
        return CGFloat((level + 2) * 15)
    }
    
    fileprivate func isExpandedAttributedText(isExpanded: Bool) -> NSAttributedString {
        let isExpandedText = isExpanded ? "[-]" : "[+]"
        let isExpandedAttributedText = NSMutableAttributedString(string: isExpandedText,
                                                                 attributes: convertToOptionalNSAttributedStringKeyDictionary(TextAttributes.textAttributes))
        isExpandedAttributedText.addAttributes(convertToNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.symbolFont()]),
                                               range: NSRange(location: 1, length: 1))
        return isExpandedAttributedText
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
