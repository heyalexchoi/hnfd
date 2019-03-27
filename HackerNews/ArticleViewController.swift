//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

class ArticleViewController: UIViewController {
    
    var article: MercuryArticle?
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ArticleViewController.actionButtonDidPress))
        
        NotificationCenter.default.addObserver(self, selector: #selector(ArticleViewController.saveReadingProgress), name: UIApplication.willResignActiveNotification, object: nil)
        
        getMercuryArticle()
        hidesBottomBarWhenPushed = true
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

extension ArticleViewController {
    
    @objc func saveReadingProgress() {
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
    
    func getMercuryArticle() {
        ProgressHUD.showAdded(to: view, animated: true)
        DataSource.getArticle(story, completion: { [weak self] (result) -> Void in
            ProgressHUD.hide(for: self?.view, animated: true)
            
            if let article = result.value {
                self?.article = article
            } else {
                ErrorController.showErrorNotification(result.error)
            }
            self?.finishLoadingArticle()
            })
    }
    
    func finishLoadingArticle() {
        let html = head + body
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    @objc func actionButtonDidPress() {
        guard let articleURL = articleURL else { return }
        let storyActivity = StoryActivity()
        present(UIActivityViewController(activityItems: [articleURL, story], applicationActivities: [storyActivity]), animated: true, completion: nil)
    }
}

extension ArticleViewController {
    
    var CSS: String {
        
        let backgroundColorHexString: String = UIColor.backgroundColor().hexString()
        let textColorHexString: String = UIColor.textColor().hexString()
        
        let cssPath = Bundle.main.path(forResource: "readability_article", ofType: "css")!
        let css = try! String(contentsOfFile: cssPath)
        // swift compiler choking on string concatenations. had to break them into more statements
        var customCSS =
        "body {"
        customCSS +=
            "font-size: \(UIFont.textReaderFont().pointSize);" +
            "font-family: \(UIFont.textReaderFont().fontName);" +
            "background-color: \(backgroundColorHexString);" +
        "color: \(textColorHexString);"
        customCSS +=
        "}"
        customCSS +=
            "a {" +
            "color: \(textColorHexString);" +
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

extension ArticleViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
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
