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
    let articleURL: NSURL
    
    let textView = UITextView()
    
    let textAttributes = TextAttributes.textAttributes
    
    init(articleURL: NSURL) {
        self.articleURL = articleURL
        super.init(nibName: nil, bundle: nil)
        
        textView.backgroundColor = UIColor.backgroundColor()
        for view in [textView] {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(view)
        }
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[textView]|",
            "V:|[textView]|"], views: [
                "textView": textView])
        
        getReadabilityArticle()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getReadabilityArticle() {
        ProgressHUD.showHUDAddedTo(view, animated: true)
        apiClient.getParsedArticleForURL(articleURL, completion: { [weak self] (article, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.article = article
            if let article = article,
                strong_self = self {
                    let attributedContent = NSMutableAttributedString(htmlString: article.content)
                    attributedContent.addAttributes(strong_self.textAttributes, range: NSRange(location: 0, length: count(attributedContent.string)))
                    strong_self.textView.attributedText = attributedContent
                    strong_self.title = article.title
            } else if let error = error {
                UIAlertView(title: "Get Parsed Article Error",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
            }
            })
    }
    
}
