//
//  ArrayExtensions.swift
//  HackerNews
//
//  Created by Alex Choi on 2/24/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import Foundation


extension Array {
    func paginate(page: Int, per_page: Int) -> Array {
        guard !self.isEmpty else {
            return []
        }
        
        let start = ((page - 1) * per_page)
        let end = (page) * per_page
        let maxNonInclusiveIndex = self.count
        
        guard start < maxNonInclusiveIndex else {
            return []
        }
        
        let safeEnd = Swift.min(end, maxNonInclusiveIndex)
        let slice = self[start..<safeEnd]
        return Array(slice)
    }
}
