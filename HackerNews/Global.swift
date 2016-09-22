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

func pmap<T,U>(_ array: Array<T>, closure: (T) -> U) -> Array<U> {
    var pmapped = Array<U>()
    DispatchQueue.concurrentPerform(iterations: array.count) { (i) -> Void in
        pmapped.append(closure(array[i]))
    }
    return pmapped
}
