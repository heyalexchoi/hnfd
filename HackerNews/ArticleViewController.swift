//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//
import WebKit
import PromiseKit

class ArticleViewController: UIViewController {
    
    var article: MercuryArticle?
    let story: Story
    let articleURL: URL?
    
    let webView = WKWebView()
    
    var shouldScroll = true
        
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
        webView.navigationDelegate = self
        
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
}

extension ArticleViewController {
    
    @objc func saveReadingProgress() {
        var hoistedWindowScrollY: CGFloat = 0
        getWindowScrollY()
            .then { [weak self] windowScrollY -> Promise<CGFloat> in
                hoistedWindowScrollY = windowScrollY
                guard let strongSelf = self else {
                    throw HNFDError.generic(message: "trying to access property of article view controller but it does not exist")
                }
                return strongSelf.getWebDocumentHeight()
            }
            .done { [weak self] webDocumentHeight in
                guard let article = self?.article else {
                    return
                }
                let readingProgress = hoistedWindowScrollY / webDocumentHeight
                print("saving reading progress: \(readingProgress)")
                Cache.shared.setReadingProgress(article: article, readingProgress: readingProgress)
            }
            .cauterize()
    }
    
    func getWindowScrollY() -> Promise<CGFloat> {
        return Promise { seal in
            webView.evaluate(javascriptString: "window.scrollY")
                .done { (scrollY) in
                    guard let scrollY = scrollY as? CGFloat else {
                        throw HNFDError.generic(message: "unable to cast window.scrollY to CGFloat")
                    }
                    seal.fulfill(scrollY)
            }
                .cauterize()
        }
    }
    
    func getWebDocumentHeight() -> Promise<CGFloat> {
        return Promise { seal in
            webView.evaluate(javascriptString: "document.readyState")
            .then { [weak self] (readyState) -> Promise<Any> in
                guard let readyState = readyState as? String,
                    let strongSelf = self,
                    readyState == "complete" else {
                    throw HNFDError.generic(message: "webView document.readyState is not complete")
                }
                return strongSelf.webView.evaluate(javascriptString: "document.body.scrollHeight")
            }
            .done { scrollHeight in
                guard let scrollHeight = scrollHeight as? CGFloat else {
                    throw HNFDError.generic(message: "unable to cast document.body.scrollHeight to CGFloat")
                }
                seal.fulfill(scrollHeight)
            }
            .cauterize()
        }
    }
    
    func scrollToReadingProgress() {
        getWebDocumentHeight()
            .done { [weak self] (height) in
                self?.setWebViewContentOffsetToMatchReadingProgress(webDocumentHeight: height)
            }
            .cauterize()
    }
    
    func setWebViewContentOffsetToMatchReadingProgress(webDocumentHeight: CGFloat) {
        print("web doc height: \(webDocumentHeight)")
        print("scrollview height: \(webView.scrollView.bounds.size.height)")
        print("should scroll: \(shouldScroll)")

        if webDocumentHeight > webView.scrollView.bounds.size.height
            && shouldScroll,
            let article = article {
            Cache.shared.getReadingProgress(article: article)
                .done { [weak self] readingProgress in
                    print("reading progress: \(readingProgress)")
                    let scrollYDestination = readingProgress * webDocumentHeight
                    self?.webView.evaluate(javascriptString: "window.scrollTo(0,\(scrollYDestination))")
                    print("scrolling to destination Y: \(scrollYDestination)")

            }
            .cauterize()
            shouldScroll = false
        }
        webView.isHidden = false
    }
    
    func getMercuryArticle() {
        ProgressHUD.showAdded(to: view, animated: true)
        DataSource.getArticle(story, completion: { [weak self] (result) -> Void in
            ProgressHUD.hide(for: self?.view, animated: true)
            switch result {
            case .success(let article):
                self?.article = article
            case .failure(let error):
                ErrorController.showErrorNotification(error)
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
            // WKWebView tries to scale content and doesn't respect the font size we give without this special header
            // https://stackoverflow.com/questions/45998220/the-font-looks-like-smaller-in-wkwebview-than-in-uiwebview
            // also would not respect css value -webkit-text-size-adjust, webkit-text-size-adjust, or text-size-adjust
            // https://forums.developer.apple.com/thread/128293

            let header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
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
            
            let body = "<body>" + header + articleInfo + article.content + "</body>"
            
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

extension ArticleViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        htmlLoaded = true
        scrollToReadingProgress()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let policy: WKNavigationActionPolicy = htmlLoaded ? .cancel : .allow
        decisionHandler(policy)
        if policy == .cancel && navigationAction.navigationType == .linkActivated,
            let url = navigationAction.request.url {
            presentWebViewController(url)
        }
    }
}
