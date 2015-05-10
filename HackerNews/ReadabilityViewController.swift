//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import DTCoreText

class ReadabilityViewContoller: UIViewController {
    
    var article: ReadabilityArticle?
    
    let apiClient = ReadabilityAPIClient()
    let story: Story
    let articleURL: NSURL
    
    let textView = DTAttributedTextView()
    
    init(story: Story) {
        self.story = story
        self.articleURL = story.URL!
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonDidPress")
        
        textView.textDelegate = self
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
        
        textView.attributedString = articleInfo
    }
    
    func getReadabilityArticle() {
        ProgressHUD.showHUDAddedTo(view, animated: true)
        apiClient.getParsedArticleForURL(articleURL, completion: { [weak self] (article, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.article = article
            if let article = article,
                strong_self = self {
                    let attributedContent = NSMutableAttributedString(attributedString: article.attributedContent)
                    let attributedText = NSMutableAttributedString()
                    attributedText.appendAttributedString(strong_self.textView.attributedString)
                    attributedText.appendAttributedString(NSAttributedString(string: "\n\n", attributes: TextAttributes.textReaderAttributes))
                    attributedText.appendAttributedString(attributedContent)
                    strong_self.textView.attributedString = attributedText
                    strong_self.textView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
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

extension ReadabilityViewContoller: DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate {
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment.isKindOfClass(DTImageTextAttachment.self) {
            let imageView = DTLazyImageView(frame: frame)
            imageView.delegate = self
            imageView.url = attachment.contentURL
            return imageView
        }
        return nil
    }
    
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let url = lazyImageView.url
        let predicate = NSPredicate(format: "contentURL == %@", url)
        let textContentView = textView.attributedTextContentView
        for attachment in textContentView.layoutFrame.textAttachmentsWithPredicate(predicate) as! [DTTextAttachment] {
            attachment.originalSize = size
            if attachment.displaySize.width > textContentView.layoutFrame.frame.size.width {
                let resizeRatio = textContentView.layoutFrame.frame.size.width / attachment.displaySize.width
                attachment.displaySize = CGSize(width: attachment.displaySize.width * resizeRatio, height: attachment.displaySize.height * resizeRatio)
            }
            textContentView.layouter = nil
            textContentView.relayoutText()
        }
    }
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForLink url: NSURL!, identifier: String!, frame: CGRect) -> UIView! {
        let linkButton = DTLinkButton(frame: frame)
//        let normalImage = attributedTextContentView.contentImageWithBounds(frame, options: DTCoreTextLayoutFrameDrawingOptions.DrawLinksHighlighted)
//        linkButton.setImage(normalImage, forState: .Normal)
        linkButton.URL = url
        linkButton.minimumHitSize = CGSize(width: 25, height: 25)
        linkButton.addTarget(self, action: "linkButtonDidPress:", forControlEvents: .TouchUpInside)
        println("made link button for url \(url)")
        return linkButton
    }
    
    func linkButtonDidPress(button: DTLinkButton) {
        presentViewController(UINavigationController(rootViewController: WebViewController(url: button.URL)), animated: true, completion: nil)
    }
}