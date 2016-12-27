//
//  Extensions.swift
//  HackerNews
//
//  Created by alexchoi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import AutolayoutExtensions

struct Shared {
    static let prototypeView = UIView()
}

func merge<K,V>(_ dicts: [K: V]...) -> [K: V] {
    var new = [K: V]()
    for dict in dicts {
        for (k,v) in dict {
            new[k] = v
        }
    }
    return new
}
