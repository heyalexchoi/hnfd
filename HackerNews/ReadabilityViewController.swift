//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class ReadabilityViewContoller: UIViewController {
    
    var article: ReadabilityArticle?
    var task: NSURLSessionTask?
    
    let cache = Cache.sharedCache()
    let story: Story
    let articleURL: NSURL
    
    let webView = UIWebView()
    
    init(story: Story) {
        self.story = story
        self.articleURL = story.URL!
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonDidPress")
        
        // hides white flash. for whatever reason setting webview's background color doesnt prevent white flash.
        view.backgroundColor = UIColor.backgroundColor()
        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
        
        for view in [webView] {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(view)
        }
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[webView]|",
            "V:|[webView]|"], views: [
                "webView": webView])
        
        getReadabilityArticle()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
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
        
        let cssPath = NSBundle.mainBundle().pathForResource("readability_article", ofType: "css")!
        let css = String(contentsOfFile:cssPath, encoding: NSUTF8StringEncoding, error: nil)!
        
        // swift compiler choking on string concatenations. had to break them into more statements
        var customCSS =
        
        "body {"
        customCSS +=
            "font-size: \(UIFont.textReaderFont().pointSize);" +
            "font-family: \(UIFont.textReaderFont().fontName);" +
            "background-color: \(UIColor.backgroundColor().hexString());" +
            "color: \(UIColor.textColor().hexString());"
        customCSS +=
        " }"
        
        customCSS +=
        "a {" +
            "color: \(UIColor.textColor().hexString());" +
        "}"
        
        let head = "<head><style type='text/css'>" + css + customCSS + "</style></head>"
        
        var articleInfo =
        "<div class='article_info'>" +
        "<h1>\(article.title)</h1>"
        
        if !article.author.isEmpty {
            articleInfo +=
                "<div>" +
                "<span class='by'>By </span>" +
                "<span class='author'>\(article.author), </span>" +
                "<span class='domain'>\(article.domain)</span>" +
            "</div>"
        }
        
        if let date = article.datePublished {
            let string = DateFormatter.stringFromDate(date, format: "MMM d, yyyy")
            articleInfo += "<div>\(string)</div>"
        }
        
        articleInfo +=
            "<div><a href='url'> \(article.URL) </a></div>" +
        "</div>"
        
        let body = "<body>" + articleInfo + article.content + "</body>"
        
        let html = head + body
                
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func actionButtonDidPress() {
        let storyActivity = StoryActivity()
        presentViewController(UIActivityViewController(activityItems: [articleURL, story], applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
    
}
