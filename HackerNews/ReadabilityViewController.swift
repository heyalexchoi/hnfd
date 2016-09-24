//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class ReadabilityViewContoller: UIViewController {
    
    var article: ReadabilityArticle?
    let story: Story
    let articleURL: URL?
    
    let webView = UIWebView()
    
    var shouldScroll = true
    var readingProgress: CGFloat {
        return webView.scrollView.contentOffset.y / webView.scrollView.contentSize.height
    }
    
    var htmlLoaded = false
    
    init(story: Story) {
        self.story = story
        self.articleURL = story.URL as URL?
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ReadabilityViewContoller.actionButtonDidPress))

        NotificationCenter.default.addObserver(self, selector: #selector(ReadabilityViewContoller.saveReadingProgress), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        getReadabilityArticle()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // hides white flash. for whatever reason setting webview's background color doesnt prevent white flash.
        view.backgroundColor = UIColor.backgroundColor()
        webView.isHidden = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        
        webView.delegate = self
        
        for view in [webView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        
        _ = view.addConstraints(withVisualFormats: [
            "H:|[webView]|",
            "V:|[webView]|"], views: [
                "webView": webView])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveReadingProgress()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToReadingProgress()
    }
    
}

extension ReadabilityViewContoller {
    
    func saveReadingProgress() {
        article?.readingProgress = readingProgress
        article?.save()
    }
    
    func scrollToReadingProgress() {
        if webView.scrollView.contentSize.height > webView.scrollView.bounds.size.height
            && shouldScroll,
            let article = article {
            webView.scrollView.setContentOffset(CGPoint(x:0, y: article.readingProgress * webView.scrollView.contentSize.height), animated: false)
            shouldScroll = false
        }
        webView.isHidden = false
    }
    
    func getReadabilityArticle() {
        ProgressHUD.showAdded(to: view, animated: true)
        DataSource.getArticle(story, completion: { [weak self] (article, error) -> Void in
            ProgressHUD.hide(for: self?.view, animated: true)
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
        guard let articleURL = articleURL else { return }
        let storyActivity = StoryActivity()
        present(UIActivityViewController(activityItems: [articleURL, story], applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
}

extension ReadabilityViewContoller {
    
    var CSS: String {
        let cssPath = Bundle.main.path(forResource: "readability_article", ofType: "css")!
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
                "<div><a href='\(article.URLString)'> \(article.URLString) </a></div>" +
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
        
        if let URLString = story.URLString {
            articleInfo +=
                "<div><a href='\(URLString)'> \(URLString) </a></div>" +
            "</div>"
        }
        
        let body = "<body>" + articleInfo + "Was not able to parse this article. :(" + "</body>"
        
        return body
    }
}

extension ReadabilityViewContoller: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let URL = request.url , htmlLoaded {
            presentWebViewController(URL)
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        htmlLoaded = true
        scrollToReadingProgress()
    }
}
