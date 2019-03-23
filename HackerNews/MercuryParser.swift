//
//  MercuryParser.swift
//  HackerNews
//
//  Created by Alex Choi on 3/23/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

struct MercuryParser {
    
    let jsCode: String
    
    init() {
        guard let url = Bundle.main.url(forResource: "outputs/@postlight/mercury-parser/dist/mercury.web", withExtension: "js") else {
            print("MercuryParser could not find mercury.web.js")
            jsCode = ""
            return
        }
        do {
            jsCode = try String(contentsOf: url)
        } catch let error {
            jsCode = ""
            print("MercuryParser.init ERROR: " + error.localizedDescription)
        }
    }
}
