//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


class ReadabilityViewContoller: UIViewController {
    
    var article: ReadabilityArticle?
    
    let apiClient = ReadabilityAPIClient()
    let story: Story
    let articleURL: NSURL
    
    let textView = UITextView()
    
    init(story: Story) {
        self.story = story
        self.articleURL = story.URL!
        super.init(nibName: nil, bundle: nil)
    
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonDidPress")
        
        let inset: CGFloat = 20
        textView.delegate = self
        textView.editable = false
        textView.textContainerInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        textView.backgroundColor = UIColor.backgroundColor()
        for view in [textView] {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(view)
        }
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[textView]|",
            "V:|[textView]|"], views: [
                "textView": textView])
        
        populateArticleInfo()
        
        getReadabilityArticle()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populateArticleInfo() {
        let articleInfo = NSMutableAttributedString()
        
        let title = NSMutableAttributedString(string: story.title, attributes: merge(TextAttributes.titleAttributes, TextAttributes.centerAlignment))
        articleInfo.appendAttributedString(title)
        
        let submitter = NSAttributedString(string: "\n\nsubmitted \(story.date.timeAgoSinceNow()) by \(story.by)", attributes: merge(TextAttributes.textReaderAttributes, TextAttributes.centerAlignment))
        articleInfo.appendAttributedString(submitter)
        
        let link = NSAttributedString(string: "\n\n\(articleURL.absoluteString!)", attributes: merge(TextAttributes.textReaderAttributes, TextAttributes.centerAlignment, TextAttributes.URLAttributes(articleURL)))
        articleInfo.appendAttributedString(link)
        
        textView.attributedText = articleInfo
        
    }
    
    func getReadabilityArticle() {
        ProgressHUD.showHUDAddedTo(view, animated: true)
        apiClient.getParsedArticleForURL(articleURL, completion: { [weak self] (article, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.article = article
            if let article = article,
                strong_self = self {
                    let attributedContent = NSMutableAttributedString(attributedString: article.attributedContent)
                    // overlay text attributes
                    attributedContent.addAttributes(TextAttributes.textReaderAttributes, range: NSRange(location: 0, length: count(attributedContent.string)))
                    // resize attachments
                    attributedContent.enumerateAttribute(NSAttachmentAttributeName, inRange: NSRange(location: 0, length: attributedContent.length), options: nil) { [weak self] (attribute, range, stop) -> Void in
                        if let attachment = attribute as? NSTextAttachment,
                            let strong_self = self {
                                if attachment.bounds.size.width > strong_self.textView.textContainer.size.width {
                                    let resizeRatio = strong_self.textView.textContainer.size.width / attachment.bounds.size.width
                                    attachment.bounds = CGRect(x: 0, y: 0, width: attachment.bounds.size.width * resizeRatio, height: attachment.bounds.size.height * resizeRatio)
                                }
                        }
                    }
                    
                    let attributedText = NSMutableAttributedString()
                    attributedText.appendAttributedString(strong_self.textView.attributedText) // info
                    attributedText.appendAttributedString(NSAttributedString(string: "\n\n", attributes: TextAttributes.textReaderAttributes))
                    attributedText.appendAttributedString(attributedContent)
                    
                    strong_self.textView.attributedText = attributedText
                    
            } else if let error = error {
                UIAlertView(title: "Get Parsed Article Error",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            })
    }
    
    func actionButtonDidPress() {
        presentViewController(UIActivityViewController(activityItems: [articleURL], applicationActivities: nil), animated: true, completion: nil)
    }
    
}

extension ReadabilityViewContoller: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        presentViewController(UINavigationController(rootViewController: WebViewController(url: URL)), animated: true, completion: nil)
        return false
    }
    
}