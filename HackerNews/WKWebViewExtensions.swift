//
//  WKWebViewExtensions.swift
//  HackerNews
//
//  Created by Alex Choi on 6/6/20.
//  Copyright © 2020 Alex Choi. All rights reserved.
//

import Foundation
import WebKit
import PromiseKit

extension WKWebView {
    @discardableResult func evaluate(javascriptString: String) -> Promise<Any> {
        return Promise { seal in
            evaluateJavaScript(javascriptString, completionHandler: { (result, error) in
                if let error = error {
                    seal.reject(error)
                    return
                }
                if let result = result {
                    seal.fulfill(result)
                    return
                }
                seal.reject(HNFDError.generic(message: "attempting to evaluate javascript string. no results or errors"))
            })
        }
    }
}
