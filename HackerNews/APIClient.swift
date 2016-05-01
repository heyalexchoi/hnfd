//
//  APIClient.swift
//  HackerNews
//
//  Created by Alex Choi on 5/1/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

struct APIClient {
    
    let backgroundManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.hnfd.background")
        return Alamofire.Manager(configuration: configuration)
    }()
    
    // need router for building requests
    // need way to get destination url that will pop the file into where pincache is reading
    
    func download(request: URLRequestConvertible, destinationURL: NSURL) {
        let downloadDestination: Request.DownloadFileDestination = { (_,_) -> NSURL in
            return destinationURL
        }
        backgroundManager.download(request, destination: downloadDestination)
    }
    
    
    
}