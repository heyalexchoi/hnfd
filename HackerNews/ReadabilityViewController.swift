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
    var task: NSURLSessionTask?
    
    let cache = Cache.sharedCache()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let inset: CGFloat = 20
        textView.contentInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    deinit {
        task?.cancel()
    }
    
    func populateArticleInfo() {
        let articleInfo = NSMutableAttributedString()
        
        let title = NSMutableAttributedString(string: story.title, attributes: merge(TextAttributes.titleAttributes, TextAttributes.centerAlignment))
        articleInfo.appendAttributedString(title)
        
        let submitter = NSAttributedString(string: "\n\nsubmitted \(story.date.timeAgoSinceNow()) by \(story.by)", attributes: merge(TextAttributes.textReaderAttributes, TextAttributes.centerAlignment))
        articleInfo.appendAttributedString(submitter)
        
        let hyperlink = articleURL.hyperlink()
        let linkData = hyperlink.dataUsingEncoding(NSUTF8StringEncoding)
        let link = NSAttributedString(HTMLData: linkData, options: [DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil)
        articleInfo.appendAttributedString(NSAttributedString(string: "\n\n"))
        articleInfo.appendAttributedString(link)
        
        textView.attributedString = articleInfo
    }
    
    func getReadabilityArticle() {
        task?.cancel()
        ProgressHUD.showHUDAddedTo(view, animated: true)
        task = cache.articleForStory(story, completion: { [weak self] (article, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.article = article
            if let article = article {
                self?.finishLoadingArticle(article)
            } else if let error = error {
                UIAlertView(title: "Readability Article Error",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            })
        
    }
    
    func finishLoadingArticle(article: ReadabilityArticle) {
        let attributedContent = NSMutableAttributedString(attributedString: article.attributedContent)
        let attributedText = NSMutableAttributedString()
        attributedText.appendAttributedString(textView.attributedString)
        attributedText.appendAttributedString(NSAttributedString(string: "\n\n", attributes: TextAttributes.textReaderAttributes))
        
        let paragraphStyle = NSMutableParagraphStyle() // work around. DTAttributedTextView doesn't seem to display line spacing correctly
        paragraphStyle.minimumLineHeight = UIFont.textReaderFont().pointSize * 1.3
        attributedContent.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attributedContent.length))
        attributedText.appendAttributedString(attributedContent)

        textView.attributedString = attributedText
    }
    
    func actionButtonDidPress() {
        let storyActivity = StoryActivity()        
        presentViewController(UIActivityViewController(activityItems: [articleURL, story], applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
    
}


extension ReadabilityViewContoller: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        presentViewController(UINavigationController(rootViewController: WebViewController(url: URL)), animated: true, completion: nil)
        return false
    }
    
}

extension ReadabilityViewContoller: DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate {
    
    func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
        if attachment.isKindOfClass(DTImageTextAttachment.self) {
            let imageView = DTLazyImageView(frame: frame)
            imageView.delegate = self
            imageView.url = attachment.contentURL
            return imageView
        } else if attachment.isKindOfClass(DTIframeTextAttachment.self) {
            if attachment.displaySize.width > attributedTextContentView.bounds.size.width {
                let scale = frame.size.width / attributedTextContentView.bounds.size.width
                attachment.displaySize = CGSize(width: attachment.displaySize.width / scale, height: attachment.displaySize.height / scale)
            }
            let videoView = DTWebVideoView(frame: frame)
            videoView.attachment = attachment
            return videoView
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
        linkButton.URL = url
        linkButton.minimumHitSize = CGSize(width: 25, height: 25)
        linkButton.addTarget(self, action: "linkButtonDidPress:", forControlEvents: .TouchUpInside)
        linkButton.GUID = identifier
        return linkButton
    }
    
    func linkButtonDidPress(button: DTLinkButton) {
        presentViewController(UINavigationController(rootViewController: WebViewController(url: button.URL)), animated: true, completion: nil)
    }
}