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
    
    var shouldScroll = true
    var readingProgress: CGFloat {
        return webView.scrollView.contentOffset.y / webView.scrollView.contentSize.height
    }
    
    var htmlLoaded = false
    
    init(story: Story) {
        self.story = story
        self.articleURL = story.URL!
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonDidPress")
        
        // hides white flash. for whatever reason setting webview's background color doesnt prevent white flash.
        view.backgroundColor = UIColor.backgroundColor()
        webView.hidden = true
        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
        
        webView.delegate = self
        
        for view in [webView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[webView]|",
            "V:|[webView]|"], views: [
                "webView": webView])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveReadingProgress", name: UIApplicationWillResignActiveNotification, object: nil)
        
        getReadabilityArticle()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveReadingProgress()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToReadingProgress()
    }
    
    func saveReadingProgress() {
        if story.saved {
            article?.readingProgress = readingProgress
            article?.save()
        }
    }
    
    func scrollToReadingProgress() {
        if webView.scrollView.contentSize.height > webView.scrollView.bounds.size.height
            && shouldScroll,
            let article = article {
                webView.scrollView.setContentOffset(CGPoint(x:0, y: article.readingProgress * webView.scrollView.contentSize.height), animated: false)
                shouldScroll = false
        }
        webView.hidden = false
    }
    
    func getReadabilityArticle() {
        task?.cancel()
        ProgressHUD.showHUDAddedTo(view, animated: true)
        task = cache.articleForStory(story, completion: { [weak self] (article, error) -> Void in
            ProgressHUD.hideHUDForView(self?.view, animated: true)
            self?.article = article
            self?.finishLoadingArticle()
            ErrorController.showErrorNotification(error)
            })
    }
    
    func finishLoadingArticle() {
        let html = head + body
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func actionButtonDidPress() {
        let storyActivity = StoryActivity()
        presentViewController(UIActivityViewController(activityItems: [articleURL, story], applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
    
}

extension ReadabilityViewContoller {
    
    var CSS: String {
        let cssPath = NSBundle.mainBundle().pathForResource("readability_article", ofType: "css")!
        let css = try! String(contentsOfFile: cssPath)
        // swift compiler choking on string concatenations. had to break them into more statements
        var customCSS =
        "body {"
        customCSS +=
            "font-size: \(UIFont.textReaderFont().pointSize);" +
            "font-family: \(UIFont.textReaderFont().fontName);" +
            "background-color: \(UIColor.backgroundColor().hexString());" +
            "color: \(UIColor.textColor().hexString());"
        customCSS +=
        "}"
        customCSS +=
        "a {" +
            "color: \(UIColor.textColor().hexString());" +
        "}"
        
        return css + customCSS
    }
    
    var head: String {
        return "<head><style type='text/css'>" + CSS + "</style></head>"
    }
    
    var body: String {
        
        if let article = article {
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
                "<div><a href='\(article.URL)'> \(article.URL) </a></div>" +
            "</div>"
            
            let body = "<body>" + articleInfo + article.content + "</body>"
            
            return body
            
        }
        
        var articleInfo =
        "<div class='article_info'>" +
        "<h1>\(story.title)</h1>"
        
        if !story.by.isEmpty {
            articleInfo +=
                "<div>" +
                "<span class='by'>Posted by </span>" +
                "<span class='author'>\(story.by)</span>" +
            "</div>"
        }
        
        let string = DateFormatter.stringFromDate(story.date, format: "MMM d, yyyy")
        articleInfo += "<div>\(string)</div>"
        
        if let URL = story.URL {
            articleInfo +=
                "<div><a href='\(URL)'> \(URL) </a></div>" +
            "</div>"
        }
        
        let body = "<body>" + articleInfo + "Was not able to parse this article. :(" + "</body>"
        
        return body
    }
}

extension ReadabilityViewContoller: UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let URL = request.URL where htmlLoaded {
            presentWebViewController(URL)
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        htmlLoaded = true
        scrollToReadingProgress()
    }
}
